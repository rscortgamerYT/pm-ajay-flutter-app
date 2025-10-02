import 'package:flutter/material.dart';

/// Skill Gap & Course Recommendation System
class SkillGapPage extends StatelessWidget {
  const SkillGapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final skillGaps = [
      {'skill': 'Digital Literacy', 'gap': 'High', 'recommended': ['Basic Computer Skills', 'Internet Usage'], 'duration': '3 months'},
      {'skill': 'Agriculture Tech', 'gap': 'Medium', 'recommended': ['Modern Farming Techniques', 'Organic Farming'], 'duration': '2 months'},
      {'skill': 'Handicrafts', 'gap': 'Low', 'recommended': ['Advanced Weaving', 'Marketing Skills'], 'duration': '1 month'},
      {'skill': 'Financial Literacy', 'gap': 'High', 'recommended': ['Banking Basics', 'Digital Payments'], 'duration': '2 months'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Skill Gap Analysis')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Skill Gap Summary', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text('High Priority: ${skillGaps.where((s) => s['gap'] == 'High').length}'),
                  Text('Medium Priority: ${skillGaps.where((s) => s['gap'] == 'Medium').length}'),
                  Text('Low Priority: ${skillGaps.where((s) => s['gap'] == 'Low').length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...skillGaps.map((gap) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: gap['gap'] == 'High' ? Colors.red : (gap['gap'] == 'Medium' ? Colors.orange : Colors.green),
                child: Icon(Icons.trending_up, color: Colors.white),
              ),
              title: Text(gap['skill'] as String),
              subtitle: Text('Priority: ${gap['gap']} • Duration: ${gap['duration']}'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recommended Courses:', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ...(gap['recommended'] as List).map((course) => Padding(
                        padding: const EdgeInsets.only(left: 16, top: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text('• $course')),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Enroll'),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}