class ServerModel {
  final String id;
  final String name;
  final String? iconUrl;
  final String description;
  final List<String> memberIds;
  final String createdBy;
  final DateTime createdAt;
  final List<ChannelModel> channels;

  ServerModel({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.description,
    required this.memberIds,
    required this.createdBy,
    required this.createdAt,
    required this.channels,
  });

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      id: json['id'],
      name: json['name'],
      iconUrl: json['iconUrl'],
      description: json['description'],
      memberIds: List<String>.from(json['memberIds'] ?? []),
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      channels: (json['channels'] as List?)
              ?.map((c) => ChannelModel.fromJson(c))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconUrl,
      'description': description,
      'memberIds': memberIds,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'channels': channels.map((c) => c.toJson()).toList(),
    };
  }
}

class ChannelModel {
  final String id;
  final String name;
  final String serverId;
  final ChannelType type;
  final String? description;
  final DateTime createdAt;

  ChannelModel({
    required this.id,
    required this.name,
    required this.serverId,
    required this.type,
    this.description,
    required this.createdAt,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['id'],
      name: json['name'],
      serverId: json['serverId'],
      type: ChannelType.values.firstWhere(
        (e) => e.toString() == 'ChannelType.${json['type']}',
        orElse: () => ChannelType.text,
      ),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'serverId': serverId,
      'type': type.toString().split('.').last,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum ChannelType {
  text,
  checklist,
  media,
  meeting,
}

class ChatMessage {
  final String id;
  final String channelId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final MessageType type;
  final List<String>? attachments;
  final DateTime timestamp;
  final bool isEdited;

  ChatMessage({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.type,
    this.attachments,
    required this.timestamp,
    this.isEdited = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      channelId: json['channelId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderAvatar: json['senderAvatar'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      timestamp: DateTime.parse(json['timestamp']),
      isEdited: json['isEdited'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channelId': channelId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'type': type.toString().split('.').last,
      'attachments': attachments,
      'timestamp': timestamp.toIso8601String(),
      'isEdited': isEdited,
    };
  }
}

enum MessageType {
  text,
  image,
  file,
  meetingLink,
}

enum TaskPriority {
  low,
  medium,
  high,
}

class ChecklistItem {
  final String id;
  final String channelId;
  final String title;
  final String? description;
  final bool isCompleted;
  final String? assignee;
  final DateTime? dueDate;
  final TaskPriority? priority;
  final DateTime createdAt;

  ChecklistItem({
    required this.id,
    required this.channelId,
    required this.title,
    this.description,
    required this.isCompleted,
    this.assignee,
    this.dueDate,
    this.priority,
    required this.createdAt,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'],
      channelId: json['channelId'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      assignee: json['assignee'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: json['priority'] != null
          ? TaskPriority.values.firstWhere(
              (e) => e.toString() == 'TaskPriority.${json['priority']}',
              orElse: () => TaskPriority.medium,
            )
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channelId': channelId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'assignee': assignee,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority?.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ChecklistItem copyWith({
    String? id,
    String? channelId,
    String? title,
    String? description,
    bool? isCompleted,
    String? assignee,
    DateTime? dueDate,
    TaskPriority? priority,
    DateTime? createdAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      assignee: assignee ?? this.assignee,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}