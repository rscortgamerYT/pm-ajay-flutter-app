import 'package:flutter/material.dart';

/// Training Partner Compliance Module
class TrainingPartnerCompliancePage extends StatelessWidget {
  const TrainingPartnerCompliancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final partners = [
      {'name': 'Skill India Training', 'status': 'Compliant', 'score': 95, 'trainings': 45, 'rating': 4.8},
      {'name': 'Digital Literacy Foundation', 'status': 'Compliant', 'score': 88, 'trainings': 32, 'rating': 4.5},
      {'name': 'Agriculture Training Center', 'status': 'Warning', 'score': 65, 'trainings': 18, 'rating': 3.9},
      {'name': 'Rural Skills Academy', 'status': 'Non-Compliant', 'score': 45, 'trainings': 8, 'rating': 3.2},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Training Partner Compliance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Partner Summary', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text('Total Partners: ${partners.length}'),
                  Text('Compliant: ${partners.where((p) => p['status'] == 'Compliant').length}'),
                  Text('Warning: ${partners.where((p) => p['status'] == 'Warning').length}'),
                  Text('Non-Compliant: ${partners.where((p) => p['status'] == 'Non-Compliant').length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...partners.map((partner) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getColor(partner['status'] as String),
                child: Text('${partner['score']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              title: Text(partner['name'] as String),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${partner['status']} • ${partner['trainings']} trainings'),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      Text(' ${partner['rating']}'),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {},
              ),
            ),
          )),
        ],
      ),
    );
  }

  Color _getColor(String status) {
    switch (status) {
      case 'Compliant': return Colors.green;
      case 'Warning': return Colors.orange;
      case 'Non-Compliant': return Colors.red;
      default: return Colors.grey;
    }
  }
}