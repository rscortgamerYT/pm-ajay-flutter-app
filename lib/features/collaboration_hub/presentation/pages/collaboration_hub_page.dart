import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pm_ajay/features/collaboration_hub/models/server_model.dart';
import 'package:pm_ajay/features/collaboration_hub/providers/collaboration_hub_providers.dart';
import 'package:pm_ajay/features/collaboration_hub/presentation/widgets/server_sidebar.dart';
import 'package:pm_ajay/features/collaboration_hub/presentation/widgets/channel_sidebar.dart';
import 'package:pm_ajay/features/collaboration_hub/presentation/widgets/chat_view.dart';
import 'package:pm_ajay/features/collaboration_hub/presentation/widgets/checklist_view.dart';
import 'package:pm_ajay/features/collaboration_hub/presentation/widgets/media_view.dart';

class CollaborationHubPage extends ConsumerWidget {
  const CollaborationHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedServer = ref.watch(selectedServerProvider);
    final selectedChannel = ref.watch(selectedChannelProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
          tooltip: 'Back to Dashboard',
        ),
        title: const Text('Collaboration Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Show settings
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Server sidebar (leftmost)
          const ServerSidebar(),
          
          // Channel sidebar
          if (selectedServer != null)
            ChannelSidebar(server: selectedServer),
          
          // Main content area
          Expanded(
            child: selectedChannel != null
                ? _buildChannelContent(selectedChannel, ref)
                : _buildWelcomeScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelContent(ChannelModel channel, WidgetRef ref) {
    switch (channel.type) {
      case ChannelType.text:
        return ChatView(channel: channel);
      case ChannelType.checklist:
        return ChecklistView(channel: channel);
      case ChannelType.media:
        return MediaView(channel: channel);
      case ChannelType.meeting:
        return ChatView(channel: channel);
    }
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to Collaboration Hub',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a server and channel to start collaborating',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}