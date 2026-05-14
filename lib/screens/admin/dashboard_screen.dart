import 'package:flutter/material.dart';
import 'dart:async';
import '../../config/index.dart';
import '../../models/index.dart';
import '../../utils/app_constants.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/task_card.dart';
import '../../widgets/create_task_bottom_sheet.dart';
import '../employee/task_details_screen.dart';

/// Admin Dashboard screen
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Task> _allTasks = [];
  User? _currentUser;
  bool _isLoading = true;
  int _selectedIndex = 0;
  StreamSubscription<List<Task>>? _tasksSub;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _tasksSub?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    // Load current user profile
    final uid = AppConfig.authService.currentUserId;
    if (uid != null) {
      try {
        final user = await AppConfig.authService.getUserProfile(uid);
        if (mounted) setState(() => _currentUser = user);
      } catch (e) {
        debugPrint('Could not load user profile: $e');
      }
    }

    // Subscribe to all tasks stream
    _tasksSub = AppConfig.taskService.getAllTasks().listen(
      (tasks) {
        debugPrint(
          '📬 AdminDashboard: Received ${tasks.length} tasks from stream',
        );
        for (final task in tasks) {
          debugPrint('   - Task: id=${task.id}, title=${task.title}');
        }
        if (mounted) {
          setState(() {
            _allTasks = tasks;
            _isLoading = false;
          });
          debugPrint(
            '✅ AdminDashboard: Updated _allTasks with ${_allTasks.length} tasks',
          );
        }
      },
      onError: (e) {
        debugPrint('❌ Tasks stream error: $e');
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  int get _totalTasks => _allTasks.length;

  int get _overdueTasks => _allTasks.where((task) => task.isOverdue).length;

  int get _activeSites {
    final sites = <String>{};
    for (final task in _allTasks) {
      if (task.status != TaskStatus.completed &&
          task.status != TaskStatus.cancelled) {
        sites.add(task.siteLocation.siteName ?? 'Unknown');
      }
    }
    return sites.length;
  }

  Map<String, List<Task>> _getTasksBySite() {
    final Map<String, List<Task>> grouped = {};
    for (final task in _allTasks) {
      final siteName = task.siteLocation.siteName ?? 'Unknown Site';
      grouped.putIfAbsent(siteName, () => []);
      grouped[siteName]!.add(task);
    }
    return grouped;
  }

  /// Show create task bottom sheet
  void _showCreateTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateTaskBottomSheet(
        onTaskCreated: (_) {}, // Stream handles refresh automatically
        onDismiss: () {},
      ),
    );
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
      backgroundColor: AppColors.lightGrey,
      body: _isLoading
          ? _buildLoadingState()
          : IndexedStack(
              index: _selectedIndex,
              children: [
                _buildDashboardTab(),
                _buildAllTasksTab(),
                _buildEmployeesTab(),
                _buildProfileTab(),
              ],
            ),
      floatingActionButton: _selectedIndex == 0
          ? _buildFloatingActionButton()
          : null,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildDashboardTab() {
    return CustomScrollView(
      slivers: [
        // Premium SliverAppBar with glassmorphism
        _buildSliverAppBar(),

        // Statistics section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md16,
              vertical: AppSpacing.md16,
            ),
            child: _buildStatisticsRow(),
          ),
        ),

        // Tasks by site section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md16),
            child: Text(
              'Active Tasks by Site',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: AppTypography.bold,
                color: AppColors.deepNavy,
              ),
            ),
          ),
        ),

        // Tasks grouped by site
        _buildTasksList(),

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl24)),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
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
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.task_alt_rounded),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_rounded),
          label: 'Employees',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }

  /// Build SliverAppBar with admin info
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.deepNavy,
      elevation: AppSpacing.elevationMd,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _handleLogout,
          tooltip: 'Logout',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md16,
                vertical: AppSpacing.md16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.8),
                                  fontWeight: AppTypography.regular,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentUser?.name ?? 'Admin',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: AppTypography.bold,
                                  color: AppColors.white,
                                ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.constructionGold.withValues(
                          alpha: 0.2,
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.constructionGold,
                          child: Text(
                            (_currentUser?.name ?? 'A')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: AppTypography.bold,
                                  color: AppColors.deepNavy,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl24),
                  Row(
                    children: [
                      Icon(
                        Icons.business_center_rounded,
                        color: AppColors.white.withValues(alpha: 0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _currentUser?.designation ?? 'Administrator',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build statistics row with glassmorphism cards
  Widget _buildStatisticsRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Total Tasks',
                value: _totalTasks.toString(),
                icon: Icons.task_alt_rounded,
                iconColor: AppColors.infoBlue,
                gradient: StatCardGradients.getGradientForType('active'),
              ),
            ),
            const SizedBox(width: AppSpacing.md16),
            Expanded(
              child: StatCard(
                label: 'Active Sites',
                value: _activeSites.toString(),
                icon: Icons.location_on_rounded,
                iconColor: AppColors.successGreen,
                gradient: StatCardGradients.getGradientForType('sites'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Overdue Tasks',
                value: _overdueTasks.toString(),
                icon: Icons.warning_rounded,
                iconColor: AppColors.errorRed,
                gradient: StatCardGradients.getGradientForType('overdue'),
              ),
            ),
            const SizedBox(width: AppSpacing.md16),
            Expanded(
              child: StatCard(
                label: 'In Progress',
                value: _allTasks
                    .where((t) => t.status == TaskStatus.inProgress)
                    .length
                    .toString(),
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.constructionGold,
                gradient: StatCardGradients.getGradientForType('default'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build tasks list grouped by site
  Widget _buildTasksList() {
    final tasksBySite = _getTasksBySite();

    if (tasksBySite.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl24),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_rounded,
                  size: 64,
                  color: AppColors.slateGrey.withValues(alpha: 0.3),
                ),
                const SizedBox(height: AppSpacing.md16),
                Text(
                  'No tasks yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.slateGrey,
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final sites = tasksBySite.keys.toList();
        final siteName = sites[index];
        final siteTasks = tasksBySite[siteName]!;

        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md16,
                  vertical: AppSpacing.sm12,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: AppColors.constructionGold,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      siteName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: AppTypography.semiBold,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.constructionGold.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXs,
                        ),
                      ),
                      child: Text(
                        '${siteTasks.length} tasks',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.constructionGold,
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...siteTasks.map((task) {
                return TaskCard(
                  task: task,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppConstants.taskDetailsRoute,
                      arguments: task.id,
                    );
                  },
                );
              }),
            ],
          ),
        );
      }, childCount: tasksBySite.length),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showCreateTaskBottomSheet,
      icon: const Icon(Icons.add_rounded),
      label: const Text('New Task'),
      tooltip: 'Create a new task',
      elevation: AppSpacing.elevationMd,
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.constructionGold),
          ),
          const SizedBox(height: AppSpacing.md16),
          Text(
            'Loading dashboard...',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.slateGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildTabHeader(String title, {List<Widget> actions = const []}) {
    return Container(
      color: AppColors.deepNavy,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md16,
            AppSpacing.sm12,
            AppSpacing.sm12,
            AppSpacing.sm12,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: AppTypography.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              ...actions,
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.white),
                onPressed: _handleLogout,
                tooltip: 'Logout',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllTasksTab() {
    return Column(
      children: [
        _buildTabHeader(
          'All Tasks (${_allTasks.length})',
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded, color: AppColors.white),
              tooltip: 'Create Task',
              onPressed: _showCreateTaskBottomSheet,
            ),
          ],
        ),
        Expanded(
          child: _allTasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 64,
                        color: AppColors.slateGrey.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: AppSpacing.md16),
                      Text(
                        'No tasks yet',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.slateGrey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md16),
                  itemCount: _allTasks.length,
                  itemBuilder: (context, index) {
                    final task = _allTasks[index];
                    return _buildAdminTaskTile(task);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAdminTaskTile(Task task) {
    final statusColors = {
      TaskStatus.pending: AppColors.statusPending,
      TaskStatus.inProgress: AppColors.statusInProgress,
      TaskStatus.verification: AppColors.statusVerification,
      TaskStatus.completed: AppColors.statusCompleted,
      TaskStatus.cancelled: AppColors.statusCancelled,
    };
    final statusColor = statusColors[task.status] ?? AppColors.slateGrey;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm12),
      color: AppColors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md16,
          vertical: 8,
        ),
        onTap: () => _viewTaskDetails(task),
        leading: Container(
          width: 4,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: AppTypography.bold,
            color: AppColors.deepNavy,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.siteLocation.siteName ?? 'Unknown Site',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.slateGrey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.status
                        .toString()
                        .split('.')
                        .last
                        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}')
                        .trim(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: AppTypography.semiBold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (task.isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Overdue',
                      style: TextStyle(
                        color: AppColors.errorRed,
                        fontSize: 10,
                        fontWeight: AppTypography.semiBold,
                      ),
                    ),
                  ),
              ],
            ),
            if (task.comments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 14,
                      color: AppColors.constructionGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.comments.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.constructionGold,
                        fontWeight: AppTypography.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          icon: const Icon(Icons.more_vert, color: AppColors.slateGrey),
          onSelected: (value) => _handleTaskAction(value, task),
          itemBuilder: (_) => [
            PopupMenuItem<String>(
              value: 'pending',
              child: Row(
                children: [
                  const Icon(
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
                  const Icon(
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
                  const Icon(
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
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppColors.statusCompleted,
                  ),
                  const SizedBox(width: 12),
                  const Text('Mark Completed'),
                ],
              ),
            ),
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
        ),
      ),
    );
  }

  /// View task details
  void _viewTaskDetails(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EmployeeTaskDetailsScreen(task: task, employeeId: task.assignedTo),
      ),
    );
  }

  Future<void> _handleTaskAction(String action, Task task) async {
    try {
      // Validate task ID
      if (task.id.isEmpty) {
        debugPrint('⚠️ Warning: Task ID is empty for task: ${task.title}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Error: Task not properly loaded. Please try again.',
              ),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
        return;
      }

      if (action == 'delete') {
        debugPrint(
          '🗑️ Delete action triggered for task: ${task.id} (${task.title})',
        );
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Task'),
            content: Text('Delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed != true) {
          debugPrint('🚫 Delete cancelled by user for task: ${task.id}');
          return;
        }
        debugPrint('✅ Delete confirmed for task: ${task.id}');
        await AppConfig.taskService.deleteTask(task.id);
        debugPrint('✅ Delete operation completed for task: ${task.id}');
      } else {
        final status = _convertStringToTaskStatus(action);
        await AppConfig.taskService.updateTaskStatus(task.id, status);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'delete' ? 'Task deleted' : 'Task updated'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error in _handleTaskAction: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Widget _buildEmployeesTab() {
    return Column(
      children: [
        _buildTabHeader(
          'Employees',
          actions: [
            IconButton(
              icon: const Icon(
                Icons.person_add_rounded,
                color: AppColors.white,
              ),
              tooltip: 'Add Employee',
              onPressed: _showAddEmployeeDialog,
            ),
          ],
        ),
        Expanded(
          child: FutureBuilder<List<User>>(
            future: AppConfig.authService.getUsersByRole(UserRole.employee),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading employees: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.errorRed),
                  ),
                );
              }
              final employees = snapshot.data ?? [];
              if (employees.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_rounded,
                        size: 72,
                        color: AppColors.slateGrey.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: AppSpacing.md16),
                      Text(
                        'No employees yet',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.slateGrey),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _showAddEmployeeDialog,
                        icon: const Icon(Icons.person_add_rounded),
                        label: const Text('Add Employee'),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md16),
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final emp = employees[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md16),
                    elevation: 2,
                    color: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row with avatar and name
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.constructionGold
                                    .withValues(alpha: 0.2),
                                child: Text(
                                  emp.name.substring(0, 1).toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: AppColors.constructionGold,
                                        fontWeight: AppTypography.bold,
                                      ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md16),
                              // Name and designation
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      emp.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: AppTypography.bold,
                                            color: AppColors.deepNavy,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (emp.designation != null) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.infoBlue.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          emp.designation!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: AppColors.infoBlue,
                                                fontWeight:
                                                    AppTypography.semiBold,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md16),
                          // Email
                          Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 16,
                                color: AppColors.slateGrey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  emp.email,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.slateGrey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md16),
                          // Active status  toggle
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md16,
                              vertical: AppSpacing.sm12,
                            ),
                            decoration: BoxDecoration(
                              color: emp.isActive
                                  ? AppColors.successGreen.withValues(
                                      alpha: 0.1,
                                    )
                                  : AppColors.errorRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: emp.isActive
                                    ? AppColors.successGreen
                                    : AppColors.errorRed,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  emp.isActive ? 'Active' : 'Inactive',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: emp.isActive
                                            ? AppColors.successGreen
                                            : AppColors.errorRed,
                                        fontWeight: AppTypography.bold,
                                      ),
                                ),
                                Switch(
                                  value: emp.isActive,
                                  activeThumbColor: AppColors.white,
                                  activeTrackColor: AppColors.successGreen,
                                  inactiveThumbColor: AppColors.white
                                      .withValues(alpha: 0.8),
                                  inactiveTrackColor: AppColors.errorRed
                                      .withValues(alpha: 0.4),
                                  onChanged: (val) async {
                                    try {
                                      await AppConfig.authService
                                          .updateUserProfile(emp.id, {
                                            'isActive': val,
                                          });
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: AppColors.errorRed,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddEmployeeDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final designationCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool loading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Employee'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email (Login ID) *',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Password *',
                      prefixIcon: Icon(Icons.lock_outlined),
                    ),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 6) return 'Min 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Phone (optional)',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: designationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Designation (optional)',
                      prefixIcon: Icon(Icons.work_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => loading = true);
                      try {
                        await AppConfig.authService.createEmployee(
                          email: emailCtrl.text.trim(),
                          password: passCtrl.text,
                          name: nameCtrl.text.trim(),
                          phoneNumber: phoneCtrl.text.trim().isEmpty
                              ? null
                              : phoneCtrl.text.trim(),
                          designation: designationCtrl.text.trim().isEmpty
                              ? null
                              : designationCtrl.text.trim(),
                          company: _currentUser?.company,
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          setState(() {}); // refresh employees tab
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Employee ${nameCtrl.text.trim()} added!',
                              ),
                              backgroundColor: AppColors.successGreen,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => loading = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: AppColors.errorRed,
                            ),
                          );
                        }
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Create'),
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
            _buildTabHeader('Profile'),
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
                        Icons.business,
                        'Company',
                        _currentUser!.company ?? 'N/A',
                      ),
                      _buildInfoRow(
                        Icons.location_city,
                        'Site',
                        _currentUser!.assignedSites.isNotEmpty
                            ? _currentUser!.assignedSites.first
                            : 'N/A',
                      ),
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

  /// Convert string action to TaskStatus enum
  TaskStatus _convertStringToTaskStatus(String action) {
    switch (action) {
      case 'pending':
        return TaskStatus.pending;
      case 'inProgress':
        return TaskStatus.inProgress;
      case 'verification':
        return TaskStatus.verification;
      case 'completed':
        return TaskStatus.completed;
      case 'cancelled':
        return TaskStatus.cancelled;
      default:
        throw Exception('Invalid task status: $action');
    }
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
