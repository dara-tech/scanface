import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance_model.dart';
import '../../utils/helpers.dart';
import 'package:attendance_app/l10n/app_localizations.dart';
import 'user_management_screen.dart';
import 'face_registration_screen.dart';
import 'attendance_report_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  int _todayCheckIns = 0;
  int _pendingUsers = 0;
  bool _statsLoaded = false;

  @override
  void initState() {
    super.initState();
    // Defer stats loading until after the first frame to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodayStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.adminDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppLocalizations.of(context)!.logout,
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(),
          const UserManagementScreen(),
          const FaceRegistrationScreen(),
          const AttendanceReportScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          height: 70,
          elevation: 0,
          backgroundColor: Colors.transparent,
          indicatorColor: Theme.of(context).colorScheme.primaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 300),
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined, size: 24),
              selectedIcon: const Icon(Icons.dashboard, size: 24),
              label: AppLocalizations.of(context)!.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline, size: 24),
              selectedIcon: const Icon(Icons.people, size: 24),
              label: AppLocalizations.of(context)!.userManagement,
            ),
            NavigationDestination(
              icon: const Icon(Icons.face_outlined, size: 24),
              selectedIcon: const Icon(Icons.face, size: 24),
              label: AppLocalizations.of(context)!.faceRegistration,
            ),
            NavigationDestination(
              icon: const Icon(Icons.assessment_outlined, size: 24),
              selectedIcon: const Icon(Icons.assessment, size: 24),
              label: AppLocalizations.of(context)!.attendanceReports,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Text(
                  '${Helpers.getGreeting()}, ${authProvider.currentUser?.name ?? AppLocalizations.of(context)!.admin}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              Helpers.formatDate(DateTime.now(), format: 'EEEE, MMMM d, yyyy'),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    AppLocalizations.of(context)!.todayPresent,
                    _todayCheckIns.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    AppLocalizations.of(context)!.status,
                    _pendingUsers.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.settings,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  AppLocalizations.of(context)!.addUser,
                  Icons.person_add,
                  Colors.blue,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const UserManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  AppLocalizations.of(context)!.faceRegistration,
                  Icons.face,
                  Colors.purple,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FaceRegistrationScreen(),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  AppLocalizations.of(context)!.attendanceReports,
                  Icons.assessment,
                  Colors.green,
                  () {
                    setState(() {
                      _currentIndex = 3;
                    });
                  },
                ),
                _buildActionCard(
                  AppLocalizations.of(context)!.userManagement,
                  Icons.people,
                  Colors.orange,
                  () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadDashboardData() async {
    await _loadTodayStats(force: true);
  }

  Future<void> _loadTodayStats({bool force = false}) async {
    if (_statsLoaded && !force) return;
    
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    // Load all attendance for today
    try {
      final allAttendance = await attendanceProvider.loadAllAttendanceForAdmin(
        startDate: todayStart,
        endDate: today,
      );

      if (mounted) {
        setState(() {
          _todayCheckIns = allAttendance.where((a) => a.checkInTime != null).length;
          // This is a placeholder - you'd calculate pending users based on your logic
          _pendingUsers = 0;
          _statsLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading today stats: $e');
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


