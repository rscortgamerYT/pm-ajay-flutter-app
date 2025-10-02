import 'package:flutter/material.dart';

/// Multi-Round Funding Eligibility Tracker
class FundingTrackerPage extends StatefulWidget {
  const FundingTrackerPage({super.key});

  @override
  State<FundingTrackerPage> createState() => _FundingTrackerPageState();
}

class _FundingTrackerPageState extends State<FundingTrackerPage> {
  final List<Map<String, dynamic>> _fundingRounds = [
    {
      'round': 1,
      'name': 'Initial Infrastructure',
      'amount': 5000000,
      'status': 'Disbursed',
      'date': '2024-01-15',
      'eligible': true,
      'criteria': ['VDP Submitted', 'Baseline Assessment', 'Bank Account'],
    },
    {
      'round': 2,
      'name': 'Skill Development',
      'amount': 3000000,
      'status': 'Eligible',
      'date': '2024-06-01',
      'eligible': true,
      'criteria': ['Round 1 Utilization 75%', 'Progress Report', 'Training Plan'],
    },
    {
      'round': 3,
      'name': 'Advanced Infrastructure',
      'amount': 7000000,
      'status': 'Pending',
      'date': '2024-12-01',
      'eligible': false,
      'criteria': ['Round 2 Completion', 'Impact Assessment', '80% Score'],
      'missingCriteria': ['Impact Assessment', '80% Score'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Round Funding Tracker'),
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
                  Text('Funding Summary', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text('Total Allocated: ₹${_fundingRounds.fold<int>(0, (sum, r) => sum + (r['amount'] as int))}'),
                  Text('Disbursed: ₹${_fundingRounds.where((r) => r['status'] == 'Disbursed').fold<int>(0, (sum, r) => sum + (r['amount'] as int))}'),
                  Text('Eligible: ${_fundingRounds.where((r) => r['eligible'] == true).length}/${_fundingRounds.length} rounds'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._fundingRounds.map((round) => _buildFundingCard(round)),
        ],
      ),
    );
  }

  Widget _buildFundingCard(Map<String, dynamic> round) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(round['status']),
          child: Text('${round['round']}', style: const TextStyle(color: Colors.white)),
        ),
        title: Text(round['name']),
        subtitle: Text('₹${round['amount']} • ${round['status']}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Expected Date: ${round['date']}'),
                const SizedBox(height: 12),
                Text('Eligibility Criteria:', style: const TextStyle(fontWeight: FontWeight.bold)),
                ...(round['criteria'] as List).map((criterion) {
                  final isMissing = (round['missingCriteria'] as List?)?.contains(criterion) ?? false;
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Row(
                      children: [
                        Icon(
                          isMissing ? Icons.cancel : Icons.check_circle,
                          color: isMissing ? Colors.red : Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(criterion),
                      ],
                    ),
                  );
                }),
                if (round['eligible'] && round['status'] == 'Eligible') ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Submit Application'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Disbursed':
        return Colors.green;
      case 'Eligible':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}