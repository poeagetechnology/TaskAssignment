import 'package:flutter/material.dart';
import '../../config/index.dart';
import '../../models/index.dart';

/// Admin widget to view and manage task reminders
class AdminTaskRemindersWidget extends StatefulWidget {
  final String adminId;

  const AdminTaskRemindersWidget({super.key, required this.adminId});

  @override
  State<AdminTaskRemindersWidget> createState() =>
      _AdminTaskRemindersWidgetState();
}

class _AdminTaskRemindersWidgetState extends State<AdminTaskRemindersWidget> {
  late Future<List<Task>> _pendingTasksFuture;

  @override
  void initState() {
    super.initState();
    _loadPendingTasks();
  }

  void _loadPendingTasks() {
    _pendingTasksFuture = AppConfig.taskService
        .getTasksByStatus(TaskStatus.pending)
        .first;
  }

  Future<void> _sendRemindersForTask(Task task) async {
    try {
      debugPrint('📬 Sending reminders for task: ${task.id}');
      await AppConfig.taskService.sendReminderForPendingTask(
        task.id,
        task.assignedTo,
        'Employee',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminders queued for sending'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending reminders: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _refreshReminders() async {
    setState(() {
      _loadPendingTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Reminders'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReminders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: _pendingTasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tasks = snapshot.data ?? [];

          // Filter only tasks assigned by this admin
          final adminTasks = tasks
              .where((t) => t.assignedBy == widget.adminId)
              .toList();

          if (adminTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 64,
                    color: AppColors.slateGrey.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pending tasks to track',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.slateGrey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md16),
            itemCount: adminTasks.length,
            itemBuilder: (context, index) {
              final task = adminTasks[index];
              return _buildReminderCard(task);
            },
          );
        },
      ),
    );
  }

  Widget _buildReminderCard(Task task) {
    final daysPending = DateTime.now().difference(task.createdAt).inDays;
    final isPastThreshold = daysPending >= 1; // 24 hours

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md16),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title and Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pending since ${daysPending}d ago',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPastThreshold
                        ? Colors.orange[50]
                        : Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isPastThreshold ? Colors.orange : Colors.blue,
                    ),
                  ),
                  child: Text(
                    isPastThreshold ? 'NEEDS REMINDER' : 'MONITORING',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isPastThreshold ? Colors.orange : Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Task Details
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.priority_high,
                        size: 16,
                        color: _getPriorityColor(task.priority),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.priority.toString().split('.').last.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getPriorityColor(task.priority),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: _getDeadlineColor(task.deadline),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDaysUntilDeadline(task.deadline),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getDeadlineColor(task.deadline),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.blue[600]),
                      const SizedBox(height: 4),
                      Text(
                        'Assigned',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action Button
            if (isPastThreshold)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _sendRemindersForTask(task),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amber[600],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_active, size: 18),
                      SizedBox(width: 8),
                      Text('Send Reminder'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical:
        return Colors.red;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.medium:
        return Colors.amber;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  Color _getDeadlineColor(DateTime deadline) {
    final daysUntil = deadline.difference(DateTime.now()).inDays;
    if (daysUntil < 0) return Colors.red;
    if (daysUntil <= 1) return Colors.red;
    if (daysUntil <= 3) return Colors.orange;
    return Colors.green;
  }

  String _getDaysUntilDeadline(DateTime deadline) {
    final daysUntil = deadline.difference(DateTime.now()).inDays;
    if (daysUntil < 0) return 'Overdue';
    if (daysUntil == 0) return 'Today';
    if (daysUntil == 1) return 'Tomorrow';
    return '${daysUntil}d left';
  }
}
