import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          if (user == null) {
            return Center(child: Text(AppLocalizations.of(context)!.noUserData));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: colors.primary.withOpacity(0.16),
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Chip(
                        avatar: const Icon(Icons.verified_user, size: 18),
                        label: Text(
                          user.role.toUpperCase(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colors.primary,
                          ),
                        ),
                        backgroundColor: colors.primary.withOpacity(0.14),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      _ProfileTile(
                        icon: Icons.person_outline,
                        title: AppLocalizations.of(context)!.name,
                        value: user.name,
                      ),
                      _divider(colors),
                      _ProfileTile(
                        icon: Icons.email_outlined,
                        title: AppLocalizations.of(context)!.email,
                        value: user.email,
                      ),
                      if (user.phoneNumber != null) ...[
                        _divider(colors),
                        _ProfileTile(
                          icon: Icons.phone_outlined,
                          title: AppLocalizations.of(context)!.phone,
                          value: user.phoneNumber!,
                        ),
                      ],
                      _divider(colors),
                      _ProfileTile(
                        icon: Icons.work_outline,
                        title: AppLocalizations.of(context)!.role,
                        value: user.role.toUpperCase(),
                      ),
                      if (user.department != null) ...[
                        _divider(colors),
                        _ProfileTile(
                          icon: Icons.business_outlined,
                          title: AppLocalizations.of(context)!.department,
                          value: user.department!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.red.withOpacity(0.12),
                    child: const Icon(Icons.logout, color: Colors.red),
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.logout,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.logout),
                        content: Text('${AppLocalizations.of(context)!.confirm} ${AppLocalizations.of(context)!.logout.toLowerCase()}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: Text(AppLocalizations.of(context)!.logout),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.logout();
                      if (!context.mounted) return;
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _divider(ColorScheme colors) => Divider(
      height: 1,
      thickness: 1,
      color: colors.outlineVariant.withOpacity(0.6),
    );

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: colors.primary.withOpacity(0.12),
        child: Icon(icon, color: colors.primary),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: colors.onSurface.withOpacity(0.85),
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
