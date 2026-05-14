import 'package:flutter/material.dart';
import '../../config/index.dart';
import '../../models/index.dart';
import '../admin/dashboard_screen.dart';
import '../employee/employee_home_screen.dart';
import 'login_screen.dart';

/// Widget that handles authentication state and routing
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Stream<User?> _userStream;

  @override
  void initState() {
    super.initState();
    try {
      debugPrint('AuthWrapper initState: Creating user stream...');
      _userStream = _getUserStream();
      debugPrint('AuthWrapper initState: User stream created successfully');
    } catch (e) {
      debugPrint('AuthWrapper initState error: $e');
      // Create a fallback stream that shows login screen
      _userStream = Stream.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _userStream,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(gradient: AppColors.primaryGradient),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.constructionGold,
                  ),
                ),
              ),
            ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          debugPrint('AuthWrapper error: ${snapshot.error}');
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        // Check if user is authenticated
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          // Route to appropriate screen based on role
          if (user.role == UserRole.admin) {
            return const AdminDashboardScreen();
          } else {
            return const EmployeeHomeScreen();
          }
        }

        // No user - show login screen
        return const LoginScreen();
      },
    );
  }

  /// Stream to get current user
  Stream<User?> _getUserStream() {
    try {
      debugPrint('_getUserStream: Started');

      // Check if authService is available
      if (!AppConfig.isInitialized) {
        debugPrint(
          '_getUserStream: AppConfig not initialized, returning login screen',
        );
        return Stream.value(null);
      }

      if (!AppConfig.firebaseAvailable) {
        debugPrint(
          '_getUserStream: Firebase not available, showing login screen',
        );
        return Stream.value(null);
      }

      debugPrint('_getUserStream: Getting auth state changes...');
      return AppConfig.authService.authStateChanges
          .asyncMap((firebaseUser) async {
            debugPrint('_getUserStream: Firebase user: $firebaseUser');
            if (firebaseUser == null) {
              return null;
            }

            // Fetch user profile from Firestore
            try {
              final userProfile = await AppConfig.authService.getUserProfile(
                firebaseUser.uid,
              );
              debugPrint(
                '_getUserStream: Got user profile: ${userProfile?.name}',
              );
              return userProfile;
            } catch (e) {
              debugPrint('_getUserStream: Error fetching user profile: $e');
              return null;
            }
          })
          .handleError((error) {
            debugPrint('_getUserStream: Stream error: $error');
            return null;
          });
    } catch (e) {
      debugPrint('_getUserStream: Outer catch error: $e');
      // Return a stream that emits null (show login screen)
      return Stream.value(null);
    }
  }
}
