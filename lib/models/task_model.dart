import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

/// Enum for task priority levels
enum TaskPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

/// Enum for task status
enum TaskStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('verification')
  verification,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

/// Represents a geographical location with site information
@JsonSerializable()
class GpsLocation {
  final String? siteName;
  final String? address;

  GpsLocation({this.siteName, this.address});

  factory GpsLocation.fromJson(Map<String, dynamic> json) =>
      _$GpsLocationFromJson(json);

  Map<String, dynamic> toJson() => _$GpsLocationToJson(this);
}

/// Image attachment for task (Before/After proof)
@JsonSerializable()
class ImageAttachment {
  final String id;
  final String url;
  final String type; // 'before' or 'after'
  final DateTime uploadedAt;
  final String? caption;

  ImageAttachment({
    required this.id,
    required this.url,
    required this.type,
    required this.uploadedAt,
    this.caption,
  });

  factory ImageAttachment.fromJson(Map<String, dynamic> json) =>
      _$ImageAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$ImageAttachmentToJson(this);
}

/// Reaction to a task comment (emoji reaction)
@JsonSerializable()
class CommentReaction {
  final String emoji;
  final String userId;
  final String userName;
  final DateTime createdAt;

  CommentReaction({
    required this.emoji,
    required this.userId,
    required this.userName,
    required this.createdAt,
  });

  factory CommentReaction.fromJson(Map<String, dynamic> json) =>
      _$CommentReactionFromJson(json);

  Map<String, dynamic> toJson() => _$CommentReactionToJson(this);
}

/// Reply to a task comment
@JsonSerializable()
class CommentReply {
  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;
  final List<CommentReaction> reactions;

  CommentReply({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
    this.reactions = const [],
  });

  factory CommentReply.fromJson(Map<String, dynamic> json) =>
      _$CommentReplyFromJson(json);

  Map<String, dynamic> toJson() => _$CommentReplyToJson(this);
}

/// Task comment/note with author information, replies, and reactions
@JsonSerializable()
class TaskComment {
  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;
  final List<CommentReply> replies;
  final List<CommentReaction> reactions;
  final bool isPinned;

  TaskComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
    this.replies = const [],
    this.reactions = const [],
    this.isPinned = false,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) =>
      _$TaskCommentFromJson(json);

  Map<String, dynamic> toJson() => _$TaskCommentToJson(this);

  /// Create a copy of this comment with modified fields
  TaskComment copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? text,
    DateTime? createdAt,
    List<CommentReply>? replies,
    List<CommentReaction>? reactions,
    bool? isPinned,
  }) {
    return TaskComment(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
      reactions: reactions ?? this.reactions,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  /// Add a reply to this comment
  TaskComment copyWithReply(CommentReply reply) {
    return copyWith(replies: [...replies, reply]);
  }

  /// Add a reaction to this comment
  TaskComment copyWithReaction(CommentReaction reaction) {
    return copyWith(reactions: [...reactions, reaction]);
  }

  /// Remove a reaction from this comment
  TaskComment removeReaction(String emoji, String userId) {
    final updatedReactions = reactions.where((r) {
      return !(r.emoji == emoji && r.userId == userId);
    }).toList();
    return copyWith(reactions: updatedReactions);
  }
}

/// Main Task model for Civil Construction Task Management
@JsonSerializable()
class Task {
  /// Unique identifier for the task
  final String id;

  /// Task title
  final String title;

  /// Detailed description of the task
  final String description;

  /// Site location with GPS coordinates
  final GpsLocation siteLocation;

  /// Task deadline
  final DateTime deadline;

  /// Priority level of the task
  final TaskPriority priority;

  /// Current status of the task
  final TaskStatus status;

  /// User ID of the admin/project manager who assigned the task
  final String assignedBy;

  /// User ID of the employee who is assigned the task
  final String assignedTo;

  /// List of image attachments for before/after proof
  final List<ImageAttachment> imageAttachments;

  /// Additional notes or comments
  final String? notes;

  /// Task comments with author information
  final List<TaskComment> comments;

  /// Timestamp when task was created
  final DateTime createdAt;

  /// Timestamp when task was last updated
  final DateTime updatedAt;

  /// Estimated duration in hours
  final int? estimatedHours;

  /// Actual time spent in hours
  final int? actualHours;

  /// Budget allocated for the task
  final double? budgetAmount;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.siteLocation,
    required this.deadline,
    required this.priority,
    required this.status,
    required this.assignedBy,
    required this.assignedTo,
    this.imageAttachments = const [],
    this.notes,
    this.comments = const [],
    required this.createdAt,
    required this.updatedAt,
    this.estimatedHours,
    this.actualHours,
    this.budgetAmount,
  });

  /// Create a copy of this task with some fields replaced
  Task copyWith({
    String? id,
    String? title,
    String? description,
    GpsLocation? siteLocation,
    DateTime? deadline,
    TaskPriority? priority,
    TaskStatus? status,
    String? assignedBy,
    String? assignedTo,
    List<ImageAttachment>? imageAttachments,
    String? notes,
    List<TaskComment>? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? estimatedHours,
    int? actualHours,
    double? budgetAmount,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      siteLocation: siteLocation ?? this.siteLocation,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedBy: assignedBy ?? this.assignedBy,
      assignedTo: assignedTo ?? this.assignedTo,
      imageAttachments: imageAttachments ?? this.imageAttachments,
      notes: notes ?? this.notes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      budgetAmount: budgetAmount ?? this.budgetAmount,
    );
  }

  /// Check if task is overdue
  bool get isOverdue =>
      DateTime.now().isAfter(deadline) && status != TaskStatus.completed;

  /// Get progress percentage based on status
  int get progressPercentage {
    switch (status) {
      case TaskStatus.pending:
        return 0;
      case TaskStatus.inProgress:
        return 50;
      case TaskStatus.verification:
        return 75;
      case TaskStatus.completed:
        return 100;
      case TaskStatus.cancelled:
        return 0;
    }
  }

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$TaskToJson(this);
    // Ensure nested objects are properly serialized
    json['siteLocation'] = siteLocation.toJson();
    json['imageAttachments'] = imageAttachments.map((e) => e.toJson()).toList();
    json['comments'] = comments.map((e) => e.toJson()).toList();
    return json;
  }

  @override
  String toString() =>
      'Task(id: $id, title: $title, status: $status, priority: $priority)';
}
