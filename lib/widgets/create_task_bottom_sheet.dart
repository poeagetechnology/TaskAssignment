import 'package:flutter/material.dart';
import '../config/index.dart';
import '../models/index.dart';

/// Bottom sheet for creating a new task
class CreateTaskBottomSheet extends StatefulWidget {
  /// Callback when task is created
  final Function(Task) onTaskCreated;

  /// Callback when bottom sheet is dismissed
  final VoidCallback? onDismiss;

  const CreateTaskBottomSheet({
    super.key,
    required this.onTaskCreated,
    this.onDismiss,
  });

  @override
  State<CreateTaskBottomSheet> createState() => _CreateTaskBottomSheetState();
}

class _CreateTaskBottomSheetState extends State<CreateTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _siteNameController = TextEditingController();
  final _deadlineDateController = TextEditingController();

  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDeadline;
  User? _selectedEmployee;
  List<User> _employees = [];
  bool _isLoading = false;
  bool _loadingEmployees = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      final list = await AppConfig.authService.getUsersByRole(
        UserRole.employee,
      );
      debugPrint('✅ Loaded ${list.length} employees:');
      for (final emp in list) {
        debugPrint('   - ${emp.name} (ID: ${emp.id})');
      }
      if (mounted) {
        setState(() {
          _employees = list;
          _loadingEmployees = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading employees: $e');
      if (mounted) {
        setState(() => _loadingEmployees = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _siteNameController.dispose();
    _deadlineDateController.dispose();
    super.dispose();
  }

  /// Select deadline date
  Future<void> _selectDeadlineDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
        _deadlineDateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  /// Create task from form data
  void _createTask() async {
    // First validate the form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    // Then check deadline
    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a deadline date'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    // Then check employee assignment
    if (_selectedEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please assign a task to an employee'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint('🔍 Creating task:');
      debugPrint(
        '   - Employee selected: ${_selectedEmployee!.name} (ID: ${_selectedEmployee!.id})',
      );
      debugPrint(
        '   - Current admin ID: ${AppConfig.authService.currentUserId}',
      );

      final task = Task(
        id: '', // Firestore will assign the ID
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        siteLocation: GpsLocation(siteName: _siteNameController.text.trim()),
        deadline: _selectedDeadline!,
        priority: _selectedPriority,
        status: TaskStatus.pending,
        assignedBy: AppConfig.authService.currentUserId ?? '',
        assignedTo: _selectedEmployee!.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      debugPrint('📝 Task object created: assignedTo=${task.assignedTo}');
      await AppConfig.taskService.createTask(task);
      debugPrint('✅ Task created successfully');
      widget.onTaskCreated(task);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Task created and assigned to ${_selectedEmployee!.name}!',
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating task: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.radiusLg),
              topRight: Radius.circular(AppSpacing.radiusLg),
            ),
          ),
          child: Column(
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create New Task',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: AppTypography.bold,
                            color: AppColors.deepNavy,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: AppColors.slateGrey,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Form content - scrollable
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: AppSpacing.md16,
                    right: AppSpacing.md16,
                    top: AppSpacing.md16,
                    bottom:
                        MediaQuery.of(context).viewInsets.bottom +
                        AppSpacing.md16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task Title
                        Text(
                          'Task Title',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontWeight: AppTypography.bold,
                                color: AppColors.deepNavy,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          style: TextStyle(
                            color: AppColors.deepNavy,
                            fontSize: AppTypography.fontSize16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g., Foundation Laying',
                            hintStyle: TextStyle(
                              color: AppColors.slateGrey.withValues(alpha: 0.6),
                            ),
                            filled: true,
                            fillColor: Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.deepNavy,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md16,
                              vertical: AppSpacing.md16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter task title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md16),

                        // Description (Optional)
                        Text(
                          'Description (Optional)',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontWeight: AppTypography.bold,
                                color: AppColors.deepNavy,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          style: TextStyle(
                            color: AppColors.deepNavy,
                            fontSize: AppTypography.fontSize16,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Provide detailed information about the task...',
                            hintStyle: TextStyle(
                              color: AppColors.slateGrey.withValues(alpha: 0.6),
                            ),
                            filled: true,
                            fillColor: Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.deepNavy,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md16,
                              vertical: AppSpacing.md16,
                            ),
                          ),
                          minLines: 3,
                          maxLines: 5,
                        ),
                        const SizedBox(height: AppSpacing.md16),

                        // Priority
                        Text(
                          'Priority Level',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontWeight: AppTypography.bold,
                                color: AppColors.deepNavy,
                              ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: TaskPriority.values.length,
                            itemBuilder: (context, index) {
                              final priority = TaskPriority.values[index];
                              final isSelected = _selectedPriority == priority;

                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index == TaskPriority.values.length - 1
                                      ? 0
                                      : AppSpacing.sm12,
                                ),
                                child: FilterChip(
                                  label: Text(
                                    priority
                                        .toString()
                                        .split('.')
                                        .last
                                        .toUpperCase(),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(
                                        () => _selectedPriority = priority,
                                      );
                                    }
                                  },
                                  backgroundColor: AppColors.white,
                                  selectedColor: _getPriorityColor(priority),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.slateGrey,
                                    fontWeight: AppTypography.semiBold,
                                  ),
                                  side: BorderSide(
                                    color: _getPriorityColor(priority),
                                    width: 1.5,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md16),

                        // Assign To Employee
                        Text(
                          'Assign To Employee',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontWeight: AppTypography.bold,
                                color: AppColors.deepNavy,
                              ),
                        ),
                        const SizedBox(height: 8),
                        _loadingEmployees
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : (_employees.isEmpty
                                  ? Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.md16,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.slateGrey.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusMd,
                                        ),
                                      ),
                                      child: Text(
                                        'No employees available. Please create employees first.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppColors.slateGrey,
                                            ),
                                      ),
                                    )
                                  : DropdownButtonFormField<User>(
                                      initialValue: _selectedEmployee,
                                      hint: const Text(
                                        'Select an employee',
                                        style: TextStyle(
                                          color: Color(0xFF9E9E9E),
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: AppColors.deepNavy,
                                        fontSize: AppTypography.fontSize16,
                                      ),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Color(0xFFF5F5F5),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusMd,
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(0xFFE0E0E0),
                                            width: 1.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusMd,
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(0xFFE0E0E0),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusMd,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.deepNavy,
                                            width: 2,
                                          ),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.person_outlined,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md16,
                                          vertical: AppSpacing.md16,
                                        ),
                                      ),
                                      items: _employees
                                          .map(
                                            (e) => DropdownMenuItem<User>(
                                              value: e,
                                              child: Text(
                                                e.name,
                                                style: TextStyle(
                                                  color: AppColors.deepNavy,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) => setState(
                                        () => _selectedEmployee = val,
                                      ),
                                      validator: (v) => v == null
                                          ? 'Please select an employee'
                                          : null,
                                      dropdownColor: AppColors.white,
                                    )),
                        const SizedBox(height: AppSpacing.md16),

                        // Site Information
                        Text(
                          'Site Information',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: AppTypography.bold,
                                color: AppColors.deepNavy,
                              ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Site Name',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontWeight: AppTypography.semiBold,
                                color: AppColors.deepNavy,
                              ),
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _siteNameController,
                          style: TextStyle(
                            color: AppColors.deepNavy,
                            fontSize: AppTypography.fontSize16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g., Project XYZ Site',
                            hintStyle: TextStyle(
                              color: AppColors.slateGrey.withValues(alpha: 0.6),
                            ),
                            filled: true,
                            fillColor: Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.deepNavy,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md16,
                              vertical: AppSpacing.md16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter site name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md16),

                        // Deadline
                        Text(
                          'Deadline Date',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontWeight: AppTypography.bold,
                                color: AppColors.deepNavy,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _deadlineDateController,
                          readOnly: true,
                          onTap: _selectDeadlineDate,
                          style: TextStyle(
                            color: AppColors.deepNavy,
                            fontSize: AppTypography.fontSize16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Select deadline date',
                            hintStyle: TextStyle(
                              color: AppColors.slateGrey.withValues(alpha: 0.6),
                            ),
                            suffixIcon: Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.deepNavy,
                            ),
                            filled: true,
                            fillColor: Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.deepNavy,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md16,
                              vertical: AppSpacing.md16,
                            ),
                          ),
                          validator: (value) {
                            if (_selectedDeadline == null) {
                              return 'Please select a deadline date';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl24),

                        // Create Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _createTask,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.constructionGold,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        AppColors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Create Task',
                                    style: TextStyle(
                                      fontSize: AppTypography.fontSize16,
                                      fontWeight: AppTypography.bold,
                                      color: AppColors.deepNavy,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Get priority color
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical:
        return AppColors.priorityCritical;
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }
}
