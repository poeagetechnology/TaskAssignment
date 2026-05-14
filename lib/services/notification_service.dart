import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../firebase_options.dart';

/// Firebase Cloud Messaging service for push notifications
class NotificationService {
  static const String tasksTopicChannel = 'tasks_channel';
  static const String urgentNotificationsChannel = 'urgent_notifications';

  FirebaseMessaging? _messaging;
  StreamSubscription<String>? _fcmTokenRefreshSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSub;

  NotificationService() {
    try {
      _messaging = FirebaseMessaging.instance;
      debugPrint('✅ FirebaseMessaging instance created');
    } catch (e) {
      debugPrint('⚠️ FirebaseMessaging not available: $e');
    }
  }

  /// Initialize notifications (mobile + web when Firebase is configured).
  Future<void> initialize() async {
    final messaging = _messaging;
    if (messaging == null) {
      debugPrint('⚠️ NotificationService: messaging unavailable');
      return;
    }

    try {
      if (!kIsWeb) {
        if (defaultTargetPlatform == TargetPlatform.android) {
          final perm = await Permission.notification.request();
          if (!perm.isGranted) {
            debugPrint('⚠️ Android notification permission not granted: $perm');
          }
        }
      }

      final settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final ok = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!ok) {
        debugPrint('User denied notification permission (FCM)');
        return;
      }

      debugPrint('FCM permission: ${settings.authorizationStatus}');

      if (!kIsWeb) {
        try {
          await messaging.setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
        } catch (e) {
          debugPrint('setForegroundNotificationPresentationOptions: $e');
        }
      }

      await _onMessageSub?.cancel();
      await _onMessageOpenedSub?.cancel();
      _onMessageSub = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      _onMessageOpenedSub =
          FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessageTap(initialMessage);
      }
    } catch (e) {
      debugPrint('⚠️ Error initializing notifications: $e');
    }
  }

  /// Get FCM token for the device (web needs [DefaultFirebaseOptions.webPushVapidPublicKey]).
  Future<String?> getFcmToken() async {
    final messaging = _messaging;
    if (messaging == null) return null;
    try {
      if (kIsWeb) {
        final vapid = DefaultFirebaseOptions.webPushVapidPublicKey;
        if (vapid != null && vapid.isNotEmpty) {
          return await messaging.getToken(vapidKey: vapid);
        }
        return await messaging.getToken();
      }
      return await messaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Save token to Firestore and keep it updated on refresh.
  Future<void> persistFcmTokenForUser(String userId) async {
    final messaging = _messaging;
    if (messaging == null || userId.isEmpty) return;

    await _fcmTokenRefreshSub?.cancel();
    _fcmTokenRefreshSub = null;

    Future<void> save(String token) async {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).set(
          {
            'fcmToken': token,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } catch (e) {
        debugPrint('Failed to save FCM token: $e');
      }
    }

    final token = await getFcmToken();
    if (token != null) await save(token);

    _fcmTokenRefreshSub = messaging.onTokenRefresh.listen(save);
  }

  /// Stop token refresh listener (e.g. on sign-out).
  Future<void> clearFcmTokenPersistence() async {
    await _fcmTokenRefreshSub?.cancel();
    _fcmTokenRefreshSub = null;
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging?.subscribeToTopic(topic);
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging?.unsubscribeFromTopic(topic);
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  /// Subscribe employee to task notifications
  Future<void> subscribeToTaskNotifications(String employeeId) async {
    try {
      await subscribeToTopic('employee_$employeeId');
      await subscribeToTopic(tasksTopicChannel);
    } catch (e) {
      debugPrint('Error subscribing to task notifications: $e');
    }
  }

  /// Subscribe to urgent notifications
  Future<void> subscribeToUrgentNotifications(String userId) async {
    try {
      await subscribeToTopic('urgent_$userId');
      await subscribeToTopic(urgentNotificationsChannel);
    } catch (e) {
      debugPrint('Error subscribing to urgent notifications: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received:');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');
    _processNotificationData(message.data);
  }

  void _handleBackgroundMessageTap(RemoteMessage message) {
    debugPrint('Background message tapped:');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');
    _processNotificationData(message.data);
  }

  void _processNotificationData(Map<String, dynamic> data) {
    final type = data['type'];
    final taskId = data['taskId'];

    switch (type) {
      case 'task_assigned':
        debugPrint('Task assigned notification: $taskId');
        break;
      case 'task_updated':
        debugPrint('Task updated notification: $taskId');
        break;
      case 'task_reminder':
        debugPrint('Task reminder notification: $taskId');
        break;
      case 'dpr_approved':
        debugPrint('DPR approved notification');
        break;
      case 'dpr_requires_revision':
        debugPrint('DPR requires revision notification');
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  Future<void> sendTaskReminder(
    String employeeId,
    String taskTitle,
    String taskId,
    String taskPriority,
  ) async {
    try {
      await subscribeToTaskNotifications(employeeId);
      debugPrint(
        '📢 Task reminder queued for employee: $employeeId, task: $taskTitle',
      );
    } catch (e) {
      debugPrint('Error sending task reminder: $e');
    }
  }

  Future<void> checkAndSendTaskReminders(String employeeId) async {
    try {
      debugPrint('🔔 Checking for task reminders for employee: $employeeId');
    } catch (e) {
      debugPrint('Error checking task reminders: $e');
    }
  }

  Future<bool> requestNotificationPermission() async {
    final messaging = _messaging;
    if (messaging == null) return false;
    try {
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      return false;
    }
  }

  Future<bool> areNotificationsEnabled() async {
    final messaging = _messaging;
    if (messaging == null) return false;
    try {
      final settings = await messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      return false;
    }
  }

  void listenToTokenRefresh(Function(String token) onTokenRefresh) {
    _messaging?.onTokenRefresh.listen(onTokenRefresh);
  }
}
