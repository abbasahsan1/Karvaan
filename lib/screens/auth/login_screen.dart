import 'package:flutter/material.dart';
import 'package:karvaan/routes/app_routes.dart';
import 'package:karvaan/providers/user_provider.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/glass_container.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final String? message;  // Added to display messages (like signup success)
  
  const LoginScreen({Key? key, this.message}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;

  OutlineInputBorder _outlineInputBorder(Color color, {double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData prefix,
    Widget? suffix,
  }) {
    final theme = Theme.of(context);
    final primaryColor = AppTheme.primaryColor;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: theme.textTheme.titleSmall?.copyWith(
        color: primaryColor.withOpacity(0.82),
        fontWeight: FontWeight.w600,
      ),
      floatingLabelStyle: theme.textTheme.titleSmall?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w700,
      ),
      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.black45),
      prefixIcon: Icon(prefix, color: primaryColor.withOpacity(0.85)),
      suffixIcon: suffix != null
          ? IconTheme(
              data: IconThemeData(color: primaryColor.withOpacity(0.85)),
              child: suffix,
            )
          : null,
      filled: true,
      fillColor: Colors.white.withOpacity(0.92),
      border: _outlineInputBorder(primaryColor.withOpacity(0.28)),
      enabledBorder: _outlineInputBorder(primaryColor.withOpacity(0.32)),
      focusedBorder: _outlineInputBorder(AppTheme.accentColor, width: 1.8),
      errorBorder: _outlineInputBorder(AppTheme.accentRedColor.withOpacity(0.85)),
      focusedErrorBorder: _outlineInputBorder(AppTheme.accentRedColor),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
      });

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.main);
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = userProvider.error ?? 'Login failed. Please try again.';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the user provider
    final userProvider = Provider.of<UserProvider>(context);
    
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return KarvaanScaffoldShell(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 32 + bottomInset),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: GlassContainer(
                      borderRadius: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_car,
                            size: 34,
                            color: AppTheme.accentColorLight,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Karvaan',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GlassContainer(
                    borderRadius: 32,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome back',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue managing your vehicles and services.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 24),
                        if (widget.message != null)
                          GlassContainer(
                            borderRadius: 18,
                            padding: const EdgeInsets.all(14),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                            ),
                            child: Text(
                              widget.message!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                            ),
                          ),
                        if (widget.message != null) const SizedBox(height: 16),
                        if (_errorMessage != null)
                          GlassContainer(
                            borderRadius: 18,
                            padding: const EdgeInsets.all(14),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFE11D48)],
                            ),
                            child: Text(
                              _errorMessage!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                            ),
                          ),
                        if (_errorMessage != null) const SizedBox(height: 16),
                        Text(
                          'Email',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                letterSpacing: 0.4,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          decoration: _fieldDecoration(
                            context,
                            label: 'Email',
                            hint: 'Enter your email',
                            prefix: Icons.email_rounded,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Password',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                letterSpacing: 0.4,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          decoration: _fieldDecoration(
                            context,
                            label: 'Password',
                            hint: 'Enter your password',
                            prefix: Icons.lock_outline_rounded,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: AppTheme.accentColor,
                              checkColor: Colors.black,
                            ),
                            Text(
                              'Remember me',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.forgotPassword);
                              },
                              style: TextButton.styleFrom(foregroundColor: AppTheme.accentColorLight),
                              child: const Text('Forgot Password?'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'Login',
                          onPressed: userProvider.isLoading ? null : _login,
                          isLoading: userProvider.isLoading,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.register);
                              },
                              style: TextButton.styleFrom(foregroundColor: AppTheme.accentColorLight),
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
