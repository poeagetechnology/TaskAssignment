import 'package:flutter/material.dart';
import '../../config/index.dart';
import '../../models/index.dart';

/// Widget to display task reminders for unstarted tasks
class TaskReminderAlert extends StatefulWidget {
  final String employeeId;
  final String employeeName;

  const TaskReminderAlert({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  State<TaskReminderAlert> createState() => _TaskReminderAlertState();
}

class _TaskReminderAlertState extends State<TaskReminderAlert> {
  late Future<List<Task>> _remindersFuture;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() {
    _remindersFuture = AppConfig.taskService.getPendingTasksNeedingReminders(
      widget.employeeId,
    );
  }

  void _dismissReminder(Task task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reminder dismissed'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  void _navigateToTask(Task task) {
    Navigator.of(context).pushNamed('/task-details', arguments: task);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: _remindersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final reminders = snapshot.data ?? [];

        if (reminders.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            _buildReminderBanner(reminders),
            if (_isExpanded) _buildReminderList(reminders),
          ],
        );
      },
    );
  }

  Widget _buildReminderBanner(List<Task> reminders) {
    return GestureDetector(
      onTap: () {
        setState(() => _isExpanded = !_isExpanded);
      },
      child: Container(
        margin: EdgeInsets.all(AppSpacing.md16),
        padding: EdgeInsets.all(AppSpacing.md16),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          border: Border.all(color: Colors.amber[500]!, width: 1.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Icon(
              Icons.notifications_active,
              color: Colors.amber[700],
              size: 24,
            ),
            SizedBox(width: AppSpacing.md16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⏰ Task Reminders',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.amber[900],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'You have ${reminders.length} unstarted ${reminders.length == 1 ? 'task' : 'tasks'} waiting',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.amber[800]),
                  ),
                ],
              ),
            ),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.amber[700],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderList(List<Task> reminders) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md16),
      child: Column(
        children: reminders.map((task) {
          return _buildReminderItem(task);
        }).toList(),
      ),
    );
  }

  Widget _buildReminderItem(Task task) {
    final daysOverdue = DateTime.now().difference(task.createdAt).inDays;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md16),
      padding: EdgeInsets.all(AppSpacing.md16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.amber[200]!, width: 1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.priority_high,
                          size: 16,
                          color: _getPriorityColor(task.priority),
                        ),
                        SizedBox(width: 4),
                        Text(
                          task.priority
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: _getPriorityColor(task.priority),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(width: AppSpacing.md16),
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Created ${daysOverdue}d ago',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _dismissReminder(task),
                child: const Text('Dismiss'),
              ),
              SizedBox(width: 8),
              FilledButton(
                onPressed: () => _navigateToTask(task),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                ),
                child: const Text('Start Task'),
              ),
            ],
          ),
        ],
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
}
