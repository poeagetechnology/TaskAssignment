import 'package:flutter/material.dart';
import '../config/index.dart';
import '../models/index.dart';

/// Task card widget for displaying task information
class TaskCard extends StatelessWidget {
  /// The task to display
  final Task task;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback for delete action
  final VoidCallback? onDelete;

  /// Callback for status update
  final Function(TaskStatus)? onStatusChanged;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onDelete,
    this.onStatusChanged,
  });

  /// Get color based on priority
  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.critical:
        return AppColors.errorRed;
      case TaskPriority.high:
        return AppColors.warningOrange;
      case TaskPriority.medium:
        return AppColors.infoBlue;
      case TaskPriority.low:
        return AppColors.successGreen;
    }
  }

  /// Get color based on status
  Color _getStatusColor() {
    switch (task.status) {
      case TaskStatus.pending:
        return AppColors.statusPending;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.verification:
        return AppColors.statusVerification;
      case TaskStatus.completed:
        return AppColors.statusCompleted;
      case TaskStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  /// Get status display text
  String _getStatusText() {
    switch (task.status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.verification:
        return 'Verification';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get priority display text
  String _getPriorityText() {
    return task.priority.toString().split('.').last.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md16,
          vertical: AppSpacing.sm12,
        ),
        elevation: AppSpacing.elevationSm,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: isOverdue
                ? Border.all(
                    color: AppColors.errorRed.withAlpha(30),
                    width: 1.5,
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with title, priority, and menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: AppTypography.semiBold,
                                  color: AppColors.deepNavy,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task.siteLocation.siteName ?? 'Site Location',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.slateGrey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Priority badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor().withAlpha(10),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXs,
                        ),
                      ),
                      child: Text(
                        _getPriorityText(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getPriorityColor(),
                          fontWeight: AppTypography.semiBold,
                          fontSize: AppTypography.fontSize10,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm12),
                    // More options menu
                    PopupMenuButton<String>(
                      position: PopupMenuPosition.under,
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: AppColors.slateGrey,
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          onDelete?.call();
                        } else {
                          // Parse status from value
                          final statusMap = {
                            'pending': TaskStatus.pending,
                            'inProgress': TaskStatus.inProgress,
                            'verification': TaskStatus.verification,
                            'completed': TaskStatus.completed,
                          };
                          if (statusMap.containsKey(value)) {
                            onStatusChanged?.call(statusMap[value]!);
                          }
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem<String>(
                          value: 'pending',
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 18,
                                color: AppColors.statusPending,
                              ),
                              const SizedBox(width: 12),
                              const Text('Mark Pending'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'inProgress',
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                size: 18,
                                color: AppColors.statusInProgress,
                              ),
                              const SizedBox(width: 12),
                              const Text('Mark In Progress'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'verification',
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 18,
                                color: AppColors.statusVerification,
                              ),
                              const SizedBox(width: 12),
                              const Text('Mark Verification'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'completed',
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: AppColors.statusCompleted,
                              ),
                              const SizedBox(width: 12),
                              const Text('Mark Completed'),
                            ],
                          ),
                        ),
                        if (onDelete != null) ...[
                          const PopupMenuDivider(),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: AppColors.errorRed,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Delete',
                                  style: TextStyle(color: AppColors.errorRed),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm12),

                // Description
                Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.slateGrey,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md16),

                // Status, deadline, and progress row
                Row(
                  children: [
                    // Status badge
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withAlpha(10),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusXs,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: _getStatusColor(),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _getStatusText(),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: _getStatusColor(),
                                      fontWeight: AppTypography.medium,
                                      fontSize: AppTypography.fontSize10,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm12),

                    // Deadline info
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: isOverdue
                                ? AppColors.errorRed
                                : AppColors.slateGrey,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _formatDate(task.deadline),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: isOverdue
                                        ? AppColors.errorRed
                                        : AppColors.slateGrey,
                                    fontSize: AppTypography.fontSize10,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md16),

                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: AppTypography.medium,
                                fontSize: AppTypography.fontSize10,
                              ),
                        ),
                        Text(
                          '${task.progressPercentage}%',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: AppTypography.semiBold,
                                fontSize: AppTypography.fontSize10,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                      child: LinearProgressIndicator(
                        value: task.progressPercentage / 100,
                        minHeight: 6,
                        backgroundColor: AppColors.lightGrey,
                        valueColor: AlwaysStoppedAnimation(
                          task.status == TaskStatus.completed
                              ? AppColors.successGreen
                              : AppColors.infoBlue,
                        ),
                      ),
                    ),
                  ],
                ),

                // Overdue warning
                if (isOverdue)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withAlpha(10),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXs,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            size: 14,
                            color: AppColors.errorRed,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Overdue',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.errorRed,
                                  fontWeight: AppTypography.semiBold,
                                  fontSize: AppTypography.fontSize10,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Format date to readable string
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
