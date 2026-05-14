import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/index.dart';

/// Firebase Authentication service
class AuthService {
  static const String usersCollection = 'users';

  firebase_auth.FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  AuthService() {
    _initializeFirebase();
  }

  /// Initialize Firebase instances
  void _initializeFirebase() {
    try {
      _auth = firebase_auth.FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      debugPrint('✅ AuthService Firebase instances initialized');
    } catch (e) {
      debugPrint('⚠️ AuthService Firebase initialization failed: $e');
      _auth = null;
      _firestore = null;
    }
  }

  /// Check if Firebase is initialized
  bool get isFirebaseInitialized => _auth != null && _firestore != null;

  /// Get Firebase Auth instance, reinitialize if needed
  firebase_auth.FirebaseAuth? get auth {
    if (_auth == null) {
      try {
        // Attempt to get Firebase Auth instance
        _auth = firebase_auth.FirebaseAuth.instance;
        debugPrint('✅ Firebase Auth instance obtained');
      } catch (e) {
        // Firebase Auth is not available - silently return null
        // This is expected when Firebase is not initialized
        return null;
      }
    }
    return _auth;
  }

  /// Get Firestore instance, reinitialize if needed
  FirebaseFirestore? get firestore {
    if (_firestore == null) {
      try {
        _firestore = FirebaseFirestore.instance;
        debugPrint('✅ Firestore instance obtained');
      } catch (e) {
        // Firestore is not available - silently return null
        // This is expected when Firebase is not initialized
        return null;
      }
    }
    return _firestore;
  }

  /// Get current user stream
  Stream<firebase_auth.User?> get authStateChanges {
    try {
      if (auth == null) {
        // Firebase not initialized - return empty stream (no user logged in)
        debugPrint('authStateChanges: Firebase Auth is not initialized');
        return Stream.value(null);
      }
      return auth!.authStateChanges();
    } catch (e) {
      // Firebase not initialized - return empty stream (no user logged in)
      debugPrint('authStateChanges error (Firebase not initialized): $e');
      return Stream.value(null);
    }
  }

  /// Get current user
  firebase_auth.User? get currentUser {
    try {
      if (auth == null) return null;
      return auth!.currentUser;
    } catch (e) {
      debugPrint('Error getting currentUser: $e');
      return null;
    }
  }

  /// Get current user's UID
  String? get currentUserId {
    try {
      if (auth == null) return null;
      return auth!.currentUser?.uid;
    } catch (e) {
      debugPrint('Error getting currentUserId: $e');
      return null;
    }
  }

  /// Sign up with email and password
  Future<firebase_auth.UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phoneNumber,
    String? company,
  }) async {
    try {
      if (auth == null) {
        throw Exception('Firebase Auth is not available');
      }

      final userCredential = await auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final appUser = User(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        role: role,
        company: company,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        assignedSites: [],
      );

      if (firestore != null) {
        await firestore!
            .collection(usersCollection)
            .doc(userCredential.user!.uid)
            .set(appUser.toJson());
      }

      return userCredential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Create an employee account without logging out the current admin.
  /// Uses a secondary Firebase app instance so the admin session is preserved.
  Future<void> createEmployee({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    String? designation,
    String? company,
  }) async {
    if (auth == null || firestore == null) {
      throw Exception('Firebase is not available');
    }

    // Use a secondary app so we don't sign out the current admin
    firebase_auth.FirebaseAuth? secondaryAuth;
    FirebaseApp? secondaryApp;
    firebase_auth.UserCredential? cred;

    try {
      // Initialize secondary Firebase app
      secondaryApp = await Firebase.initializeApp(
        name: 'secondary_employee_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      secondaryAuth = firebase_auth.FirebaseAuth.instanceFor(app: secondaryApp);

      // Create Firebase Auth user
      cred = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;
      debugPrint('✅ Firebase Auth user created: $uid');

      // Create user document in Firestore
      final employee = User(
        id: uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        role: UserRole.employee,
        designation: designation,
        company: company,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        assignedSites: [],
        isActive: true,
      );

      try {
        await firestore!
            .collection(usersCollection)
            .doc(uid)
            .set(employee.toJson());
        debugPrint('✅ Employee document created in Firestore: $uid');
      } catch (firestoreError) {
        debugPrint('❌ Failed to create employee document: $firestoreError');
        // If Firestore write fails, delete the Firebase Auth user we just created
        try {
          await secondaryAuth.currentUser?.delete();
          debugPrint('✅ Deleted Firebase Auth user due to Firestore failure');
        } catch (deleteError) {
          debugPrint('❌ Failed to delete Firebase Auth user: $deleteError');
        }
        throw Exception('Failed to create employee profile: $firestoreError');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth error: ${e.code}');
      throw Exception(_handleAuthException(e));
    } catch (e) {
      debugPrint('❌ Unexpected error creating employee: $e');
      throw Exception('Failed to create employee: $e');
    } finally {
      // Clean up secondary auth
      try {
        await secondaryAuth?.signOut();
        await secondaryApp?.delete();
        debugPrint('✅ Secondary Firebase app cleaned up');
      } catch (cleanupError) {
        debugPrint('⚠️ Error during cleanup: $cleanupError');
      }
    }
  }

  /// Sign in with email and password
  Future<firebase_auth.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (auth == null) {
        throw Exception('Firebase Auth is not available');
      }

      final userCredential = await auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login
      if (firestore != null) {
        await firestore!
            .collection(usersCollection)
            .doc(userCredential.user!.uid)
            .update({'lastLoginAt': Timestamp.now()})
            .catchError((e) => debugPrint('Could not update lastLoginAt: $e'));
      }

      return userCredential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on Exception catch (e) {
      // Handle web/development mode where Firebase isn't initialized
      if (e.toString().contains('No Firebase App') ||
          e.toString().contains('FirebaseApp')) {
        throw Exception(
          'Authentication service not available. Running in demo mode.',
        );
      }
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      if (auth == null) {
        throw Exception('Firebase Auth is not available');
      }
      await auth!.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Converts Firestore Timestamp fields to ISO-8601 strings so that
  /// the json_serializable-generated [User.fromJson] can parse them.
  Map<String, dynamic> _normalizeFirestoreData(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) {
        return MapEntry(key, value.toDate().toIso8601String());
      }
      return MapEntry(key, value);
    });
  }

  /// Get user profile by ID
  Future<User?> getUserProfile(String userId) async {
    try {
      if (firestore == null) return null;

      final doc = await firestore!
          .collection(usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      final data = _normalizeFirestoreData(doc.data()!);
      // Remove empty id field to avoid conflicts
      data.remove('id');
      return User.fromJson({...data, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      if (firestore == null) return;

      data['updatedAt'] = Timestamp.now();
      await firestore!.collection(usersCollection).doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Get users by role
  Future<List<User>> getUsersByRole(UserRole role) async {
    try {
      if (firestore == null) return [];

      final snapshot = await firestore!
          .collection(usersCollection)
          .where('role', isEqualTo: role.toShortString())
          .get();

      return snapshot.docs.map((doc) {
        final data = _normalizeFirestoreData(doc.data());
        // Remove empty id field to avoid conflicts
        data.remove('id');
        return User.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Get employees for a site
  Future<List<User>> getEmployeesForSite(String siteId) async {
    try {
      if (firestore == null) return [];

      final snapshot = await firestore!
          .collection(usersCollection)
          .where('assignedSites', arrayContains: siteId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = _normalizeFirestoreData(doc.data());
        // Remove empty id field to avoid conflicts
        data.remove('id');
        return User.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch employees: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (auth == null) {
        throw Exception('Firebase Auth is not available');
      }
      await auth!.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      if (auth == null) {
        throw Exception('Firebase Auth is not available');
      }
      await auth!.currentUser?.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Delete user account
  Future<void> deleteUserAccount(String userId) async {
    try {
      // Delete Firestore document
      if (firestore != null) {
        await firestore!.collection(usersCollection).doc(userId).delete();
      }

      // Delete Firebase Auth user
      if (auth != null) {
        await auth!.currentUser?.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete user account: $e');
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-credential':
        return 'The supplied auth credential is invalid.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}

/// Extension for UserRole enum
extension UserRoleExtension on UserRole {
  String toShortString() {
    return toString().split('.').last;
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.toString().split('.').last == value.replaceAll('_', ''),
      orElse: () => UserRole.employee,
    );
  }
}
