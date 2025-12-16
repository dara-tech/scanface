import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import 'package:attendance_app/l10n/app_localizations.dart';
import 'add_user_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userManagement.split(' ').first),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddUserScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = userProvider.users;

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noData,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddUserScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)!.addUser),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => userProvider.loadAllUsers(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRoleColor(user.role),
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        if (user.department != null) Text(user.department!),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(
                            user.role.toUpperCase(),
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                          labelStyle: TextStyle(color: _getRoleColor(user.role)),
                        ),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  const Icon(Icons.edit, size: 20),
                                  const SizedBox(width: 8),
                                  Text(AppLocalizations.of(context)!.editUser),
                                ],
                              ),
                              onTap: () {
                                // TODO: Implement edit user
                              },
                            ),
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  Icon(
                                    user.isActive ? Icons.block : Icons.check,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(user.isActive ? AppLocalizations.of(context)!.cancel : AppLocalizations.of(context)!.confirm),
                                ],
                              ),
                              onTap: () async {
                                final updated = user.copyWith(isActive: !user.isActive);
                                await userProvider.updateUser(updated);
                              },
                            ),
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  const Icon(Icons.delete, size: 20, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Text(AppLocalizations.of(context)!.deleteUser, style: const TextStyle(color: Colors.red)),
                                ],
                              ),
                              onTap: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(AppLocalizations.of(context)!.deleteUser),
                                    content: Text('${AppLocalizations.of(context)!.confirm} ${AppLocalizations.of(context)!.deleteUser.toLowerCase()} ${user.name}?'),
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
                                        child: Text(AppLocalizations.of(context)!.deleteUser),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await userProvider.deleteUser(user.id);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${AppLocalizations.of(context)!.user} ${AppLocalizations.of(context)!.deleteUser.toLowerCase()}')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
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

  Color _getRoleColor(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return Colors.red;
      case AppConstants.roleEmployee:
        return Colors.blue;
      case AppConstants.roleStudent:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

