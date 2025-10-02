import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pm_ajay/features/collaboration_hub/models/server_model.dart';
import 'package:pm_ajay/features/collaboration_hub/providers/collaboration_hub_providers.dart';

class ChannelSidebar extends ConsumerWidget {
  final ServerModel server;

  const ChannelSidebar({
    super.key,
    required this.server,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChannel = ref.watch(selectedChannelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 240,
      color: isDark ? const Color(0xFF2F3136) : const Color(0xFFF2F3F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Server header
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF27292D) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    server.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          
          // Channels list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildChannelSection(
                  context,
                  ref,
                  'TEXT CHANNELS',
                  server.channels
                      .where((c) => c.type == ChannelType.text)
                      .toList(),
                  selectedChannel,
                  Icons.tag,
                ),
                _buildChannelSection(
                  context,
                  ref,
                  'CHECKLISTS',
                  server.channels
                      .where((c) => c.type == ChannelType.checklist)
                      .toList(),
                  selectedChannel,
                  Icons.checklist,
                ),
                _buildChannelSection(
                  context,
                  ref,
                  'MEDIA GALLERY',
                  server.channels
                      .where((c) => c.type == ChannelType.media)
                      .toList(),
                  selectedChannel,
                  Icons.photo_library,
                ),
              ],
            ),
          ),
          
          // User profile section
          Container(
            height: 52,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF27292D) : Colors.white,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Current User',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.settings, size: 20, color: Colors.grey[600]),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<ChannelModel> channels,
    ChannelModel? selectedChannel,
    IconData icon,
  ) {
    if (channels.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...channels.map((channel) {
          final isSelected = selectedChannel?.id == channel.id;
          return InkWell(
            onTap: () {
              ref.read(selectedChannelProvider.notifier).state = channel;
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey[300])
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black87)
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      channel.name,
                      style: TextStyle(
                        fontSize: 15,
                        color: isSelected
                            ? (isDark ? Colors.white : Colors.black87)
                            : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}