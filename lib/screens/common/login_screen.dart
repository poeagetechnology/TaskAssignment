import 'package:flutter/material.dart';
import '../../config/index.dart';

/// Login screen for authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Sign in user
      await AppConfig.authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Navigate to appropriate screen based on role
        // This will be handled by the auth wrapper
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.md16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Header
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md16),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Icon(
                      Icons.construction,
                      size: 64,
                      color: AppColors.constructionGold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg20),

                  // Title
                  Text(
                    'Sago Builders',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: AppTypography.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md16),

                  // Subtitle
                  Text(
                    'Civil Construction Task Management',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg20 * 2),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(
                        color: AppColors.slateGrey.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.constructionGold,
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        borderSide: BorderSide(
                          color: AppColors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        borderSide: BorderSide(
                          color: AppColors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        borderSide: BorderSide(
                          color: AppColors.constructionGold,
                          width: 2,
                        ),
                      ),
                      labelStyle: TextStyle(
                        color: AppColors.constructionGold,
                        fontWeight: AppTypography.semiBold,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md16,
                        vertical: AppSpacing.md16,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: AppColors.deepNavy,
                      fontSize: AppTypography.fontSize16,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg20),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(
                        color: AppColors.slateGrey.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColors.constructionGold,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.constructionGold,
                        ),
                        onPressed: () {
                          setState(() => _showPassword = !_showPassword);
                        },
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        borderSide: BorderSide(
                          color: AppColors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        borderSide: BorderSide(
                          color: AppColors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        borderSide: BorderSide(
                          color: AppColors.constructionGold,
                          width: 2,
                        ),
                      ),
                      labelStyle: TextStyle(
                        color: AppColors.constructionGold,
                        fontWeight: AppTypography.semiBold,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md16,
                        vertical: AppSpacing.md16,
                      ),
                    ),
                    obscureText: !_showPassword,
                    style: TextStyle(
                      color: AppColors.deepNavy,
                      fontSize: AppTypography.fontSize16,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg20 * 2),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.md16,
                        ),
                        backgroundColor: AppColors.constructionGold,
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.deepNavy,
                                ),
                              ),
                            )
                          : Text(
                              'Sign In',
                              style: TextStyle(
                                color: AppColors.deepNavy,
                                fontSize: AppTypography.fontSize16,
                                fontWeight: AppTypography.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md16),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: AppTypography.fontSize14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed('/signup');
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.constructionGold,
                            fontSize: AppTypography.fontSize14,
                            fontWeight: AppTypography.bold,
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
    );
  }
}
