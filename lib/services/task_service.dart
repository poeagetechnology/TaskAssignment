import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/index.dart';
import 'task_reminder_service.dart';

/// Firebase Firestore service for task operations
class TaskService {
  static const String tasksCollection = 'tasks';

  late FirebaseFirestore _firestore;

  TaskService() {
    try {
      // Always initialize instance
      _firestore = FirebaseFirestore.instance;
      debugPrint('✅ Firestore instance created for TaskService');
    } catch (e) {
      debugPrint('⚠️ Firestore not available in TaskService: $e');
    }
  }

  /// Recursively converts Firestore Timestamp fields to ISO-8601 strings.
  Map<String, dynamic> _normalizeFirestoreData(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) {
        return MapEntry(key, value.toDate().toIso8601String());
      } else if (value is Map<String, dynamic>) {
        return MapEntry(key, _normalizeFirestoreData(value));
      } else if (value is List) {
        return MapEntry(
          key,
          value.map((e) {
            if (e is Map<String, dynamic>) return _normalizeFirestoreData(e);
            if (e is Timestamp) return e.toDate().toIso8601String();
            return e;
          }).toList(),
        );
      }
      return MapEntry(key, value);
    });
  }

  /// Recursively converts DateTime objects to Firestore Timestamp objects for storage.
  /// This ensures dates in nested structures (like comments and reactions) are properly stored.
  Map<String, dynamic> _convertDatesToTimestamps(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is DateTime) {
        return MapEntry(key, Timestamp.fromDate(value));
      } else if (value is Map<String, dynamic>) {
        return MapEntry(key, _convertDatesToTimestamps(value));
      } else if (value is List) {
        return MapEntry(
          key,
          value.map((e) {
            if (e is Map<String, dynamic>) return _convertDatesToTimestamps(e);
            if (e is DateTime) return Timestamp.fromDate(e);
            return e;
          }).toList(),
        );
      }
      return MapEntry(key, value);
    });
  }

  /// Create a new task
  Future<String> createTask(Task task) async {
    try {
      final json = task.toJson();
      // Remove id field - Firestore generates this
      json.remove('id');
      // Store dates as Firestore Timestamps for correct querying
      json['createdAt'] = Timestamp.fromDate(task.createdAt);
      json['updatedAt'] = Timestamp.fromDate(task.updatedAt);
      json['deadline'] = Timestamp.fromDate(task.deadline);
      debugPrint('💾 Creating task:');
      debugPrint('   - title=${json['title']}');
      debugPrint('   - assignedTo=${json['assignedTo']}');
      debugPrint('   - assignedBy=${json['assignedBy']}');
      final docRef = await _firestore.collection(tasksCollection).add(json);
      debugPrint(
        '✅ Task created with ID: ${docRef.id} and assignedTo: ${json['assignedTo']}',
      );
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Failed to create task: $e');
      throw Exception('Failed to create task: $e');
    }
  }

  /// Get task by ID
  Future<Task?> getTaskById(String taskId) async {
    try {
      final doc = await _firestore
          .collection(tasksCollection)
          .doc(taskId)
          .get();

      if (!doc.exists) return null;

      final data = _normalizeFirestoreData(doc.data() as Map<String, dynamic>);
      // Remove empty id field to avoid conflicts
      data.remove('id');
      return Task.fromJson({...data, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to fetch task: $e');
    }
  }

  /// Get all tasks (admin use)
  Stream<List<Task>> getAllTasks() {
    return _firestore
        .collection(tasksCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          debugPrint('📊 getAllTasks: Found ${snapshot.docs.length} documents');
          final tasks = <Task>[];
          for (final doc in snapshot.docs) {
            try {
              final data = _normalizeFirestoreData(doc.data());
              // Remove the empty id field to prevent conflicts
              data.remove('id');
              // Use doc.id from Firestore document reference
              final taskJson = {'id': doc.id, ...data};
              debugPrint(
                '📥 Parsing task: docId=${doc.id}, title=${taskJson['title']}',
              );
              final task = Task.fromJson(taskJson);
              debugPrint(
                '✅ Task created successfully: id=${task.id}, title=${task.title}',
              );
              tasks.add(task);
            } catch (e) {
              debugPrint('❌ Error parsing task from doc ${doc.id}: $e');
            }
          }
          debugPrint('📦 Returning ${tasks.length} tasks from getAllTasks');
          return tasks;
        });
  }

  /// Get all tasks assigned to an employee
  Stream<List<Task>> getTasksForEmployee(String employeeId) {
    debugPrint('🔍 getTasksForEmployee called for: $employeeId');
    return _firestore
        .collection(tasksCollection)
        .where('assignedTo', isEqualTo: employeeId)
        .snapshots()
        .map((snapshot) {
          debugPrint(
            '📊 getTasksForEmployee: Found ${snapshot.docs.length} documents for employeeId=$employeeId',
          );
          final tasks = <Task>[];
          for (final doc in snapshot.docs) {
            try {
              final data = _normalizeFirestoreData(doc.data());
              debugPrint(
                '📥 Raw Firestore data: assignedTo=${data['assignedTo']}, title=${data['title']}',
              );
              // Remove empty id field to avoid conflicts
              data.remove('id');
              // Correct order: spread data first, then override with doc.id
              final taskJson = {...data, 'id': doc.id};
              debugPrint(
                '📥 Task JSON: docId=${doc.id}, assignedTo=${taskJson['assignedTo']}, title=${taskJson['title']}',
              );
              final task = Task.fromJson(taskJson);
              debugPrint('📦 Task created: id=${task.id}, title=${task.title}');
              tasks.add(task);
            } catch (e) {
              debugPrint('❌ Error parsing task from doc ${doc.id}: $e');
            }
          }
          debugPrint(
            '📦 Returning ${tasks.length} tasks from getTasksForEmployee',
          );
          return tasks;
        });
  }

  /// Get all tasks created by an admin
  Stream<List<Task>> getTasksByAdmin(String adminId) {
    return _firestore
        .collection(tasksCollection)
        .where('assignedBy', isEqualTo: adminId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = _normalizeFirestoreData(doc.data());
            // Remove empty id field to avoid conflicts
            data.remove('id');
            return Task.fromJson({...data, 'id': doc.id});
          }).toList();
        });
  }

  /// Get tasks by status
  Stream<List<Task>> getTasksByStatus(TaskStatus status) {
    return _firestore
        .collection(tasksCollection)
        .where('status', isEqualTo: status.toShortString())
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = _normalizeFirestoreData(doc.data());
            // Remove empty id field to avoid conflicts
            data.remove('id');
            return Task.fromJson({...data, 'id': doc.id});
          }).toList();
        });
  }

  /// Update task
  Future<void> updateTask(String taskId, Task task) async {
    try {
      await _firestore
          .collection(tasksCollection)
          .doc(taskId)
          .update(task.toJson());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  /// Update task status
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    if (taskId.isEmpty) {
      throw Exception(
        'Cannot update task: Task ID is empty. This is a data integrity issue.',
      );
    }

    try {
      debugPrint(
        '🔄 Updating task $taskId to status ${status.toShortString()}',
      );
      await _firestore.collection(tasksCollection).doc(taskId).update({
        'status': status.toShortString(),
        'updatedAt': Timestamp.now(),
      });
      debugPrint('✅ Task $taskId updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating task $taskId: $e');
      throw Exception('Failed to update task status: $e');
    }
  }

  /// Delete task
  Future<void> deleteTask(String taskId) async {
    debugPrint(
      '🗑️ deleteTask called with ID: "$taskId" (isEmpty: ${taskId.isEmpty})',
    );

    if (taskId.isEmpty) {
      debugPrint('❌ Cannot delete: Task ID is empty or null');
      throw Exception('Cannot delete task: Task ID is empty.');
    }

    try {
      debugPrint('🗑️ Attempting to delete task: $taskId');
      await _firestore.collection(tasksCollection).doc(taskId).delete();
      debugPrint('✅ Task $taskId deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting task $taskId: $e');
      throw Exception('Failed to delete task: $e');
    }
  }

  /// Add image attachment to task
  Future<void> addImageAttachment(String taskId, ImageAttachment image) async {
    try {
      await _firestore.collection(tasksCollection).doc(taskId).update({
        'imageAttachments': FieldValue.arrayUnion([image.toJson()]),
      });
    } catch (e) {
      throw Exception('Failed to add image attachment: $e');
    }
  }

  /// Add comment to task
  Future<void> addTaskComment(String taskId, TaskComment comment) async {
    if (taskId.isEmpty) {
      throw Exception('Cannot add comment: Task ID is empty.');
    }

    try {
      debugPrint('💬 Adding comment to task $taskId');
      final commentJson = comment.toJson();
      // Convert DateTime objects to Firestore Timestamps for nested structures
      final commentWithTimestamps = _convertDatesToTimestamps(commentJson);

      await _firestore.collection(tasksCollection).doc(taskId).update({
        'comments': FieldValue.arrayUnion([commentWithTimestamps]),
        'updatedAt': Timestamp.now(),
      });
      debugPrint('✅ Comment added successfully');
    } catch (e) {
      debugPrint('❌ Error adding comment: $e');
      throw Exception('Failed to add comment: $e');
    }
  }

  /// Add reply to a comment
  Future<void> addCommentReply(
    String taskId,
    String commentId,
    CommentReply reply,
  ) async {
    if (taskId.isEmpty || commentId.isEmpty) {
      throw Exception('Cannot add reply: Task ID or Comment ID is empty.');
    }

    try {
      debugPrint('💬 Adding reply to comment $commentId in task $taskId');
      final taskDoc = await _firestore
          .collection(tasksCollection)
          .doc(taskId)
          .get();
      final data = _normalizeFirestoreData(
        taskDoc.data() as Map<String, dynamic>,
      );
      // Remove empty id field to avoid conflicts
      data.remove('id');
      final task = Task.fromJson({...data, 'id': taskDoc.id});

      final updatedComments = task.comments.map((comment) {
        if (comment.id == commentId) {
          return comment.copyWithReply(reply);
        }
        return comment;
      }).toList();

      final commentsJson = updatedComments.map((c) => c.toJson()).toList();
      // Convert DateTime objects to Firestore Timestamps for nested structures
      final commentsWithTimestamps = commentsJson
          .map((c) => _convertDatesToTimestamps(c))
          .toList();

      await _firestore.collection(tasksCollection).doc(taskId).update({
        'comments': commentsWithTimestamps,
        'updatedAt': Timestamp.now(),
      });
      debugPrint('✅ Reply added successfully');
    } catch (e) {
      debugPrint('❌ Error adding reply: $e');
      throw Exception('Failed to add reply: $e');
    }
  }

  /// Add reaction to a comment
  Future<void> addCommentReaction(
    String taskId,
    String commentId,
    CommentReaction reaction,
  ) async {
    if (taskId.isEmpty || commentId.isEmpty) {
      throw Exception('Cannot add reaction: Task ID or Comment ID is empty.');
    }

    try {
      debugPrint('😊 Adding reaction to comment $commentId in task $taskId');
      final taskDoc = await _firestore
          .collection(tasksCollection)
          .doc(taskId)
          .get();
      final data = _normalizeFirestoreData(
        taskDoc.data() as Map<String, dynamic>,
      );
      // Remove empty id field to avoid conflicts
      data.remove('id');
      final task = Task.fromJson({...data, 'id': taskDoc.id});

      final updatedComments = task.comments.map((comment) {
        if (comment.id == commentId) {
          return comment.copyWithReaction(reaction);
        }
        return comment;
      }).toList();

      final commentsJson = updatedComments.map((c) => c.toJson()).toList();
      // Convert DateTime objects to Firestore Timestamps for nested structures
      final commentsWithTimestamps = commentsJson
          .map((c) => _convertDatesToTimestamps(c))
          .toList();

      await _firestore.collection(tasksCollection).doc(taskId).update({
        'comments': commentsWithTimestamps,
        'updatedAt': Timestamp.now(),
      });
      debugPrint('✅ Reaction added successfully');
    } catch (e) {
      debugPrint('❌ Error adding reaction: $e');
      throw Exception('Failed to add reaction: $e');
    }
  }

  /// Remove reaction from a comment
  Future<void> removeCommentReaction(
    String taskId,
    String commentId,
    String emoji,
    String userId,
  ) async {
    if (taskId.isEmpty || commentId.isEmpty) {
      throw Exception(
        'Cannot remove reaction: Task ID or Comment ID is empty.',
      );
    }

    try {
      debugPrint('Removing reaction from comment $commentId in task $taskId');
      final taskDoc = await _firestore
          .collection(tasksCollection)
          .doc(taskId)
          .get();
      final data = _normalizeFirestoreData(
        taskDoc.data() as Map<String, dynamic>,
      );
      // Remove empty id field to avoid conflicts
      data.remove('id');
      final task = Task.fromJson({...data, 'id': taskDoc.id});

      final updatedComments = task.comments.map((comment) {
        if (comment.id == commentId) {
          return comment.removeReaction(emoji, userId);
        }
        return comment;
      }).toList();

      final commentsJson = updatedComments.map((c) => c.toJson()).toList();
      // Convert DateTime objects to Firestore Timestamps for nested structures
      final commentsWithTimestamps = commentsJson
          .map((c) => _convertDatesToTimestamps(c))
          .toList();

      await _firestore.collection(tasksCollection).doc(taskId).update({
        'comments': commentsWithTimestamps,
        'updatedAt': Timestamp.now(),
      });
      debugPrint('✅ Reaction removed successfully');
    } catch (e) {
      debugPrint('❌ Error removing reaction: $e');
      throw Exception('Failed to remove reaction: $e');
    }
  }

  /// Pin/unpin comment
  Future<void> togglePinComment(
    String taskId,
    String commentId,
    bool isPinned,
  ) async {
    if (taskId.isEmpty || commentId.isEmpty) {
      throw Exception('Cannot pin comment: Task ID or Comment ID is empty.');
    }

    try {
      debugPrint(
        '${isPinned ? '📌' : '📍'} ${isPinned ? 'Pinning' : 'Unpinning'} comment $commentId in task $taskId',
      );
      final taskDoc = await _firestore
          .collection(tasksCollection)
          .doc(taskId)
          .get();
      final data = _normalizeFirestoreData(
        taskDoc.data() as Map<String, dynamic>,
      );
      // Remove empty id field to avoid conflicts
      data.remove('id');
      final task = Task.fromJson({...data, 'id': taskDoc.id});

      final updatedComments = task.comments.map((comment) {
        if (comment.id == commentId) {
          return comment.copyWith(isPinned: isPinned);
        }
        return comment;
      }).toList();

      final commentsJson = updatedComments.map((c) => c.toJson()).toList();
      // Convert DateTime objects to Firestore Timestamps for nested structures
      final commentsWithTimestamps = commentsJson
          .map((c) => _convertDatesToTimestamps(c))
          .toList();

      await _firestore.collection(tasksCollection).doc(taskId).update({
        'comments': commentsWithTimestamps,
        'updatedAt': Timestamp.now(),
      });
      debugPrint('✅ Comment ${isPinned ? 'pinned' : 'unpinned'} successfully');
    } catch (e) {
      debugPrint('❌ Error toggling pin: $e');
      throw Exception('Failed to toggle pin: $e');
    }
  }

  /// Search tasks by title or description
  Future<List<Task>> searchTasks(String query) async {
    try {
      // Note: For production, consider using Algolia or Meilisearch for better search
      final snapshot = await _firestore.collection(tasksCollection).get();

      final tasks = snapshot.docs.map((doc) {
        final data = _normalizeFirestoreData(doc.data());
        // Remove empty id field to avoid conflicts
        data.remove('id');
        return Task.fromJson({...data, 'id': doc.id});
      }).toList();

      return tasks
          .where(
            (task) =>
                task.title.toLowerCase().contains(query.toLowerCase()) ||
                task.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search tasks: $e');
    }
  }

  /// Send reminder notification for pending task if not started
  /// Returns true if reminder was sent
  Future<bool> sendReminderForPendingTask(
    String taskId,
    String employeeId,
    String employeeName,
  ) async {
    try {
      debugPrint(
        '📤 Sending reminder for task: $taskId to employee: $employeeId',
      );

      // Get the task to verify it's still pending
      final task = await getTaskById(taskId);
      if (task == null) {
        debugPrint('❌ Task not found');
        return false;
      }

      if (task.status != TaskStatus.pending) {
        debugPrint(
          'ℹ️ Task is no longer pending (status: ${task.status}), skipping reminder',
        );
        return false;
      }

      // Record the reminder using TaskReminderService
      final reminderService = TaskReminderService();
      await reminderService.recordReminderSent(
        taskId,
        employeeId,
        employeeName,
      );

      debugPrint('✅ Reminder recorded for task: $taskId');
      return true;
    } catch (e) {
      debugPrint('❌ Error sending reminder: $e');
      return false;
    }
  }

  /// Get all pending tasks that need reminders for an employee
  Future<List<Task>> getPendingTasksNeedingReminders(String employeeId) async {
    try {
      debugPrint('🔍 Getting pending tasks needing reminders for: $employeeId');

      final reminderService = TaskReminderService();
      final tasksNeedingReminders = await reminderService
          .getTasksNeedingReminders(employeeId);

      debugPrint(
        '📬 Found ${tasksNeedingReminders.length} tasks needing reminders',
      );
      return tasksNeedingReminders;
    } catch (e) {
      debugPrint('❌ Error getting pending tasks: $e');
      return [];
    }
  }

  /// Clear reminders when task starts
  Future<void> clearTaskReminders(String taskId, String employeeId) async {
    try {
      debugPrint('🧹 Clearing reminders for task: $taskId');
      final reminderService = TaskReminderService();
      await reminderService.clearRemindersForTask(taskId, employeeId);
    } catch (e) {
      debugPrint('Warning: Error clearing reminders: $e');
    }
  }
}

extension TaskStatusExtension on TaskStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => TaskStatus.pending,
    );
  }
}
