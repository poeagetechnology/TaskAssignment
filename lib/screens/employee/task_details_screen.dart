import 'package:flutter/material.dart';
import '../../config/index.dart';
import '../../models/index.dart';
import '../../widgets/index.dart';

/// Employee Task Details Screen showing task information and completion form
class EmployeeTaskDetailsScreen extends StatefulWidget {
  final Task task;
  final String employeeId;

  const EmployeeTaskDetailsScreen({
    required this.task,
    required this.employeeId,
    super.key,
  });

  @override
  State<EmployeeTaskDetailsScreen> createState() =>
      _EmployeeTaskDetailsScreenState();
}

class _EmployeeTaskDetailsScreenState extends State<EmployeeTaskDetailsScreen> {
  late Task _currentTask;
  final _commentController = TextEditingController();
  bool _showComments = false;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Format date to readable format
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Add comment
  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final userId = AppConfig.authService.currentUserId;
    final userName = AppConfig.authService.currentUser?.email ?? 'Unknown';

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: User not logged in'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (widget.task.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Task ID is invalid'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    try {
      final comment = TaskComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorId: userId,
        authorName: userName,
        text: text,
        createdAt: DateTime.now(),
      );

      await AppConfig.taskService.addTaskComment(widget.task.id, comment);
      _commentController.clear();

      if (mounted) {
        setState(() {
          _currentTask = _currentTask.copyWith(
            comments: [..._currentTask.comments, comment],
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  /// Add reaction to a comment
  Future<void> _addReactionToComment(
    String commentId,
    CommentReaction reaction,
  ) async {
    if (widget.task.id.isEmpty) return;

    try {
      await AppConfig.taskService.addCommentReaction(
        widget.task.id,
        commentId,
        reaction,
      );

      if (mounted) {
        setState(() {
          final updatedComments = _currentTask.comments.map((comment) {
            if (comment.id == commentId) {
              return comment.copyWithReaction(reaction);
            }
            return comment;
          }).toList();

          _currentTask = _currentTask.copyWith(comments: updatedComments);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding reaction: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  /// Remove reaction from a comment
  Future<void> _removeReactionFromComment(
    String commentId,
    String emoji,
    String userId,
  ) async {
    if (widget.task.id.isEmpty) return;

    try {
      await AppConfig.taskService.removeCommentReaction(
        widget.task.id,
        commentId,
        emoji,
        userId,
      );

      if (mounted) {
        setState(() {
          final updatedComments = _currentTask.comments.map((comment) {
            if (comment.id == commentId) {
              return comment.removeReaction(emoji, userId);
            }
            return comment;
          }).toList();

          _currentTask = _currentTask.copyWith(comments: updatedComments);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing reaction: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  /// Add reply to a comment
  Future<void> _addReplyToComment(String commentId, CommentReply reply) async {
    if (widget.task.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Task ID is invalid'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    try {
      await AppConfig.taskService.addCommentReply(
        widget.task.id,
        commentId,
        reply,
      );

      if (mounted) {
        setState(() {
          final updatedComments = _currentTask.comments.map((comment) {
            if (comment.id == commentId) {
              return comment.copyWithReply(reply);
            }
            return comment;
          }).toList();

          _currentTask = _currentTask.copyWith(comments: updatedComments);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reply added successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding reply: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  /// Get priority color
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.critical:
        return AppColors.priorityCritical;
    }
  }

  /// Get priority label
  String _getPriorityLabel(TaskPriority priority) {
    return priority.toString().split('.').last.toUpperCase();
  }

  /// Show task completion form
  void _showCompletionForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: TaskCompletionForm(
          task: _currentTask,
          employeeId: widget.employeeId,
          onCompletionSuccess: () {
            setState(() {
              _currentTask = _currentTask.copyWith(
                status: TaskStatus.verification,
              );
            });
            Navigator.pop(context, true);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        _currentTask.status == TaskStatus.verification ||
        _currentTask.status == TaskStatus.completed;
    final isOverdue =
        _currentTask.deadline.isBefore(DateTime.now()) && !isCompleted;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        elevation: 2,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
        ),
        title: const Text(
          'Task Details',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task header with status
            Container(
              padding: const EdgeInsets.all(AppSpacing.md16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppSpacing.radiusMd),
                  bottomRight: Radius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(_currentTask.priority),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getPriorityLabel(_currentTask.priority),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: AppTypography.fontSize12,
                        fontWeight: AppTypography.semiBold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentTask.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: AppTypography.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Status indicator
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _currentTask.status == TaskStatus.completed
                              ? AppColors.statusCompleted
                              : _currentTask.status == TaskStatus.verification
                              ? AppColors.statusVerification
                              : _currentTask.status == TaskStatus.inProgress
                              ? AppColors.statusInProgress
                              : AppColors.statusPending,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentTask.status
                            .toString()
                            .split('.')
                            .last
                            .replaceAllMapped(
                              RegExp(r'([A-Z])'),
                              (m) => ' ${m.group(1)}',
                            )
                            .trim(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: AppTypography.semiBold,
                          color: AppColors.white,
                        ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.errorRed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Overdue',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: AppTypography.fontSize10,
                              fontWeight: AppTypography.semiBold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md16),

            // Task details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: AppTypography.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.lightGrey, width: 1),
                    ),
                    child: Text(
                      _currentTask.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md16),

                  // Location info
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.constructionGold,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Site Location',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.slateGrey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentTask.siteLocation.siteName ??
                                  'Unknown Site',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: AppTypography.semiBold,
                                    color: AppColors.deepNavy,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            if (_currentTask.siteLocation.address != null)
                              Text(
                                _currentTask.siteLocation.address!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.slateGrey),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md16),

                  // Deadline info
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: isOverdue
                            ? AppColors.errorRed
                            : AppColors.constructionGold,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deadline',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.slateGrey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(_currentTask.deadline),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: AppTypography.semiBold,
                                    color: isOverdue
                                        ? AppColors.errorRed
                                        : AppColors.deepNavy,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md16),

                  // Attached images
                  if (_currentTask.imageAttachments.isNotEmpty) ...[
                    Text(
                      'Reference Images (${_currentTask.imageAttachments.length})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: AppTypography.bold,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _currentTask.imageAttachments.length,
                      itemBuilder: (context, index) {
                        final image = _currentTask.imageAttachments[index];
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            color: AppColors.lightGrey,
                            border: Border.all(color: AppColors.lightGrey),
                          ),
                          child: Image.network(
                            image.url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.slateGrey.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md16),
                  ],

                  // Notes
                  if (_currentTask.notes != null &&
                      _currentTask.notes!.isNotEmpty) ...[
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: AppTypography.bold,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md16),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(
                          color: AppColors.successGreen.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.successGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _currentTask.notes!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.deepNavy),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md16),

            // Comments Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: AppColors.deepNavy.withValues(alpha: 0.1),
                    thickness: 1,
                  ),
                  const SizedBox(height: AppSpacing.md16),

                  // Comments button
                  GestureDetector(
                    onTap: () => setState(() => _showComments = !_showComments),
                    child: Row(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 18,
                          color: AppColors.constructionGold,
                        ),
                        const SizedBox(width: AppSpacing.sm12),
                        Expanded(
                          child: Text(
                            'Comments (${_currentTask.comments.length})',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  fontWeight: AppTypography.semiBold,
                                  color: AppColors.deepNavy,
                                ),
                          ),
                        ),
                        Icon(
                          _showComments ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.slateGrey,
                        ),
                      ],
                    ),
                  ),

                  // Comments list and input
                  if (_showComments) ...[
                    const SizedBox(height: AppSpacing.md16),

                    // Existing comments
                    if (_currentTask.comments.isNotEmpty) ...[
                      // Pinned comments first
                      ..._currentTask.comments
                          .where((c) => c.isPinned)
                          .map(
                            (comment) => CommentThreadWidget(
                              comment: comment,
                              onAddReaction: (reaction) =>
                                  _addReactionToComment(comment.id, reaction),
                              onRemoveReaction: (emoji, userId) =>
                                  _removeReactionFromComment(
                                    comment.id,
                                    emoji,
                                    userId,
                                  ),
                              onAddReply: (reply) =>
                                  _addReplyToComment(comment.id, reply),
                              canInteract: true,
                            ),
                          ),
                      // Regular comments
                      ..._currentTask.comments
                          .where((c) => !c.isPinned)
                          .map(
                            (comment) => CommentThreadWidget(
                              comment: comment,
                              onAddReaction: (reaction) =>
                                  _addReactionToComment(comment.id, reaction),
                              onRemoveReaction: (emoji, userId) =>
                                  _removeReactionFromComment(
                                    comment.id,
                                    emoji,
                                    userId,
                                  ),
                              onAddReply: (reply) =>
                                  _addReplyToComment(comment.id, reply),
                              canInteract: true,
                            ),
                          ),
                    ] else
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.sm12,
                        ),
                        child: Text(
                          'No comments yet. Start a discussion!',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.slateGrey,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ),

                    const SizedBox(height: AppSpacing.md16),

                    // Add comment input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(
                          color: AppColors.constructionGold.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.all(AppSpacing.md16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment or ask a question...',
                              hintStyle: const TextStyle(
                                color: AppColors.slateGrey,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            maxLines: 3,
                            minLines: 1,
                          ),
                          SizedBox(height: AppSpacing.md16),
                          FilledButton.icon(
                            onPressed: _addComment,
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text('Comment'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.constructionGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: !isCompleted
          ? Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSpacing.md16),
              child: SafeArea(
                child: SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _showCompletionForm,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.constructionGold,
                      foregroundColor: AppColors.deepNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline),
                        const SizedBox(width: 12),
                        Text(
                          'Submit Completion',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontSize: AppTypography.fontSize16,
                                fontWeight: AppTypography.semiBold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
