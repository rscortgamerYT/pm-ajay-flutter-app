import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pm_ajay/features/collaboration_hub/models/server_model.dart';

// State provider for selected server
final selectedServerProvider = StateProvider<ServerModel?>((ref) => null);

// State provider for selected channel
final selectedChannelProvider = StateProvider<ChannelModel?>((ref) => null);

// Provider for list of servers
final serversProvider = StateNotifierProvider<ServersNotifier, List<ServerModel>>((ref) {
  return ServersNotifier();
});

class ServersNotifier extends StateNotifier<List<ServerModel>> {
  ServersNotifier() : super([]) {
    _initializeDemoServers();
  }

  void _initializeDemoServers() {
    state = [
      ServerModel(
        id: 'server-1',
        name: 'PM-AJAY Central',
        description: 'Main coordination server for PM-AJAY officials',
        memberIds: ['user-1', 'user-2', 'user-3'],
        createdBy: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        channels: [
          ChannelModel(
            id: 'channel-1',
            name: 'general',
            serverId: 'server-1',
            type: ChannelType.text,
            description: 'General discussion',
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
          ),
          ChannelModel(
            id: 'channel-2',
            name: 'project-updates',
            serverId: 'server-1',
            type: ChannelType.text,
            description: 'Share project progress',
            createdAt: DateTime.now().subtract(const Duration(days: 25)),
          ),
          ChannelModel(
            id: 'channel-3',
            name: 'action-items',
            serverId: 'server-1',
            type: ChannelType.checklist,
            description: 'Track tasks and deliverables',
            createdAt: DateTime.now().subtract(const Duration(days: 20)),
          ),
          ChannelModel(
            id: 'channel-4',
            name: 'media-gallery',
            serverId: 'server-1',
            type: ChannelType.media,
            description: 'Share images and documents',
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
          ),
        ],
      ),
      ServerModel(
        id: 'server-2',
        name: 'Regional Teams',
        description: 'Regional coordination workspace',
        memberIds: ['user-1', 'user-4', 'user-5'],
        createdBy: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        channels: [
          ChannelModel(
            id: 'channel-5',
            name: 'north-zone',
            serverId: 'server-2',
            type: ChannelType.text,
            description: 'North zone coordination',
            createdAt: DateTime.now().subtract(const Duration(days: 20)),
          ),
          ChannelModel(
            id: 'channel-6',
            name: 'south-zone',
            serverId: 'server-2',
            type: ChannelType.text,
            description: 'South zone coordination',
            createdAt: DateTime.now().subtract(const Duration(days: 20)),
          ),
        ],
      ),
    ];
  }

  void addServer(ServerModel server) {
    state = [...state, server];
  }

  void updateServer(ServerModel updatedServer) {
    state = [
      for (final server in state)
        if (server.id == updatedServer.id) updatedServer else server
    ];
  }

  void deleteServer(String serverId) {
    state = state.where((server) => server.id != serverId).toList();
  }

  void addChannelToServer(String serverId, ChannelModel channel) {
    state = [
      for (final server in state)
        if (server.id == serverId)
          ServerModel(
            id: server.id,
            name: server.name,
            iconUrl: server.iconUrl,
            description: server.description,
            memberIds: server.memberIds,
            createdBy: server.createdBy,
            createdAt: server.createdAt,
            channels: [...server.channels, channel],
          )
        else
          server
    ];
  }
}

// Provider for chat messages in a channel
final channelMessagesProvider = StateNotifierProvider.family<ChannelMessagesNotifier, List<ChatMessage>, String>((ref, channelId) {
  return ChannelMessagesNotifier(channelId);
});

class ChannelMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final String channelId;

  ChannelMessagesNotifier(this.channelId) : super([]) {
    _initializeDemoMessages();
  }

  void _initializeDemoMessages() {
    if (channelId == 'channel-1') {
      state = [
        ChatMessage(
          id: 'msg-1',
          channelId: channelId,
          senderId: 'user-1',
          senderName: 'Admin User',
          content: 'Welcome to the PM-AJAY collaboration hub!',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ChatMessage(
          id: 'msg-2',
          channelId: channelId,
          senderId: 'user-2',
          senderName: 'Project Manager',
          content: 'Great to be here. Looking forward to coordinating on upcoming projects.',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];
    }
  }

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void updateMessage(ChatMessage updatedMessage) {
    state = [
      for (final message in state)
        if (message.id == updatedMessage.id) updatedMessage else message
    ];
  }

  void deleteMessage(String messageId) {
    state = state.where((message) => message.id != messageId).toList();
  }
}

// Provider for checklist items in a channel
final channelChecklistsProvider = StateNotifierProvider.family<ChannelChecklistNotifier, List<ChecklistItem>, String>((ref, channelId) {
  return ChannelChecklistNotifier(channelId);
});

class ChannelChecklistNotifier extends StateNotifier<List<ChecklistItem>> {
  final String channelId;

  ChannelChecklistNotifier(this.channelId) : super([]) {
    _initializeDemoChecklist();
  }

  void _initializeDemoChecklist() {
    if (channelId == 'channel-3') {
      state = [
        ChecklistItem(
          id: 'task-1',
          channelId: channelId,
          title: 'Review Q4 budget allocation',
          description: 'Complete review of all Q4 fund allocations',
          isCompleted: true,
          assignee: 'Admin User',
          dueDate: DateTime.now().subtract(const Duration(days: 2)),
          priority: TaskPriority.high,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        ChecklistItem(
          id: 'task-2',
          channelId: channelId,
          title: 'Prepare progress report',
          description: 'Compile project status updates for stakeholder meeting',
          isCompleted: false,
          assignee: 'Project Manager',
          dueDate: DateTime.now().add(const Duration(days: 3)),
          priority: TaskPriority.medium,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        ChecklistItem(
          id: 'task-3',
          channelId: channelId,
          title: 'Schedule site inspections',
          description: 'Coordinate with regional teams for next month site visits',
          isCompleted: false,
          assignee: 'Regional Coordinator',
          dueDate: DateTime.now().add(const Duration(days: 7)),
          priority: TaskPriority.low,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];
    }
  }

  void addItem(ChecklistItem item) {
    state = [...state, item];
  }

  void updateItem(ChecklistItem updatedItem) {
    state = [
      for (final item in state)
        if (item.id == updatedItem.id) updatedItem else item
    ];
  }

  void toggleItem(String itemId) {
    state = [
      for (final item in state)
        if (item.id == itemId)
          item.copyWith(isCompleted: !item.isCompleted)
        else
          item
    ];
  }

  void removeItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }
}

// Provider for message input text
final messageInputProvider = StateProvider<String>((ref) => '');

// Provider for tracking typing indicators
final typingUsersProvider = StateProvider<Map<String, List<String>>>((ref) => {});