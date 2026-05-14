/// Application constants and configuration
class AppConstants {
  // API endpoints
  static const String apiBaseUrl = 'https://api.example.com';

  // Route names
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String taskDetailsRoute = '/task-details';
  static const String createTaskRoute = '/create-task';
  static const String dprFormRoute = '/dpr';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';
  static const String dprCollection = 'dpr';

  // Task related
  static const int maxImageAttachments = 10;
  static const int maxImageSizeMB = 10;
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'gif',
  ];

  // Location services
  static const double locationAccuracy = 100.0; // meters
  static const int locationUpdateIntervalSeconds = 30;

  // Pagination
  static const int pageSize = 20;
  static const int maxTasksPerPage = 50;
  static const int maxDprsPerPage = 30;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);
  static const Duration syncTimeout = Duration(seconds: 10);

  // Cache duration
  static const Duration userCacheDuration = Duration(hours: 1);
  static const Duration tasksCacheDuration = Duration(minutes: 15);
  static const Duration dprsNoCacheDuration = Duration(
    seconds: 0,
  ); // Always fetch fresh

  // Default values
  static const double defaultLocationLatitude = 0.0;
  static const double defaultLocationLongitude = 0.0;
  static const String defaultCurrency = 'INR';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 1000;

  // Features
  static const bool enableOfflineMode = true;
  static const bool enableImageCompression = true;
  static const bool enablePushNotifications = true;
  static const bool enableLocationTracking = false; // Requires user permission
}

/// Date and time formatting constants
class DateTimeConstants {
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd/MM/yyyy hh:mm a';
  static const String isoDateFormat = 'yyyy-MM-dd';

  // Time zone
  static const String defaultTimeZone = 'Asia/Kolkata'; // For Indian projects
}

/// Error messages
class ErrorMessages {
  static const String networkError =
      'Network error. Please check your internet connection.';
  static const String firebaseError = 'An error occurred with Firebase.';
  static const String authenticationError =
      'Authentication failed. Please try again.';
  static const String authorizationError =
      'You do not have permission to perform this action.';
  static const String notFoundError = 'The requested resource was not found.';
  static const String invalidInput = 'Invalid input provided.';
  static const String fileUploadError = 'File upload failed.';
  static const String locationError =
      'Failed to get location. Please enable location services.';
  static const String cameraError = 'Failed to access camera.';
}

/// Success messages
class SuccessMessages {
  static const String taskCreated = 'Task created successfully.';
  static const String taskUpdated = 'Task updated successfully.';
  static const String taskDeleted = 'Task deleted successfully.';
  static const String dprSubmitted =
      'Daily Progress Report submitted successfully.';
  static const String dprApproved = 'Daily Progress Report approved.';
  static const String profileUpdated = 'Profile updated successfully.';
  static const String imageUploaded = 'Image uploaded successfully.';
  static const String passwordChanged = 'Password changed successfully.';
}

/// Loading messages
class LoadingMessages {
  static const String loading = 'Loading...';
  static const String uploading = 'Uploading...';
  static const String savingData = 'Saving data...';
  static const String fetchingData = 'Fetching data...';
  static const String authenticating = 'Authenticating...';
}
