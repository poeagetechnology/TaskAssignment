import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/index.dart';

/// Service for managing task reminders for unstarted tasks
class TaskReminderService {
  static const String remindersCollection = 'task_reminders';
  static const int reminderIntervalHours = 24; // Send reminder every 24 hours

  late FirebaseFirestore _firestore;

  TaskReminderService() {
    try {
      _firestore = FirebaseFirestore.instance;
      debugPrint('✅ Firestore instance created for TaskReminderService');
    } catch (e) {
      debugPrint('⚠️ Firestore not available in TaskReminderService: $e');
    }
  }

  /// Check for pending tasks that need reminders
  /// Returns list of tasks that need reminders
  Future<List<Task>> getTasksNeedingReminders(String employeeId) async {
    try {
      debugPrint(
        '🔍 Checking for pending tasks needing reminders for: $employeeId',
      );

      // Get all pending tasks for the employee
      final tasksSnapshot = await _firestore
          .collection('tasks')
          .where('assignedTo', isEqualTo: employeeId)
          .where('status', isEqualTo: 'pending')
          .get();

      debugPrint('📊 Found ${tasksSnapshot.docs.length} pending tasks');

      final tasksNeedingReminders = <Task>[];
      final now = DateTime.now();

      for (final doc in tasksSnapshot.docs) {
        try {
          final data = doc.data();
          final task = Task.fromJson({...data, 'id': doc.id});

          // Check if this task has already been reminded in the last reminderIntervalHours
          final lastReminderTime = await _getLastReminderTime(
            task.id,
            employeeId,
          );

          if (lastReminderTime == null) {
            // Never reminded before
            debugPrint(
              '⏰ Task ${task.id} - Never reminded before, needs reminder',
            );
            tasksNeedingReminders.add(task);
          } else {
            // Check if enough time has passed since last reminder
            final timeSinceLastReminder = now.difference(lastReminderTime);
            if (timeSinceLastReminder.inHours >= reminderIntervalHours) {
              debugPrint(
                '⏰ Task ${task.id} - ${timeSinceLastReminder.inHours} hours since last reminder, needs reminder',
              );
              tasksNeedingReminders.add(task);
            } else {
              final hoursUntilNextReminder =
                  reminderIntervalHours - timeSinceLastReminder.inHours;
              debugPrint(
                '⏳ Task ${task.id} - Next reminder in $hoursUntilNextReminder hours',
              );
            }
          }
        } catch (e) {
          debugPrint('❌ Error processing task ${doc.id}: $e');
        }
      }

      debugPrint('📬 ${tasksNeedingReminders.length} tasks need reminders');
      return tasksNeedingReminders;
    } catch (e) {
      debugPrint('❌ Error checking tasks for reminders: $e');
      return [];
    }
  }

  /// Get the last time a reminder was sent for a task
  Future<DateTime?> _getLastReminderTime(
    String taskId,
    String employeeId,
  ) async {
    try {
      final doc = await _firestore
          .collection(remindersCollection)
          .doc('${taskId}_$employeeId')
          .get();

      if (doc.exists) {
        final timestamp = doc.data()?['lastReminderTime'] as Timestamp?;
        return timestamp?.toDate();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting last reminder time: $e');
      return null;
    }
  }

  /// Record that a reminder was sent for a task
  Future<void> recordReminderSent(
    String taskId,
    String employeeId,
    String employeeName,
  ) async {
    try {
      debugPrint(
        '💾 Saving reminder record for task: $taskId, employee: $employeeId',
      );
      await _firestore
          .collection(remindersCollection)
          .doc('${taskId}_$employeeId')
          .set({
            'taskId': taskId,
            'employeeId': employeeId,
            'employeeName': employeeName,
            'lastReminderTime': FieldValue.serverTimestamp(),
            'reminderCount': FieldValue.increment(1),
          }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error recording reminder: $e');
    }
  }

  /// Get reminder statistics for a task
  Future<Map<String, dynamic>?> getReminderStats(
    String taskId,
    String employeeId,
  ) async {
    try {
      final doc = await _firestore
          .collection(remindersCollection)
          .doc('${taskId}_$employeeId')
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting reminder stats: $e');
      return null;
    }
  }

  /// Get all pending tasks by task ID (for admin to see who needs reminders)
  Future<List<Map<String, dynamic>>> getPendingTasksWithReminderInfo(
    String taskId,
  ) async {
    try {
      final taskSnapshot = await _firestore
          .collection('tasks')
          .doc(taskId)
          .get();

      if (!taskSnapshot.exists) {
        return [];
      }

      final task = Task.fromJson({...taskSnapshot.data()!, 'id': taskId});
      final employeeId = task.assignedTo;

      // Get reminder info for this employee
      final reminderStats = await getReminderStats(taskId, employeeId);

      return [
        {
          'taskId': taskId,
          'employeeId': employeeId,
          'taskTitle': task.title,
          'taskStatus': task.status.toString().split('.').last,
          'reminderCount': reminderStats?['reminderCount'] ?? 0,
          'lastReminderTime': reminderStats?['lastReminderTime']?.toDate(),
          'createdAt': task.createdAt,
          'needsReminder': task.status == TaskStatus.pending,
        },
      ];
    } catch (e) {
      debugPrint('Error getting pending tasks with reminder info: $e');
      return [];
    }
  }

  /// Clear reminders for a task when it starts
  Future<void> clearRemindersForTask(String taskId, String employeeId) async {
    try {
      debugPrint('🧹 Clearing reminders for task: $taskId');
      await _firestore
          .collection(remindersCollection)
          .doc('${taskId}_$employeeId')
          .delete();
    } catch (e) {
      debugPrint('Warning: Error clearing reminders: $e');
    }
  }
}
