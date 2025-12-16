import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/helpers.dart';
import 'check_in_screen.dart';
import 'attendance_history_screen.dart';
import 'profile_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;
  bool _statsLoaded = false;

  @override
  void initState() {
    super.initState();
    // Defer all data loading until after the first frame to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadStats();
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId != null) {
      await attendanceProvider.loadTodayAttendance(userId);
      // Also reload stats when refreshing
      await _loadStats(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          user?.name ?? AppLocalizations.of(context)!.user,
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(theme, colors),
          const AttendanceHistoryScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surface,
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
          indicatorColor: colors.primaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 300),
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined, size: 24),
              selectedIcon: const Icon(Icons.home, size: 24),
              label: AppLocalizations.of(context)!.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_outlined, size: 24),
              selectedIcon: const Icon(Icons.history, size: 24),
              label: AppLocalizations.of(context)!.history,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline, size: 24),
              selectedIcon: const Icon(Icons.person, size: 24),
              label: AppLocalizations.of(context)!.profile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(ThemeData theme, ColorScheme colors) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _HeaderCard(theme: theme, colors: colors),
            const SizedBox(height: 20),
            Consumer<AttendanceProvider>(
              builder: (context, attendanceProvider, _) {
                final todayAttendance = attendanceProvider.todayAttendance;

                return _TodayCard(
                  theme: theme,
                  colors: colors,
                  todayAttendance: todayAttendance,
                  onCheckOut: () async {
                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                    final userId = authProvider.currentUser?.id;
                    if (userId != null) {
                      try {
                        await attendanceProvider.checkOut(userId);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.checkOutSuccessful),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                          ),
                        );
                      }
                    }
                  },
                  onCheckIn: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CheckInScreen(),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            Consumer<AttendanceProvider>(
              builder: (context, attendanceProvider, _) {
                final stats = attendanceProvider.stats;
                final isLoading = attendanceProvider.isLoading && stats == null;
                
                if (isLoading) {
                  return Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.loading,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                if (stats == null) {
                  return const SizedBox.shrink();
                }

                return _StatsCard(
                  theme: theme,
                  colors: colors,
                  present: stats.present,
                  late: stats.late,
                  absent: stats.absent,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadStats({bool force = false}) async {
    if (_statsLoaded && !force) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId != null && mounted) {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      await attendanceProvider.loadStats(
        userId,
        startDate: startOfMonth,
        endDate: now,
      );
      if (mounted) {
        setState(() {
          _statsLoaded = true;
        });
      }
    }
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.theme, required this.colors});

  final ThemeData theme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.attendancePulse,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              Helpers.getGreeting(),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              Helpers.formatDate(DateTime.now(), format: 'EEEE, MMMM d, yyyy'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.theme,
    required this.colors,
    required this.todayAttendance,
    required this.onCheckOut,
    required this.onCheckIn,
  });

  final ThemeData theme;
  final ColorScheme colors;
  final dynamic todayAttendance;
  final VoidCallback onCheckOut;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: colors.primary),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.todayStatus,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    todayAttendance?.checkInTime != null
                        ? AppLocalizations.of(context)!.processing
                        : AppLocalizations.of(context)!.status,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (todayAttendance?.checkInTime != null) ...[
              _InfoRow(
                label: AppLocalizations.of(context)!.checkInTime,
                value: Helpers.formatTime(todayAttendance!.checkInTime!),
                colors: colors,
                theme: theme,
              ),
              const SizedBox(height: 12),
              if (todayAttendance.checkOutTime != null) ...[
                _InfoRow(
                  label: AppLocalizations.of(context)!.checkOutTime,
                  value: Helpers.formatTime(todayAttendance.checkOutTime!),
                  colors: colors,
                  theme: theme,
                ),
                if (todayAttendance.workingHours != null) ...[
                  const SizedBox(height: 12),
                  Divider(color: colors.outlineVariant.withOpacity(0.6)),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: AppLocalizations.of(context)!.workingHours,
                    value:
                        Helpers.formatDuration(todayAttendance.workingHours!),
                    colors: colors,
                    theme: theme,
                    valueColor: colors.tertiary,
                  ),
                ],
              ] else ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: onCheckOut,
                    icon: const Icon(Icons.logout),
                    label: Text(AppLocalizations.of(context)!.checkOut),
                  ),
                ),
              ],
            ] else ...[
              Text(
                AppLocalizations.of(context)!.notCheckedInYet,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onCheckIn,
                icon: const Icon(Icons.camera_alt),
                label: Text(AppLocalizations.of(context)!.checkIn),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.theme,
    required this.colors,
    required this.present,
    required this.late,
    required this.absent,
  });

  final ThemeData theme;
  final ColorScheme colors;
  final int present;
  final int late;
  final int absent;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.thisMonth,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatPill(
                  label: AppLocalizations.of(context)!.present,
                  value: present,
                  color: colors.tertiary,
                  icon: Icons.check_circle,
                ),
                _StatPill(
                  label: AppLocalizations.of(context)!.late,
                  value: late,
                  color: Colors.orange,
                  icon: Icons.schedule,
                ),
                _StatPill(
                  label: AppLocalizations.of(context)!.absent,
                  value: absent,
                  color: Colors.red,
                  icon: Icons.cancel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: theme.textTheme.headlineSmall?.copyWith(color: color),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.colors,
    required this.theme,
    this.valueColor,
  });

  final String label;
  final String value;
  final ColorScheme colors;
  final ThemeData theme;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface.withOpacity(0.72),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: valueColor ?? colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
