import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance_model.dart';
import '../../utils/helpers.dart';
import 'package:attendance_app/l10n/app_localizations.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Defer history loading until after the first frame to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId != null) {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      await attendanceProvider.loadAttendanceHistory(
        userId,
        startDate: startOfMonth,
        endDate: now,
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.history),
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, attendanceProvider, _) {
          if (attendanceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = attendanceProvider.attendanceHistory;

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noAttendanceRecords,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadHistory,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final attendance = history[index];
                final statusColor = _getStatusColor(attendance.status.name);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.2),
                      child: Icon(
                        attendance.status == AttendanceStatus.present
                            ? Icons.check_circle
                            : attendance.status == AttendanceStatus.late
                                ? Icons.schedule
                                : Icons.cancel,
                        color: statusColor,
                      ),
                    ),
                    title: Text(
                      Helpers.formatDate(attendance.date, format: 'EEEE, MMMM d'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (attendance.checkInTime != null)
                          Text('${AppLocalizations.of(context)!.checkInTime}: ${Helpers.formatTime(attendance.checkInTime!)}'),
                        if (attendance.checkOutTime != null)
                          Text('${AppLocalizations.of(context)!.checkOutTime}: ${Helpers.formatTime(attendance.checkOutTime!)}'),
                        if (attendance.workingHours != null)
                          Text(
                            '${AppLocalizations.of(context)!.workingHours}: ${Helpers.formatDuration(attendance.workingHours!)}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        attendance.status == AttendanceStatus.present
                            ? AppLocalizations.of(context)!.present
                            : attendance.status == AttendanceStatus.late
                                ? AppLocalizations.of(context)!.late
                                : AppLocalizations.of(context)!.absent,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: statusColor.withOpacity(0.2),
                      labelStyle: TextStyle(color: statusColor),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

