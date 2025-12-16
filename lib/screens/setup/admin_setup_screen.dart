import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/authentication_service.dart';
import 'package:attendance_app/l10n/app_localizations.dart';
import '../admin/admin_dashboard_screen.dart';

class AdminSetupScreen extends StatefulWidget {
  const AdminSetupScreen({super.key});

  @override
  State<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthenticationService.instance.createAdminUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      // Auto login after creating admin
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(
        _emailController.text.trim(),
        _emailController.text.trim(), // Using email as password for demo
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final maxWidth = isTablet ? screenWidth * 0.6 : double.infinity;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.adminDashboard),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 48.0 : 24.0),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: isTablet ? 100.0 : 80.0,
                      color: Colors.blue,
                    ),
                    SizedBox(height: isTablet ? 32.0 : 24.0),
                    Text(
                      AppLocalizations.of(context)!.hello,
                      style: TextStyle(
                        fontSize: isTablet ? 36.0 : 28.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isTablet ? 12.0 : 8.0),
                    Text(
                      AppLocalizations.of(context)!.addUser,
                      style: TextStyle(
                        fontSize: isTablet ? 20.0 : 16.0,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isTablet ? 40.0 : 32.0),
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(fontSize: isTablet ? 18.0 : null),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.name,
                        prefixIcon: Icon(Icons.person, size: isTablet ? 28.0 : null),
                        border: const OutlineInputBorder(),
                        contentPadding: isTablet ? const EdgeInsets.symmetric(horizontal: 20, vertical: 20) : null,
                      ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterEmail.replaceAll('email', AppLocalizations.of(context)!.name.toLowerCase());
                    }
                    return null;
                  },
                ),
                    SizedBox(height: isTablet ? 24.0 : 16.0),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: isTablet ? 18.0 : null),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.email,
                        prefixIcon: Icon(Icons.email, size: isTablet ? 28.0 : null),
                        border: const OutlineInputBorder(),
                        contentPadding: isTablet ? const EdgeInsets.symmetric(horizontal: 20, vertical: 20) : null,
                      ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterEmail;
                    }
                    if (!value.contains('@')) {
                      return AppLocalizations.of(context)!.pleaseEnterValidEmail;
                    }
                    return null;
                  },
                ),
                    SizedBox(height: isTablet ? 24.0 : 16.0),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(fontSize: isTablet ? 18.0 : null),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.phone,
                        prefixIcon: Icon(Icons.phone, size: isTablet ? 28.0 : null),
                        border: const OutlineInputBorder(),
                        contentPadding: isTablet ? const EdgeInsets.symmetric(horizontal: 20, vertical: 20) : null,
                      ),
                    ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                    SizedBox(height: isTablet ? 32.0 : 24.0),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createAdmin,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 20.0 : 16.0),
                        minimumSize: isTablet ? const Size(double.infinity, 56) : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: isTablet ? 24.0 : 20.0,
                              width: isTablet ? 24.0 : 20.0,
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              AppLocalizations.of(context)!.addUser,
                              style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

