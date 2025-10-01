import 'package:flutter/material.dart';

class FundDetailPage extends StatelessWidget {
  final String fundId;

  const FundDetailPage({
    super.key,
    required this.fundId,
  });

  @override
  Widget build(BuildContext context) {
    // Mock data
    final fund = {
      'id': fundId,
      'project': 'Adarsh Gram Development - Phase 1',
      'amount': '₹15.5 Crore',
      'status': 'Approved',
      'agency': 'Gujarat Rural Development Agency',
      'requestDate': '15 Mar 2024',
      'approvalDate': '22 Mar 2024',
      'disbursementDate': 'Pending',
      'utilized': '₹10.1 Crore',
      'remaining': '₹5.4 Crore',
      'utilizationPercent': 65,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fund Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Total Amount',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fund['amount'] as String,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatusChip(fund['status'] as String),
                  ],
                ),
              ),
            ),

            // Utilization Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    context,
                    'Utilized',
                    fund['utilized'] as String,
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildStatCard(
                    context,
                    'Remaining',
                    fund['remaining'] as String,
                    Icons.account_balance_wallet,
                    Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Utilization Progress
            _buildSection(
              context,
              'Utilization Progress',
              [
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (fund['utilizationPercent'] as int) / 100,
                        backgroundColor: Colors.grey[200],
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${fund['utilizationPercent']}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),

            // Fund Information
            _buildSection(
              context,
              'Fund Information',
              [
                _buildInfoRow(Icons.folder, 'Project', fund['project'] as String),
                _buildInfoRow(Icons.business, 'Agency', fund['agency'] as String),
                _buildInfoRow(Icons.calendar_today, 'Request Date', fund['requestDate'] as String),
                _buildInfoRow(Icons.check_circle, 'Approval Date', fund['approvalDate'] as String),
                _buildInfoRow(Icons.payment, 'Disbursement Date', fund['disbursementDate'] as String),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.timeline),
                    label: const Text('View Transaction History'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.description),
                    label: const Text('Download Statement'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = status == 'Approved'
        ? Colors.green
        : status == 'Disbursed'
            ? Colors.blue
            : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: children,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}