import 'package:flutter/material.dart';

/// Milestone-Based Fund Release & Accountability Dashboard
class MilestoneDashboardPage extends StatelessWidget {
  const MilestoneDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final milestones = [
      {'name': 'VDP Approval', 'status': 'Completed', 'amount': 1000000, 'date': '2024-01-15', 'proof': 'certificate.pdf'},
      {'name': 'Land Acquisition', 'status': 'Completed', 'amount': 2000000, 'date': '2024-03-20', 'proof': 'documents.pdf'},
      {'name': 'Infrastructure Start', 'status': 'In Progress', 'amount': 3000000, 'date': '2024-06-01', 'progress': 65},
      {'name': 'Training Programs', 'status': 'Pending', 'amount': 1500000, 'date': '2024-09-01'},
      {'name': 'Final Assessment', 'status': 'Upcoming', 'amount': 2500000, 'date': '2024-12-01'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Milestone Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fund Release Summary', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text('Total Allocated: ₹${milestones.fold<int>(0, (sum, m) => sum + (m['amount'] as int))}'),
                  Text('Released: ₹${milestones.where((m) => m['status'] == 'Completed').fold<int>(0, (sum, m) => sum + (m['amount'] as int))}'),
                  Text('Completed: ${milestones.where((m) => m['status'] == 'Completed').length}/${milestones.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...milestones.map((m) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(_getIcon(m['status'] as String), color: _getColor(m['status'] as String)),
              title: Text(m['name'] as String),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₹${m['amount']} • ${m['date']}'),
                  if (m['progress'] != null) LinearProgressIndicator(value: (m['progress'] as int) / 100),
                ],
              ),
              trailing: m['status'] == 'Completed' 
                ? IconButton(icon: const Icon(Icons.file_download), onPressed: () {})
                : null,
            ),
          )),
        ],
      ),
    );
  }

  IconData _getIcon(String status) {
    switch (status) {
      case 'Completed': return Icons.check_circle;
      case 'In Progress': return Icons.pending;
      case 'Pending': return Icons.schedule;
      default: return Icons.upcoming;
    }
  }

  Color _getColor(String status) {
    switch (status) {
      case 'Completed': return Colors.green;
      case 'In Progress': return Colors.blue;
      case 'Pending': return Colors.orange;
      default: return Colors.grey;
    }
  }
}