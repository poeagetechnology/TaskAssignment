// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  profilePictureUrl: json['profilePictureUrl'] as String?,
  company: json['company'] as String?,
  assignedSites:
      (json['assignedSites'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  designation: json['designation'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'role': _$UserRoleEnumMap[instance.role]!,
  'profilePictureUrl': instance.profilePictureUrl,
  'company': instance.company,
  'assignedSites': instance.assignedSites,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'designation': instance.designation,
};

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.employee: 'employee',
};
