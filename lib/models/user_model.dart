import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// Enum for user roles
enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('employee')
  employee,
}

/// User model for role-based access control
@JsonSerializable()
class User {
  /// Unique identifier (Firebase UID)
  final String id;

  /// User's full name
  final String name;

  /// User's email address
  final String email;

  /// User's phone number
  final String? phoneNumber;

  /// User's role in the system
  final UserRole role;

  /// URL to user's profile picture
  final String? profilePictureUrl;

  /// Company or organization name
  final String? company;

  /// List of site IDs the user has access to
  final List<String> assignedSites;

  /// Whether the user is active
  final bool isActive;

  /// Account creation timestamp
  final DateTime createdAt;

  /// Last updated timestamp
  final DateTime updatedAt;

  /// Last login timestamp
  final DateTime? lastLoginAt;

  /// User's designation/title
  final String? designation;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.profilePictureUrl,
    this.company,
    this.assignedSites = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.designation,
  });

  /// Copy with method for immutability
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    UserRole? role,
    String? profilePictureUrl,
    String? company,
    List<String>? assignedSites,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    String? designation,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      company: company ?? this.company,
      assignedSites: assignedSites ?? this.assignedSites,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      designation: designation ?? this.designation,
    );
  }

  /// Check if user is an admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if user is an employee
  bool get isEmployee => role == UserRole.employee;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() => 'User(id: $id, name: $name, role: $role)';
}
