import 'package:flutter/material.dart';

/// Enriched Reporting & Alert Systems - Enhanced reports and notifications
class EnrichedReportingAlertsPage extends StatelessWidget {
  const EnrichedReportingAlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      {'type': 'Critical', 'message': 'Fund release pending approval', 'time': '5 mins ago', 'icon': Icons.error},
      {'type': 'Warning', 'message': 'Project deadline approaching', 'time': '1 hour ago', 'icon': Icons.warning},
      {'type': 'Info', 'message': 'New compliance report available', 'time': '3 hours ago', 'icon': Icons.info},
      {'type': 'Success', 'message': 'Milestone completed', 'time': '1 day ago', 'icon': Icons.check_circle},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Alerts')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Quick Reports', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildReportCard('Project Status', Icons.assessment, Colors.blue),
              _buildReportCard('Fund Utilization', Icons.account_balance_wallet, Colors.green),
              _buildReportCard('Compliance Summary', Icons.verified, Colors.orange),
              _buildReportCard('Performance Metrics', Icons.trending_up, Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Alerts', style: Theme.of(context).textTheme.titleLarge),
              Chip(
                label: Text('${alerts.length}'),
                backgroundColor: Colors.red.shade100,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alerts.map((alert) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                alert['icon'] as IconData,
                color: _getAlertColor(alert['type'] as String),
              ),
              title: Text(alert['message'] as String),
              subtitle: Text(alert['time'] as String),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {},
              ),
            ),
          )),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Generate Custom Report', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Report Type'),
                    items: ['Financial', 'Compliance', 'Progress', 'Audit']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Start Date'),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'End Date'),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Generate Report'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, IconData icon, Color color) {
    return Card(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'Critical': return Colors.red;
      case 'Warning': return Colors.orange;
      case 'Info': return Colors.blue;
      case 'Success': return Colors.green;
      default: return Colors.grey;
    }
  }
}