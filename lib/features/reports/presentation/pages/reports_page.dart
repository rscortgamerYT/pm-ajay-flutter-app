import 'package:flutter/material.dart';
import '../../../../core/data/demo_data_provider.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedReport = 'Overview';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Report Type Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildReportChip('Overview'),
                const SizedBox(width: 8),
                _buildReportChip('Financial'),
                const SizedBox(width: 8),
                _buildReportChip('Projects'),
                const SizedBox(width: 8),
                _buildReportChip('Agencies'),
              ],
            ),
          ),

          // Report Content
          Expanded(
            child: _selectedReport == 'Overview'
                ? _buildOverviewReport()
                : Center(
                    child: Text('${_selectedReport} Report Coming Soon'),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Generate Report'),
      ),
    );
  }

  Widget _buildReportChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedReport == label,
      onSelected: (selected) => setState(() => _selectedReport = label),
    );
  }

  Widget _buildOverviewReport() {
    final projects = DemoDataProvider.getDemoProjects();
    final agencies = DemoDataProvider.getDemoAgencies();
    final funds = DemoDataProvider.getDemoFunds();
    
    final totalFunds = funds.fold(0.0, (sum, f) => sum + f.amount);
    final avgCompletion = projects.fold(0.0, (sum, p) => sum + p.completionPercentage) / projects.length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Overview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Summary Cards with Real Data
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Total Projects', '${projects.length}', Icons.folder, Colors.blue),
              _buildStatCard('Active Agencies', '${agencies.length}', Icons.business, Colors.green),
              _buildStatCard('Total Funds', '₹${(totalFunds / 10000000).toStringAsFixed(1)}Cr', Icons.account_balance_wallet, Colors.orange),
              _buildStatCard('Avg Completion', '${avgCompletion.toStringAsFixed(0)}%', Icons.trending_up, Colors.purple),
            ],
          ),
          const SizedBox(height: 24),

          // Project Status Breakdown
          Text(
            'Project Status',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildComponentItem(
            'In Progress',
            projects.where((p) => p.status.name == 'inProgress').length,
            Colors.blue
          ),
          _buildComponentItem(
            'Approved',
            projects.where((p) => p.status.name == 'approved').length,
            Colors.green
          ),
          _buildComponentItem(
            'Delayed',
            projects.where((p) => p.status.name == 'delayed').length,
            Colors.red
          ),
          const SizedBox(height: 24),

          // Recent Activities from Demo Data
          Text(
            'Recent Activities',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                _buildActivityItem(
                  '${projects[0].name} - ${projects[0].completionPercentage}% complete',
                  '${DateTime.now().difference(projects[0].updatedAt).inHours}h ago'
                ),
                const Divider(height: 1),
                _buildActivityItem(
                  '${funds[0].name} - ${funds[0].status.name}',
                  '${DateTime.now().difference(funds[0].updatedAt).inDays}d ago'
                ),
                const Divider(height: 1),
                _buildActivityItem(
                  '${agencies[0].name} - Coordination score: ${(agencies[0].coordinationScore * 100).toStringAsFixed(0)}%',
                  '${DateTime.now().difference(agencies[0].updatedAt).inDays}d ago'
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentItem(String name, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '$count Projects',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time) {
    return ListTile(
      leading: const Icon(Icons.circle, size: 8),
      title: Text(title),
      trailing: Text(
        time,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }
}