import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final notifications = [
      {
        'id': '1',
        'title': 'Fund Approved',
        'message': 'Your fund request for Adarsh Gram Phase 1 has been approved',
        'type': 'fund',
        'time': '2 hours ago',
        'read': false,
      },
      {
        'id': '2',
        'title': 'Project Update',
        'message': 'Project milestone completed: Foundation work finished',
        'type': 'project',
        'time': '5 hours ago',
        'read': false,
      },
      {
        'id': '3',
        'title': 'Deadline Reminder',
        'message': 'Project report submission due in 3 days',
        'type': 'deadline',
        'time': '1 day ago',
        'read': true,
      },
      {
        'id': '4',
        'title': 'New Task Assigned',
        'message': 'You have been assigned to review GIA applications',
        'type': 'task',
        'time': '2 days ago',
        'read': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {},
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(context, notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, Map<String, dynamic> notification) {
    final isRead = notification['read'] as bool;
    
    IconData icon;
    Color iconColor;
    
    switch (notification['type']) {
      case 'fund':
        icon = Icons.account_balance_wallet;
        iconColor = Colors.green;
        break;
      case 'project':
        icon = Icons.folder;
        iconColor = Colors.blue;
        break;
      case 'deadline':
        icon = Icons.alarm;
        iconColor = Colors.orange;
        break;
      case 'task':
        icon = Icons.task;
        iconColor = Colors.purple;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Container(
      color: isRead ? null : Colors.blue.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          notification['title'] as String,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification['message'] as String),
            const SizedBox(height: 4),
            Text(
              notification['time'] as String,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {},
      ),
    );
  }
}