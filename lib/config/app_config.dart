import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import '../services/index.dart';

/// Application configuration and service locator setup
class AppConfig {
  static AuthService? _authService;
  static TaskService? _taskService;
  static DprService? _dprService;
  static StorageService? _storageService;
  static NotificationService? _notificationService;
  static bool firebaseAvailable = false; // Track if Firebase is initialized

  /// Initialize Firebase and services
  static Future<void> initialize() async {
    debugPrint('🔄 AppConfig.initialize() starting...');

    // Initialize Firebase with configuration - do this on ALL platforms
    try {
      await Firebase.initializeApp(options: _getFirebaseOptions());
      firebaseAvailable = true;
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      firebaseAvailable = false;
      debugPrint('⚠️ Firebase initialization error: $e');
      debugPrint('⚠️ Running in demo mode without Firebase');
      // Continue even if Firebase fails - app will attempt demo mode
    }

    // Initialize services with individual error handling
    debugPrint('📦 Initializing services...');
    try {
      _authService = AuthService();
      debugPrint('✅ AuthService initialized');
    } catch (e) {
      debugPrint('⚠️ AuthService initialization failed: $e');
      // Initialize with fallback
      try {
        _authService = AuthService();
      } catch (e2) {
        debugPrint('⚠️ AuthService fallback initialization failed: $e2');
      }
    }

    try {
      _taskService = TaskService();
      debugPrint('✅ TaskService initialized');
    } catch (e) {
      debugPrint('⚠️ TaskService initialization failed: $e');
    }

    try {
      _dprService = DprService();
      debugPrint('✅ DprService initialized');
    } catch (e) {
      debugPrint('⚠️ DprService initialization failed: $e');
    }

    try {
      _storageService = StorageService();
      debugPrint('✅ StorageService initialized');
    } catch (e) {
      debugPrint('⚠️ StorageService initialization failed: $e');
    }

    try {
      _notificationService = NotificationService();
      debugPrint('✅ NotificationService initialized');
    } catch (e) {
      debugPrint('⚠️ NotificationService initialization failed: $e');
    }

    debugPrint('✅ Services initialization phase completed');

    // FCM: initialize when Firebase is up (includes web — was skipped before).
    if (firebaseAvailable) {
      try {
        debugPrint('Initializing notifications...');
        if (_notificationService != null) {
          await Future.wait([
            _notificationService!.initialize().timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                debugPrint('⚠️ Notification initialization timeout');
              },
            ),
          ]);
        }
      } catch (e) {
        debugPrint('Notification service async initialization warning: $e');
      }
    }

    // Enable Firestore offline persistence (with error handling) - skip on web
    if (!kIsWeb) {
      try {
        debugPrint('Enabling Firestore network...');
        await FirebaseFirestore.instance.enableNetwork().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('⚠️ Firestore network enable timeout');
          },
        );
      } catch (e) {
        debugPrint('Firestore network enable warning: $e');
      }
    }

    // Auth + FCM (subscribe + Firestore token) must run on web too when Firebase works.
    // Inner handlers still skip web-only noise (e.g. Firestore health listener).
    if (firebaseAvailable) {
      try {
        _setupErrorHandlers();
      } catch (e) {
        debugPrint('Error handlers setup warning: $e');
      }
    }

    debugPrint('✅ AppConfig.initialize() completed');
  }

  /// Check if services are properly initialized
  static bool get isInitialized => _authService != null;

  /// Get Firebase options based on platform
  static FirebaseOptions _getFirebaseOptions() {
    return DefaultFirebaseOptions.currentPlatform;
  }

  /// Get auth service
  static AuthService get authService {
    if (_authService == null) {
      throw Exception(
        'AuthService not initialized. Call AppConfig.initialize() first.',
      );
    }
    return _authService!;
  }

  /// Get task service
  static TaskService get taskService {
    if (_taskService == null) {
      throw Exception(
        'TaskService not initialized. Call AppConfig.initialize() first.',
      );
    }
    return _taskService!;
  }

  /// Get DPR service
  static DprService get dprService {
    if (_dprService == null) {
      throw Exception(
        'DprService not initialized. Call AppConfig.initialize() first.',
      );
    }
    return _dprService!;
  }

  /// Get storage service
  static StorageService get storageService {
    if (_storageService == null) {
      throw Exception(
        'StorageService not initialized. Call AppConfig.initialize() first.',
      );
    }
    return _storageService!;
  }

  /// Get notification service
  static NotificationService get notificationService {
    if (_notificationService == null) {
      throw Exception(
        'NotificationService not initialized. Call AppConfig.initialize() first.',
      );
    }
    return _notificationService!;
  }

  /// Setup error handlers
  static void _setupErrorHandlers() {
    // Firebase Auth: keep FCM topics + Firestore token in sync after login.
    try {
      if (firebaseAvailable) {
        FirebaseAuth.instance.userChanges().listen(
          (user) async {
            if (user == null) {
              debugPrint('User logged out');
              try {
                await _notificationService?.clearFcmTokenPersistence();
              } catch (e) {
                debugPrint('clearFcmTokenPersistence: $e');
              }
            } else {
              debugPrint('User logged in: ${user.email}');
              if (_notificationService != null) {
                try {
                  await _notificationService!.subscribeToTaskNotifications(
                    user.uid,
                  );
                  await _notificationService!.persistFcmTokenForUser(user.uid);
                } catch (e) {
                  debugPrint('FCM subscribe/token sync: $e');
                }
              }
            }
          },
          onError: (error) {
            debugPrint('Auth error: $error');
          },
        );
      }
    } catch (e) {
      debugPrint('Error setting up auth handler: $e');
    }

    // Handle Firestore errors (skip on web in demo mode)
    try {
      if (!kIsWeb && firebaseAvailable) {
        FirebaseFirestore.instance
            .collection('health')
            .doc('status')
            .snapshots()
            .listen(
              (doc) {
                debugPrint('Firestore health check: OK');
              },
              onError: (error) {
                debugPrint('Firestore error: $error');
              },
            );
      }
    } catch (e) {
      debugPrint('Error setting up Firestore handler: $e');
    }
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;

  /// Get current user ID
  static String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Get current user email
  static String? get currentUserEmail =>
      FirebaseAuth.instance.currentUser?.email;

  /// Enable offline persistence
  static Future<void> enableOfflinePersistence() async {
    try {
      await FirebaseFirestore.instance.enableNetwork();
    } catch (e) {
      debugPrint('Error enabling offline persistence: $e');
    }
  }

  /// Disable network to test offline functionality
  static Future<void> disableNetwork() async {
    try {
      await FirebaseFirestore.instance.disableNetwork();
    } catch (e) {
      debugPrint('Error disabling network: $e');
    }
  }
}
