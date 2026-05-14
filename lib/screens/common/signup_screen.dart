import 'package:flutter/material.dart';
import '../../config/index.dart';
import '../../models/index.dart';

/// Sign up screen for admin registration
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    // Validation
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Sign up as admin
      await AppConfig.authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: UserRole.admin,
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        company: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to login
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup failed: $e'),
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
                    'Join Sago Builders',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: AppTypography.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md16),

                  // Subtitle
                  Text(
                    'Create your admin account to get started',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg20),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      hintStyle: TextStyle(
                        color: AppColors.slateGrey.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
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
                    style: TextStyle(
                      color: AppColors.deepNavy,
                      fontSize: AppTypography.fontSize16,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md16),

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
                  SizedBox(height: AppSpacing.md16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password (min 6 characters)',
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
                  SizedBox(height: AppSpacing.md16),

                  // Confirm Password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      hintStyle: TextStyle(
                        color: AppColors.slateGrey.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColors.constructionGold,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.constructionGold,
                        ),
                        onPressed: () {
                          setState(
                            () => _showConfirmPassword = !_showConfirmPassword,
                          );
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
                    obscureText: !_showConfirmPassword,
                    style: TextStyle(
                      color: AppColors.deepNavy,
                      fontSize: AppTypography.fontSize16,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md16),

                  // Company field (optional)
                  TextFormField(
                    controller: _companyController,
                    decoration: InputDecoration(
                      labelText: 'Company Name (Optional)',
                      hintText: 'Enter your company name',
                      hintStyle: TextStyle(
                        color: AppColors.slateGrey.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.business_outlined,
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
                    style: TextStyle(
                      color: AppColors.deepNavy,
                      fontSize: AppTypography.fontSize16,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md16),

                  // Phone field (optional)
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number (Optional)',
                      hintText: 'Enter your phone number',
                      hintStyle: TextStyle(
                        color: AppColors.slateGrey.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.phone_outlined,
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
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      color: AppColors.deepNavy,
                      fontSize: AppTypography.fontSize16,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg20),

                  // Sign up button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleSignup,
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
                              'Sign Up',
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

                  // Sign in link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: AppTypography.fontSize14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        child: Text(
                          'Sign In',
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
