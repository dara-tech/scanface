import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../user/user_home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String _selectedRole = 'employee';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        role: _selectedRole,
      );

      if (!mounted) return;

      final user = authProvider.currentUser;
      if (user != null) {
        // Navigate based on role
        if (user.role == 'admin') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const UserHomeScreen()),
          );
        }
      }
    } catch (e) {
      setState(() {
        // Extract clean error message
        String error = e.toString();
        error = error.replaceAll('Exception: ', '');
        error = error.replaceAll('DioException: ', '');
        _errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final maxWidth = isTablet ? screenWidth * 0.6 : 540.0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 48.0 : 24.0),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 48.0 : 24.0,
                      vertical: isTablet ? 40.0 : 28.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.person_add,
                          size: isTablet ? 80.0 : 56.0,
                        ),
                        SizedBox(height: isTablet ? 24.0 : 16.0),
                        Text(
                          AppLocalizations.of(context)!.createAccount,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colors.onSurface,
                            fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
                            fontSize: isTablet ? 32.0 : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isTablet ? 32.0 : 24.0),
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
                            fontSize: isTablet ? 18.0 : null,
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.name,
                            prefixIcon: Icon(Icons.person, size: isTablet ? 28.0 : null),
                            contentPadding: isTablet ? const EdgeInsets.symmetric(horizontal: 20, vertical: 20) : null,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.pleaseEnterName;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isTablet ? 24.0 : 16.0),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
                            fontSize: isTablet ? 18.0 : null,
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.email,
                            prefixIcon: Icon(Icons.alternate_email, size: isTablet ? 28.0 : null),
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
                          style: TextStyle(
                            color: colors.onSurface,
                            fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
                            fontSize: isTablet ? 18.0 : null,
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.phone,
                            prefixIcon: Icon(Icons.phone, size: isTablet ? 28.0 : null),
                            contentPadding: isTablet ? const EdgeInsets.symmetric(horizontal: 20, vertical: 20) : null,
                          ),
                        ),
                        SizedBox(height: isTablet ? 24.0 : 16.0),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
                            fontSize: isTablet ? 18.0 : null,
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.role,
                            prefixIcon: Icon(Icons.person_outline, size: isTablet ? 28.0 : null),
                            contentPadding: isTablet ? const EdgeInsets.symmetric(horizontal: 20, vertical: 20) : null,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'employee',
                              child: Text(AppLocalizations.of(context)!.employee),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text(AppLocalizations.of(context)!.admin),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedRole = value;
                              });
                            }
                          },
                        ),
                        SizedBox(height: isTablet ? 24.0 : 16.0),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
                            fontSize: isTablet ? 18.0 : null,
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.password,
                            prefixIcon: Icon(Icons.lock, size: isTablet ? 28.0 : null),
                            contentPadding: isTablet ? const EdgeInsets.symmetric(horizontal: 20, vertical: 20) : null,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: isTablet ? 28.0 : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.pleaseEnterPassword;
                            }
                            if (value.length < 6) {
                              return AppLocalizations.of(context)!.passwordTooShort;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isTablet ? 24.0 : 16.0),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
                            fontSize: isTablet ? 18.0 : null,
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.confirmPassword,
                            prefixIcon: Icon(Icons.lock_outline, size: isTablet ? 28.0 : null),
                            contentPadding: isTablet ? const EdgeInsets.symmetric(horizontal: 20, vertical: 20) : null,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: isTablet ? 28.0 : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.pleaseEnterConfirmPassword;
                            }
                            if (value != _passwordController.text) {
                              return AppLocalizations.of(context)!.passwordsDoNotMatch;
                            }
                            return null;
                          },
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.red.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: isTablet ? 32.0 : 24.0),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  padding: isTablet 
                                      ? const EdgeInsets.symmetric(vertical: 20)
                                      : null,
                                  minimumSize: isTablet 
                                      ? const Size(double.infinity, 56)
                                      : null,
                                ),
                                child: authProvider.isLoading
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(vertical: isTablet ? 4.0 : 2.0),
                                        child: SizedBox(
                                          height: isTablet ? 24.0 : 18.0,
                                          width: isTablet ? 24.0 : 18.0,
                                          child: const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.white),
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: EdgeInsets.symmetric(vertical: isTablet ? 4.0 : 2.0),
                                        child: Text(
                                          authProvider.isLoading
                                              ? AppLocalizations.of(context)!.processing
                                              : AppLocalizations.of(context)!.register,
                                          style: TextStyle(
                                            fontSize: isTablet ? 18.0 : null,
                                          ),
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.alreadyHaveAccount,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurface.withOpacity(0.7),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!.login,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 18.0 : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

