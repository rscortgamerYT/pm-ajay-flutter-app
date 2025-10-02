import 'package:equatable/equatable.dart';

/// Represents a message in a project discussion
class Message extends Equatable {
  final String id;
  final String projectId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final List<String> attachments;
  final String? replyToId;
  final List<String> mentions;
  final bool isEdited;
  final DateTime? editedAt;
  final Map<String, dynamic> metadata;

  const Message({
    required this.id,
    required this.projectId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.type,
    this.attachments = const [],
    this.replyToId,
    this.mentions = const [],
    this.isEdited = false,
    this.editedAt,
    this.metadata = const {},
  });

  Message copyWith({
    String? id,
    String? projectId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    List<String>? attachments,
    String? replyToId,
    List<String>? mentions,
    bool? isEdited,
    DateTime? editedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
      replyToId: replyToId ?? this.replyToId,
      mentions: mentions ?? this.mentions,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'attachments': attachments,
      'replyToId': replyToId,
      'mentions': mentions,
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      replyToId: json['replyToId'] as String?,
      mentions: (json['mentions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isEdited: json['isEdited'] as bool? ?? false,
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        senderId,
        senderName,
        content,
        timestamp,
        type,
        attachments,
        replyToId,
        mentions,
        isEdited,
        editedAt,
        metadata,
      ];
}

enum MessageType {
  text,
  image,
  file,
  system,
  announcement,
}

/// Represents a task assignment
class TaskAssignment extends Equatable {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String assignerId;
  final String assigneeId;
  final String assigneeName;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final List<String> attachments;
  final List<String> tags;
  final Map<String, dynamic> metadata;

  const TaskAssignment({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.assignerId,
    required this.assigneeId,
    required this.assigneeName,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.dueDate,
    this.completedAt,
    this.attachments = const [],
    this.tags = const [],
    this.metadata = const {},
  });

  TaskAssignment copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    String? assignerId,
    String? assigneeId,
    String? assigneeName,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? completedAt,
    List<String>? attachments,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return TaskAssignment(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignerId: assignerId ?? this.assignerId,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      attachments: attachments ?? this.attachments,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'assignerId': assignerId,
      'assigneeId': assigneeId,
      'assigneeName': assigneeName,
      'priority': priority.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'attachments': attachments,
      'tags': tags,
      'metadata': metadata,
    };
  }

  factory TaskAssignment.fromJson(Map<String, dynamic> json) {
    return TaskAssignment(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      assignerId: json['assignerId'] as String,
      assigneeId: json['assigneeId'] as String,
      assigneeName: json['assigneeName'] as String,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        title,
        description,
        assignerId,
        assigneeId,
        assigneeName,
        priority,
        status,
        createdAt,
        dueDate,
        completedAt,
        attachments,
        tags,
        metadata,
      ];
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

enum TaskStatus {
  pending,
  inProgress,
  review,
  completed,
  cancelled,
}