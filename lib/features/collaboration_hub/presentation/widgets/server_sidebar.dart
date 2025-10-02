import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pm_ajay/features/collaboration_hub/providers/collaboration_hub_providers.dart';

class ServerSidebar extends ConsumerWidget {
  const ServerSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serversProvider);
    final selectedServer = ref.watch(selectedServerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 72,
      color: isDark ? const Color(0xFF202225) : const Color(0xFFE3E5E8),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Home button
          _buildServerButton(
            context,
            icon: Icons.home,
            isSelected: selectedServer == null,
            onTap: () {
              ref.read(selectedServerProvider.notifier).state = null;
              ref.read(selectedChannelProvider.notifier).state = null;
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(thickness: 2),
          ),
          // Server list
          Expanded(
            child: ListView.builder(
              itemCount: servers.length,
              itemBuilder: (context, index) {
                final server = servers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildServerButton(
                    context,
                    text: server.name.substring(0, 2).toUpperCase(),
                    isSelected: selectedServer?.id == server.id,
                    onTap: () {
                      ref.read(selectedServerProvider.notifier).state = server;
                      // Auto-select first channel
                      if (server.channels.isNotEmpty) {
                        ref.read(selectedChannelProvider.notifier).state =
                            server.channels.first;
                      }
                    },
                  ),
                );
              },
            ),
          ),
          // Add server button
          _buildServerButton(
            context,
            icon: Icons.add,
            isSelected: false,
            onTap: () {
              // TODO: Implement add server dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add server feature coming soon')),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildServerButton(
    BuildContext context, {
    IconData? icon,
    String? text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF36393F) : Colors.white;
    final selectedColor = Theme.of(context).primaryColor;

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : bgColor,
            borderRadius: BorderRadius.circular(isSelected ? 16 : 24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 24,
                  )
                : Text(
                    text!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}