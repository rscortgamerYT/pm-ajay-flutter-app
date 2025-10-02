import 'package:flutter/material.dart';

/// Enhanced Compliance Monitoring - Strengthened tracking and alerts
class EnhancedComplianceMonitoringPage extends StatelessWidget {
  const EnhancedComplianceMonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'category': 'Documentation', 'status': 'Compliant', 'score': 95, 'issues': 0},
      {'category': 'Financial Records', 'status': 'Compliant', 'score': 92, 'issues': 1},
      {'category': 'Safety Standards', 'status': 'Warning', 'score': 78, 'issues': 3},
      {'category': 'Environmental Norms', 'status': 'Non-Compliant', 'score': 55, 'issues': 5},
      {'category': 'Labor Compliance', 'status': 'Compliant', 'score': 88, 'issues': 2},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Compliance Monitoring')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.orange.shade50,
            child: ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: const Text('3 Compliance Issues Require Attention'),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text('Review'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Overall Score', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('82%', style: Theme.of(context).textTheme.headlineMedium),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Open Issues', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('11', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.orange)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Compliance Categories', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...items.map((item) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(item['status'] as String),
                child: Text('${item['score']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              title: Text(item['category'] as String),
              subtitle: Text('${item['status']} • ${item['issues']} open issues'),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {},
              ),
            ),
          )),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent Alerts', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _buildAlert('Environmental clearance pending', '2 hours ago'),
                  _buildAlert('Safety audit overdue', '1 day ago'),
                  _buildAlert('Document verification required', '3 days ago'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlert(String message, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.notifications, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Compliant': return Colors.green;
      case 'Warning': return Colors.orange;
      case 'Non-Compliant': return Colors.red;
      default: return Colors.grey;
    }
  }
}