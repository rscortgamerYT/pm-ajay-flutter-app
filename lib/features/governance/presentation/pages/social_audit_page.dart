import 'package:flutter/material.dart';

/// Social Audit & Gram Sabha Engagement Module
class SocialAuditPage extends StatelessWidget {
  const SocialAuditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final audits = [
      {'title': 'MGNREGA Works Audit', 'date': '2024-03-15', 'status': 'Completed', 'participants': 45},
      {'title': 'School Infrastructure Review', 'date': '2024-03-10', 'status': 'Scheduled', 'participants': 32},
      {'title': 'Water Supply Audit', 'date': '2024-02-28', 'status': 'Completed', 'participants': 38},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Social Audit & Gram Sabha')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Next Gram Sabha', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Date: April 5, 2024'),
                  const Text('Time: 10:00 AM'),
                  const Text('Venue: Village Panchayat Office'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Register Attendance'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Recent Audits', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...audits.map((audit) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                audit['status'] == 'Completed' ? Icons.check_circle : Icons.schedule,
                color: audit['status'] == 'Completed' ? Colors.green : Colors.orange,
              ),
              title: Text(audit['title'] as String),
              subtitle: Text('${audit['date']} • ${audit['participants']} participants'),
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
                  Text('Citizen Feedback', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Share your feedback',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Submit Feedback'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}