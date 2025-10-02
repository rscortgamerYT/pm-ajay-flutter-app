import 'package:flutter/material.dart';

/// Gap-Analysis & Scheme Convergence Recommendation Engine
class GapAnalysisPage extends StatefulWidget {
  final String villageId;
  final String villageName;

  const GapAnalysisPage({
    super.key,
    required this.villageId,
    required this.villageName,
  });

  @override
  State<GapAnalysisPage> createState() => _GapAnalysisPageState();
}

class _GapAnalysisPageState extends State<GapAnalysisPage> {
  final List<Map<String, dynamic>> _gaps = [
    {
      'sector': 'Water Supply',
      'gap': 'Only 60% households have piped water',
      'priority': 'High',
      'schemes': ['Jal Jeevan Mission', 'PM-AJAY Water Infrastructure'],
      'estimatedCost': 5000000,
      'timeline': '6 months',
    },
    {
      'sector': 'Education',
      'gap': 'No secondary school within 5km',
      'priority': 'Medium',
      'schemes': ['Samagra Shiksha', 'PM-AJAY Education'],
      'estimatedCost': 15000000,
      'timeline': '12 months',
    },
    {
      'sector': 'Health',
      'gap': 'Primary Health Center understaffed',
      'priority': 'High',
      'schemes': ['Ayushman Bharat', 'PM-AJAY Health'],
      'estimatedCost': 2000000,
      'timeline': '3 months',
    },
    {
      'sector': 'Roads',
      'gap': 'Internal roads unpaved',
      'priority': 'Medium',
      'schemes': ['PMGSY', 'PM-AJAY Infrastructure'],
      'estimatedCost': 8000000,
      'timeline': '9 months',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gap Analysis: ${widget.villageName}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gap Analysis Summary', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text('Total Gaps Identified: ${_gaps.length}'),
                  Text('High Priority: ${_gaps.where((g) => g['priority'] == 'High').length}'),
                  Text('Medium Priority: ${_gaps.where((g) => g['priority'] == 'Medium').length}'),
                  Text('Total Estimated Cost: ₹${_gaps.fold<int>(0, (sum, g) => sum + (g['estimatedCost'] as int))}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._gaps.map((gap) => _buildGapCard(gap)),
        ],
      ),
    );
  }

  Widget _buildGapCard(Map<String, dynamic> gap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: gap['priority'] == 'High' ? Colors.red : Colors.orange,
          child: Icon(Icons.warning, color: Colors.white),
        ),
        title: Text(gap['sector']),
        subtitle: Text(gap['gap']),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Priority: ${gap['priority']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Estimated Cost: ₹${gap['estimatedCost']}'),
                Text('Timeline: ${gap['timeline']}'),
                const SizedBox(height: 12),
                Text('Recommended Schemes:', style: const TextStyle(fontWeight: FontWeight.bold)),
                ...(gap['schemes'] as List).map((scheme) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('• $scheme'),
                )),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Generate Proposal'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}