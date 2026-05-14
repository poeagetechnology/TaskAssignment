// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GpsLocation _$GpsLocationFromJson(Map<String, dynamic> json) => GpsLocation(
  siteName: json['siteName'] as String?,
  address: json['address'] as String?,
);

Map<String, dynamic> _$GpsLocationToJson(GpsLocation instance) =>
    <String, dynamic>{
      'siteName': instance.siteName,
      'address': instance.address,
    };

ImageAttachment _$ImageAttachmentFromJson(Map<String, dynamic> json) =>
    ImageAttachment(
      id: json['id'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      caption: json['caption'] as String?,
    );

Map<String, dynamic> _$ImageAttachmentToJson(ImageAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'type': instance.type,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
      'caption': instance.caption,
    };

CommentReaction _$CommentReactionFromJson(Map<String, dynamic> json) =>
    CommentReaction(
      emoji: json['emoji'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CommentReactionToJson(CommentReaction instance) =>
    <String, dynamic>{
      'emoji': instance.emoji,
      'userId': instance.userId,
      'userName': instance.userName,
      'createdAt': instance.createdAt.toIso8601String(),
    };

CommentReply _$CommentReplyFromJson(Map<String, dynamic> json) => CommentReply(
  id: json['id'] as String,
  authorId: json['authorId'] as String,
  authorName: json['authorName'] as String,
  text: json['text'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  reactions:
      (json['reactions'] as List<dynamic>?)
          ?.map((e) => CommentReaction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$CommentReplyToJson(CommentReply instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'text': instance.text,
      'createdAt': instance.createdAt.toIso8601String(),
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
    };

TaskComment _$TaskCommentFromJson(Map<String, dynamic> json) => TaskComment(
  id: json['id'] as String,
  authorId: json['authorId'] as String,
  authorName: json['authorName'] as String,
  text: json['text'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  replies:
      (json['replies'] as List<dynamic>?)
          ?.map((e) => CommentReply.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  reactions:
      (json['reactions'] as List<dynamic>?)
          ?.map((e) => CommentReaction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isPinned: json['isPinned'] as bool? ?? false,
);

Map<String, dynamic> _$TaskCommentToJson(TaskComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'text': instance.text,
      'createdAt': instance.createdAt.toIso8601String(),
      'replies': instance.replies.map((e) => e.toJson()).toList(),
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
      'isPinned': instance.isPinned,
    };

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  siteLocation: GpsLocation.fromJson(
    json['siteLocation'] as Map<String, dynamic>,
  ),
  deadline: DateTime.parse(json['deadline'] as String),
  priority: $enumDecode(_$TaskPriorityEnumMap, json['priority']),
  status: $enumDecode(_$TaskStatusEnumMap, json['status']),
  assignedBy: json['assignedBy'] as String,
  assignedTo: json['assignedTo'] as String,
  imageAttachments:
      (json['imageAttachments'] as List<dynamic>?)
          ?.map((e) => ImageAttachment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  notes: json['notes'] as String?,
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => TaskComment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  estimatedHours: (json['estimatedHours'] as num?)?.toInt(),
  actualHours: (json['actualHours'] as num?)?.toInt(),
  budgetAmount: (json['budgetAmount'] as num?)?.toDouble(),
);

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'siteLocation': instance.siteLocation.toJson(),
  'deadline': instance.deadline.toIso8601String(),
  'priority': _$TaskPriorityEnumMap[instance.priority]!,
  'status': _$TaskStatusEnumMap[instance.status]!,
  'assignedBy': instance.assignedBy,
  'assignedTo': instance.assignedTo,
  'imageAttachments': instance.imageAttachments.map((e) => e.toJson()).toList(),
  'notes': instance.notes,
  'comments': instance.comments.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'estimatedHours': instance.estimatedHours,
  'actualHours': instance.actualHours,
  'budgetAmount': instance.budgetAmount,
};

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
  TaskPriority.critical: 'critical',
};

const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'pending',
  TaskStatus.inProgress: 'in_progress',
  TaskStatus.verification: 'verification',
  TaskStatus.completed: 'completed',
  TaskStatus.cancelled: 'cancelled',
};
