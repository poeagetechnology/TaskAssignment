import 'package:flutter/material.dart';
import '../../config/index.dart';
import '../../models/index.dart';
import '../../widgets/index.dart';

/// Employee home screen showing assigned tasks
class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  late Stream<List<Task>> _taskStream;
  int _selectedIndex = 0;
  User? _currentUser;

  static const List<String> _tabTitles = ['My Tasks', 'Progress', 'Profile'];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final userId = AppConfig.authService.currentUserId;
    if (userId != null) {
      AppConfig.authService
          .getUserProfile(userId)
          .then((user) {
            if (mounted) {
              setState(() => _currentUser = user);
            }
          })
          .catchError((e) {
            debugPrint('Error loading user profile: $e');
          });
    }
  }

  void _loadTasks() {
    final userId = AppConfig.authService.currentUserId;
    debugPrint('🔍 _loadTasks: currentUserId=$userId');
    if (userId != null) {
      debugPrint('✅ Loading tasks for userId: $userId');
      _taskStream = AppConfig.taskService.getTasksForEmployee(userId);
    } else {
      debugPrint('❌ currentUserId is null');
      // Initialize with empty stream if user ID is not available
      _taskStream = Stream.value([]);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AppConfig.authService.signOut();
    }
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[_selectedIndex]),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [_buildMyTasksTab(), _buildProgressTab(), _buildProfileTab()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.deepNavy,
        selectedItemColor: AppColors.constructionGold,
        unselectedItemColor: AppColors.white.withValues(alpha: 0.5),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_rounded),
            label: 'My Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildMyTasksTab() {
    return Container(
      color: AppColors.lightGrey,
      child: StreamBuilder<List<Task>>(
        stream: _taskStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    size: 64,
                    color: AppColors.slateGrey.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: AppSpacing.md16),
                  Text(
                    'No tasks assigned',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.slateGrey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: tasks.length + 1, // +1 for reminder widget
            itemBuilder: (context, index) {
              // Show reminder alert as first item
              if (index == 0) {
                final userId = AppConfig.authService.currentUserId;
                final userName = _currentUser?.name ?? 'Employee';

                return (userId != null)
                    ? TaskReminderAlert(
                        employeeId: userId,
                        employeeName: userName,
                      )
                    : const SizedBox.shrink();
              }

              final task = tasks[index - 1];
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md16,
                  vertical: 4,
                ),
                child: _TaskCard(task: task),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProgressTab() {
    return Container(
      color: AppColors.lightGrey,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 72,
              color: AppColors.slateGrey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md16),
            Text(
              'Daily Progress Reports',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: AppTypography.semiBold,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.slateGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    if (_currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: AppColors.lightGrey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md16),
              child: Card(
                color: AppColors.white,
                elevation: 8,
                shadowColor: AppColors.black.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.constructionGold.withValues(
                          alpha: 0.2,
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: AppColors.constructionGold,
                          child: Text(
                            (_currentUser!.name).substring(0, 1).toUpperCase(),
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: AppTypography.bold,
                                  color: AppColors.deepNavy,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md16),
                      Text(
                        _currentUser!.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: AppTypography.bold,
                              color: AppColors.deepNavy,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm12),
                      Text(
                        _currentUser!.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.deepNavy,
                          fontWeight: AppTypography.medium,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md16),
                      Container(
                        height: 1.5,
                        color: AppColors.deepNavy.withValues(alpha: 0.15),
                      ),
                      const SizedBox(height: AppSpacing.md16),
                      _buildInfoRow(
                        Icons.phone,
                        'Phone',
                        _currentUser!.phoneNumber ?? 'N/A',
                      ),
                      _buildInfoRow(
                        Icons.work,
                        'Designation',
                        _currentUser!.designation ?? 'N/A',
                      ),
                      _buildInfoRow(
                        Icons.business,
                        'Company',
                        _currentUser!.company ?? 'N/A',
                      ),
                      _buildInfoRow(
                        Icons.location_city,
                        'Assigned Sites',
                        _currentUser!.assignedSites.isNotEmpty
                            ? _currentUser!.assignedSites.join(', ')
                            : 'Not assigned',
                      ),
                      _buildInfoRow(
                        Icons.verified_user,
                        'Role',
                        _currentUser!.role.toString().split('.').last,
                      ),
                      const SizedBox(height: AppSpacing.md16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _handleLogout,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.errorRed,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md16,
                            ),
                          ),
                          child: const Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.constructionGold),
          const SizedBox(width: AppSpacing.md16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.slateGrey,
                    fontWeight: AppTypography.semiBold,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.deepNavy,
                    fontWeight: AppTypography.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatefulWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  bool _isUpdating = false;
  final _commentController = TextEditingController();
  bool _showComments = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Color _getStatusColor(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => AppColors.statusPending,
      TaskStatus.inProgress => AppColors.statusInProgress,
      TaskStatus.verification => AppColors.statusVerification,
      TaskStatus.completed => AppColors.statusCompleted,
      TaskStatus.cancelled => AppColors.statusCancelled,
    };
  }

  String _getStatusText(TaskStatus status) {
    return status
        .toString()
        .split('.')
        .last
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match[1]}')
        .trim();
  }

  /// Get available status transitions for employee
  List<TaskStatus> _getAvailableStatuses() {
    switch (widget.task.status) {
      case TaskStatus.pending:
        return [TaskStatus.inProgress, TaskStatus.cancelled];
      case TaskStatus.inProgress:
        return [
          TaskStatus.verification,
          TaskStatus.pending,
          TaskStatus.cancelled,
        ];
      case TaskStatus.verification:
        return [TaskStatus.inProgress]; // Can go back to in progress
      case TaskStatus.completed:
      case TaskStatus.cancelled:
        return []; // Cannot change completed or cancelled tasks
    }
  }

  Future<void> _updateTaskStatus(TaskStatus newStatus) async {
    if (_isUpdating) return;

    // Validate task ID
    if (widget.task.id.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error: Task ID is invalid. Please refresh and try again.',
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
      debugPrint('❌ Task ID is empty: ${widget.task}');
      return;
    }

    setState(() => _isUpdating = true);

    try {
      debugPrint(
        '📝 Updating task ${widget.task.id} to status ${_getStatusText(newStatus)}',
      );
      await AppConfig.taskService.updateTaskStatus(widget.task.id, newStatus);

      // Clear reminders when task starts
      if (newStatus == TaskStatus.inProgress &&
          widget.task.status == TaskStatus.pending) {
        debugPrint('🧹 Clearing reminders for started task');
        try {
          await AppConfig.taskService.clearTaskReminders(
            widget.task.id,
            widget.task.assignedTo,
          );
          debugPrint('✅ Reminders cleared');
        } catch (e) {
          debugPrint('⚠️ Warning: Could not clear reminders: $e');
        }
      }

      if (mounted) {
        debugPrint('✅ Task status updated successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Task status updated to ${_getStatusText(newStatus)}',
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating task status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    // Get current user
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

    // Validate task ID
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

  @override
  Widget build(BuildContext context) {
    final availableStatuses = _getAvailableStatuses();
    final isStatusChangeable = availableStatuses.isNotEmpty;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md16),
      color: AppColors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: _getStatusColor(widget.task.status).withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: AppTypography.bold,
                        color: AppColors.deepNavy,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isStatusChangeable)
                    PopupMenuButton<TaskStatus>(
                      enabled: !_isUpdating,
                      onSelected: _updateTaskStatus,
                      itemBuilder: (context) {
                        return availableStatuses.map((status) {
                          return PopupMenuItem<TaskStatus>(
                            value: status,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: AppSpacing.sm12),
                                Text(_getStatusText(status)),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            widget.task.status,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getStatusText(widget.task.status),
                              style: TextStyle(
                                color: _getStatusColor(widget.task.status),
                                fontSize: AppTypography.fontSize10,
                                fontWeight: AppTypography.semiBold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down,
                              size: 16,
                              color: _getStatusColor(widget.task.status),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          widget.task.status,
                        ).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getStatusText(widget.task.status),
                        style: TextStyle(
                          color: _getStatusColor(widget.task.status),
                          fontSize: AppTypography.fontSize10,
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.sm12),

              // Description
              if (widget.task.description.isNotEmpty)
                Text(
                  widget.task.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.slateGrey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              SizedBox(height: AppSpacing.sm12),

              // Site and deadline
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.slateGrey,
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.task.siteLocation.siteName ?? 'Unknown Site',
                      style: TextStyle(
                        color: AppColors.slateGrey,
                        fontSize: AppTypography.fontSize12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md16),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.slateGrey,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${widget.task.deadline.month}/${widget.task.deadline.day}/${widget.task.deadline.year}',
                    style: TextStyle(
                      color: AppColors.slateGrey,
                      fontSize: AppTypography.fontSize12,
                    ),
                  ),
                ],
              ),

              // Status change hint
              if (isStatusChangeable)
                Padding(
                  padding: EdgeInsets.only(top: AppSpacing.sm12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: AppColors.constructionGold,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Tap status to update',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.constructionGold,
                                fontWeight: AppTypography.medium,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Comments section
              SizedBox(height: AppSpacing.md16),
              Divider(color: AppColors.deepNavy.withValues(alpha: 0.1)),
              SizedBox(height: AppSpacing.md16),

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
                    SizedBox(width: AppSpacing.sm12),
                    Expanded(
                      child: Text(
                        'Comments (${widget.task.comments.length})',
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
                SizedBox(height: AppSpacing.md16),

                // Existing comments with enhanced UI (pinned first)
                if (widget.task.comments.isNotEmpty) ...[
                  // Pinned comments
                  ...widget.task.comments
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
                  ...widget.task.comments
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
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm12),
                    child: Text(
                      'No comments yet. Start a discussion!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.slateGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                SizedBox(height: AppSpacing.md16),

                // Add comment input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: AppColors.constructionGold.withValues(alpha: 0.2),
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
      ),
    );
  }
}
