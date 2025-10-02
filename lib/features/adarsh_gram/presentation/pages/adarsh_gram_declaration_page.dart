import 'package:flutter/material.dart';

/// Adarsh Gram Declaration Assistant
class AdarshGramDeclarationPage extends StatefulWidget {
  final String villageId;
  final String villageName;

  const AdarshGramDeclarationPage({
    super.key,
    required this.villageId,
    required this.villageName,
  });

  @override
  State<AdarshGramDeclarationPage> createState() => _AdarshGramDeclarationPageState();
}

class _AdarshGramDeclarationPageState extends State<AdarshGramDeclarationPage> {
  final List<Map<String, dynamic>> _criteria = [
    {'name': 'Clean Drinking Water', 'status': true, 'score': 95},
    {'name': 'Sanitation Coverage', 'status': true, 'score': 90},
    {'name': 'Electricity Access', 'status': true, 'score': 98},
    {'name': 'All-Weather Road', 'status': true, 'score': 85},
    {'name': 'Primary School', 'status': true, 'score': 88},
    {'name': 'Health Facility', 'status': false, 'score': 65},
    {'name': 'Digital Connectivity', 'status': true, 'score': 80},
    {'name': 'Women Empowerment', 'status': true, 'score': 78},
    {'name': 'Skill Development', 'status': false, 'score': 60},
    {'name': 'Environmental Sustainability', 'status': true, 'score': 82},
  ];

  @override
  Widget build(BuildContext context) {
    final metCriteria = _criteria.where((c) => c['status'] == true).length;
    final totalCriteria = _criteria.length;
    final overallScore = _criteria.fold<int>(0, (sum, c) => sum + (c['score'] as int)) / totalCriteria;
    final isEligible = metCriteria >= 8 && overallScore >= 75;

    return Scaffold(
      appBar: AppBar(
        title: Text('Adarsh Gram Declaration: ${widget.villageName}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: isEligible ? Colors.green[50] : Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(isEligible ? Icons.check_circle : Icons.warning, 
                        color: isEligible ? Colors.green : Colors.orange, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEligible ? 'Eligible for Adarsh Gram Declaration' : 'Not Yet Eligible',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text('Overall Score: ${overallScore.toStringAsFixed(1)}%'),
                            Text('Criteria Met: $metCriteria/$totalCriteria'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isEligible) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.file_download),
                      label: const Text('Generate Declaration Certificate'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Certificate generation initiated')),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Eligibility Criteria', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Minimum 8 out of 10 criteria must be met with overall score ≥ 75%'),
          const SizedBox(height: 16),
          ..._criteria.map((criterion) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                criterion['status'] ? Icons.check_circle : Icons.cancel,
                color: criterion['status'] ? Colors.green : Colors.red,
              ),
              title: Text(criterion['name']),
              trailing: CircleAvatar(
                backgroundColor: _getScoreColor(criterion['score']),
                child: Text('${criterion['score']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}