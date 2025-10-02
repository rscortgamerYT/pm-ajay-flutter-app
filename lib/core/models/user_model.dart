import 'package:equatable/equatable.dart';
import 'permission_model.dart';

/// Represents an authenticated user in the PM-AJAY system
class AppUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? phone;
  final String? whatsapp;
  final String? profileImageUrl;
  final String? department;
  final String? designation;
  final List<Permission> permissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? metadata;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.whatsapp,
    this.profileImageUrl,
    this.department,
    this.designation,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
    this.metadata,
  });

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? phone,
    String? whatsapp,
    String? profileImageUrl,
    String? department,
    String? designation,
    List<Permission>? permissions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? metadata,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'phone': phone,
      'whatsapp': whatsapp,
      'profileImageUrl': profileImageUrl,
      'department': department,
      'designation': designation,
      'permissions': permissions.map((p) => p.name).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.citizen,
      ),
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((p) => Permission.values.firstWhere(
                    (perm) => perm.name == p,
                    orElse: () => Permission.viewProjects,
                  ))
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        role,
        phone,
        whatsapp,
        profileImageUrl,
        department,
        designation,
        permissions,
        isActive,
        createdAt,
        lastLoginAt,
        metadata,
      ];
}

/// User roles in the PM-AJAY system
enum UserRole {
  superAdmin,
  admin,
  officer,
  citizen,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Administrator';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.officer:
        return 'Government Officer';
      case UserRole.citizen:
        return 'Citizen';
    }
  }

  String get description {
    switch (this) {
      case UserRole.superAdmin:
        return 'Full system access with all permissions';
      case UserRole.admin:
        return 'Administrative access to manage projects, funds, and agencies';
      case UserRole.officer:
        return 'Field officer with project management capabilities';
      case UserRole.citizen:
        return 'Public access to view projects and submit reports';
    }
  }
}