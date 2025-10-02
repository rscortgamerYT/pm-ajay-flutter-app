import 'package:equatable/equatable.dart';

/// Represents a compliance checklist for project monitoring
class ComplianceChecklist extends Equatable {
  final String id;
  final String projectId;
  final String name;
  final String description;
  final ComplianceCategory category;
  final List<ChecklistItem> items;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String createdBy;
  final ComplianceStatus status;
  final Map<String, dynamic> metadata;

  const ComplianceChecklist({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.category,
    required this.items,
    required this.createdAt,
    this.completedAt,
    required this.createdBy,
    required this.status,
    this.metadata = const {},
  });

  ComplianceChecklist copyWith({
    String? id,
    String? projectId,
    String? name,
    String? description,
    ComplianceCategory? category,
    List<ChecklistItem>? items,
    DateTime? createdAt,
    DateTime? completedAt,
    String? createdBy,
    ComplianceStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return ComplianceChecklist(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  double get completionPercentage {
    if (items.isEmpty) return 0.0;
    final completedCount = items.where((item) => item.isCompleted).length;
    return completedCount / items.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'description': description,
      'category': category.name,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'createdBy': createdBy,
      'status': status.name,
      'metadata': metadata,
    };
  }

  factory ComplianceChecklist.fromJson(Map<String, dynamic> json) {
    return ComplianceChecklist(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: ComplianceCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ComplianceCategory.general,
      ),
      items: (json['items'] as List<dynamic>)
          .map((item) => ChecklistItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      createdBy: json['createdBy'] as String,
      status: ComplianceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ComplianceStatus.pending,
      ),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        name,
        description,
        category,
        items,
        createdAt,
        completedAt,
        createdBy,
        status,
        metadata,
      ];
}

/// Individual item in a compliance checklist
class ChecklistItem extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? completedBy;
  final List<String> attachments;
  final String? notes;
  final bool isRequired;

  const ChecklistItem({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.completedAt,
    this.completedBy,
    this.attachments = const [],
    this.notes,
    this.isRequired = true,
  });

  ChecklistItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completedAt,
    String? completedBy,
    List<String>? attachments,
    String? notes,
    bool? isRequired,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      attachments: attachments ?? this.attachments,
      notes: notes ?? this.notes,
      isRequired: isRequired ?? this.isRequired,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'completedBy': completedBy,
      'attachments': attachments,
      'notes': notes,
      'isRequired': isRequired,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      completedBy: json['completedBy'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      notes: json['notes'] as String?,
      isRequired: json['isRequired'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        isCompleted,
        completedAt,
        completedBy,
        attachments,
        notes,
        isRequired,
      ];
}

/// Represents an audit trail entry
class AuditTrail extends Equatable {
  final String id;
  final String projectId;
  final String userId;
  final String userName;
  final AuditAction action;
  final String entityType;
  final String entityId;
  final String? entityName;
  final DateTime timestamp;
  final Map<String, dynamic>? previousData;
  final Map<String, dynamic>? newData;
  final String? notes;
  final String ipAddress;
  final Map<String, dynamic> metadata;

  const AuditTrail({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.userName,
    required this.action,
    required this.entityType,
    required this.entityId,
    this.entityName,
    required this.timestamp,
    this.previousData,
    this.newData,
    this.notes,
    required this.ipAddress,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'userId': userId,
      'userName': userName,
      'action': action.name,
      'entityType': entityType,
      'entityId': entityId,
      'entityName': entityName,
      'timestamp': timestamp.toIso8601String(),
      'previousData': previousData,
      'newData': newData,
      'notes': notes,
      'ipAddress': ipAddress,
      'metadata': metadata,
    };
  }

  factory AuditTrail.fromJson(Map<String, dynamic> json) {
    return AuditTrail(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      action: AuditAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => AuditAction.other,
      ),
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      entityName: json['entityName'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      previousData: json['previousData'] as Map<String, dynamic>?,
      newData: json['newData'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
      ipAddress: json['ipAddress'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        userId,
        userName,
        action,
        entityType,
        entityId,
        entityName,
        timestamp,
        previousData,
        newData,
        notes,
        ipAddress,
        metadata,
      ];
}

enum ComplianceCategory {
  environmental,
  safety,
  legal,
  financial,
  technical,
  quality,
  general,
}

enum ComplianceStatus {
  pending,
  inProgress,
  completed,
  failed,
  exempt,
}

enum AuditAction {
  create,
  update,
  delete,
  approve,
  reject,
  submit,
  review,
  export,
  access,
  other,
}