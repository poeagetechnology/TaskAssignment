import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../config/index.dart';
import '../models/index.dart';
import '../services/index.dart';

/// Task Completion Form for employees to submit task completion evidence
/// Includes photo capture, material/labor details, and Firestore status update
class TaskCompletionForm extends StatefulWidget {
  final Task task;
  final String employeeId;
  final VoidCallback? onCompletionSuccess;

  const TaskCompletionForm({
    required this.task,
    required this.employeeId,
    this.onCompletionSuccess,
    super.key,
  });

  @override
  State<TaskCompletionForm> createState() => _TaskCompletionFormState();
}

class _TaskCompletionFormState extends State<TaskCompletionForm> {
  final _formKey = GlobalKey<FormState>();
  final _materialUsedController = TextEditingController();
  final _laborCountController = TextEditingController();
  final _imagePicker = ImagePicker();

  final List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _showSuccessAnimation = false;

  late TaskService _taskService;
  late StorageService _storageService;

  @override
  void initState() {
    super.initState();
    _taskService = TaskService();
    _storageService = StorageService();
  }

  @override
  void dispose() {
    _materialUsedController.dispose();
    _laborCountController.dispose();
    super.dispose();
  }

  /// Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image added successfully'),
              duration: Duration(seconds: 2),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Remove image from selected images
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// Upload images to Firebase Storage
  Future<List<String>> _uploadImages() async {
    try {
      final urls = <String>[];

      for (var imageFile in _selectedImages) {
        final url = await _storageService.uploadTaskImage(
          imageFile: imageFile,
          taskId: widget.task.id,
          imageType: 'completion',
        );
        urls.add(url);
      }

      return urls;
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  /// Submit task completion for approval
  Future<void> _submitForApproval() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one completion photo'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Show loading overlay
      if (mounted) {
        _showLoadingOverlay();
      }

      // Upload images to Firebase Storage
      final imageUrls = await _uploadImages();

      // Create image attachments
      const uuid = Uuid();
      final imageAttachments = imageUrls
          .map(
            (url) => ImageAttachment(
              id: uuid.v4(),
              url: url,
              type: 'completion',
              uploadedAt: DateTime.now(),
              caption: 'Task completion evidence - ${DateTime.now().toLocal()}',
            ),
          )
          .toList();

      // Update task with completion details
      final updatedTask = widget.task.copyWith(
        status: TaskStatus.verification,
        imageAttachments: [
          ...widget.task.imageAttachments,
          ...imageAttachments,
        ],
        notes:
            '${widget.task.notes ?? ''}\n\n[Completion Submission]\n'
            'Material Used: ${_materialUsedController.text}\n'
            'Labor Count: ${_laborCountController.text}\n'
            'Submitted at: ${DateTime.now().toLocal()}',
        updatedAt: DateTime.now(),
      );

      // Update task in Firestore
      await _taskService.updateTask(widget.task.id, updatedTask);

      // Add image attachments to Firestore
      for (var attachment in imageAttachments) {
        await _taskService.addImageAttachment(widget.task.id, attachment);
      }

      // Hide loading overlay
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Show success animation
      setState(() {
        _showSuccessAnimation = true;
        _isLoading = false;
      });

      // Wait for animation to complete
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task submitted for approval successfully!'),
            duration: const Duration(seconds: 3),
            backgroundColor: AppColors.successGreen,
          ),
        );

        // Callback
        widget.onCompletionSuccess?.call();

        // Navigate back
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // Hide loading overlay
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show loading overlay
  void _showLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Semi-transparent background
            Container(color: Colors.black.withValues(alpha: 0.5)),
            // Loading content
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Loading spinner
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.deepNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Uploading completion details...',
                    style: AppTheme.lightTheme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while we process your photos',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main form
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complete Task',
                              style: AppTheme.lightTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.deepNavy,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Task: ${widget.task.title}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFE0E0E0),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Task info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.constructionGold.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.constructionGold.withValues(
                          alpha: 0.4,
                        ),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.constructionGold,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.task.siteLocation.siteName ?? 'Site',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.deepNavy,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              if (widget.task.siteLocation.address != null)
                                Text(
                                  widget.task.siteLocation.address!,
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Photo upload section
                  Text(
                    'Construction Site Photos',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepNavy,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Image preview grid
                  if (_selectedImages.isNotEmpty) ...[
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            // Image thumbnail
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Remove button
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Photo buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text(
                            'Take Photo',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: AppColors.deepNavy,
                              width: 2,
                            ),
                            foregroundColor: AppColors.deepNavy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.image_outlined),
                          label: const Text(
                            'Choose from Gallery',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: AppColors.deepNavy,
                              width: 2,
                            ),
                            foregroundColor: AppColors.deepNavy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Material Used field
                  Text(
                    'Materials Used',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _materialUsedController,
                    style: TextStyle(color: AppColors.deepNavy, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'e.g., Cement, Steel, Bricks, Paint...',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.deepNavy,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    minLines: 3,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter materials used';
                      }
                      if (value.length < 5) {
                        return 'Please provide more details';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Labor Count field
                  Text(
                    'Labor Count (Number of Workers)',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _laborCountController,
                    style: TextStyle(color: AppColors.deepNavy, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Enter number of workers',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.deepNavy,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.people_outlined,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter labor count';
                      }
                      final number = int.tryParse(value);
                      if (number == null || number <= 0) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submitForApproval,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.deepNavy,
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Submit for Approval',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Info text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFFFB74D), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFFF57C00),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Once submitted, your task will be sent for verification by the admin.',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                                  color: Color(0xFFF57C00),
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Success animation overlay
        if (_showSuccessAnimation)
          Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Lottie success animation
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Lottie.asset(
                            'assets/animations/success.json',
                            repeat: false,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Success! 🎉',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.successGreen,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your task completion has been\nsubmitted for verification',
                          textAlign: TextAlign.center,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600], height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
