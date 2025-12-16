import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/l10n/app_localizations.dart';
import '../providers/connection_provider.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final bool showDetails;
  final bool compact;

  const ConnectionStatusWidget({
    super.key,
    this.showDetails = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectionProvider>(
      builder: (context, connectionProvider, child) {
        final status = connectionProvider.status;
        final isOnline = connectionProvider.isOnline;
        final lastSync = connectionProvider.lastSyncTime;
        final errorMessage = connectionProvider.errorMessage;

        if (compact) {
          return _buildCompactIndicator(context, status, isOnline);
        }

        return _buildFullIndicator(
          context,
          status,
          isOnline,
          lastSync,
          errorMessage,
          showDetails,
        );
      },
    );
  }

  Widget _buildCompactIndicator(
    BuildContext context,
    ConnectionStatus status,
    bool isOnline,
  ) {
    Color color;
    IconData icon;

    switch (status) {
      case ConnectionStatus.connected:
        color = Colors.green;
        icon = Icons.cloud_done;
        break;
      case ConnectionStatus.connecting:
      case ConnectionStatus.syncing:
        color = Colors.orange;
        icon = Icons.cloud_sync;
        break;
      case ConnectionStatus.disconnected:
        color = Colors.red;
        icon = Icons.cloud_off;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullIndicator(
    BuildContext context,
    ConnectionStatus status,
    bool isOnline,
    DateTime? lastSync,
    String? errorMessage,
    bool showDetails,
  ) {
    final localizations = AppLocalizations.of(context);
    
    Color color;
    IconData icon;
    String statusText;
    String? subtitle;

    switch (status) {
      case ConnectionStatus.connected:
        color = Colors.green;
        icon = Icons.cloud_done;
        statusText = localizations?.serverConnected ?? 'Connected';
        if (lastSync != null && showDetails) {
          final diff = DateTime.now().difference(lastSync);
          if (diff.inSeconds < 60) {
            subtitle = '${diff.inSeconds}s ago';
          } else if (diff.inMinutes < 60) {
            subtitle = '${diff.inMinutes}m ago';
          } else {
            subtitle = '${diff.inHours}h ago';
          }
        }
        break;
      case ConnectionStatus.connecting:
        color = Colors.orange;
        icon = Icons.cloud_sync;
        statusText = localizations?.connecting ?? 'Connecting...';
        break;
      case ConnectionStatus.syncing:
        color = Colors.blue;
        icon = Icons.sync;
        statusText = localizations?.syncing ?? 'Syncing...';
        break;
      case ConnectionStatus.disconnected:
        color = Colors.red;
        icon = Icons.cloud_off;
        statusText = localizations?.serverDisconnected ?? 'Disconnected';
        if (errorMessage != null && showDetails) {
          subtitle = errorMessage;
        }
        break;
    }

    return GestureDetector(
      onTap: () {
        if (status == ConnectionStatus.disconnected) {
          Provider.of<ConnectionProvider>(context, listen: false).syncNow();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (subtitle != null && showDetails)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            if (status == ConnectionStatus.syncing)
              const SizedBox(width: 8)
            else if (status == ConnectionStatus.disconnected)
              const SizedBox(width: 8),
            if (status == ConnectionStatus.syncing)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Persistent status bar at the top of the screen
class ConnectionStatusBar extends StatelessWidget {
  const ConnectionStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectionProvider>(
      builder: (context, connectionProvider, child) {
        final status = connectionProvider.status;
        
        // Only show bar when disconnected
        if (status != ConnectionStatus.disconnected) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.red.withOpacity(0.1),
          child: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)?.serverDisconnected ?? 
                  'No connection to server',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  connectionProvider.syncNow();
                },
                child: Text(
                  AppLocalizations.of(context)?.retry ?? 'Retry',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

