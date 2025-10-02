import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reporting_providers.dart';
import '../../models/report_model.dart';
import '../widgets/metric_card.dart';
import '../widgets/project_status_chart.dart';
import '../widgets/budget_utilization_chart.dart';
import '../widgets/project_completion_chart.dart';
import '../widgets/recent_trends_list.dart';

/// Dashboard page displaying comprehensive metrics and visualizations
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(dashboardMetricsProvider),
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref),
            tooltip: 'Filter Reports',
          ),
        ],
      ),
      body: metricsAsync.when(
        data: (metrics) => _buildDashboard(context, metrics),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading dashboard: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(dashboardMetricsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, DashboardMetrics metrics) {
    return RefreshIndicator(
      onRefresh: () async {
        // Trigger refresh
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary metrics section
            Text(
              'Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildMetricsGrid(context, metrics),
            const SizedBox(height: 32),

            // Charts section
            Text(
              'Analytics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildChartsSection(context, metrics),
            const SizedBox(height: 32),

            // Recent trends
            Text(
              'Recent Trends',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            RecentTrendsList(trends: metrics.recentTrends),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, DashboardMetrics metrics) {
    return GridView.count(
      crossAxisCount: _getCrossAxisCount(context),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        MetricCard(
          title: 'Total Projects',
          value: metrics.totalProjects.toString(),
          icon: Icons.folder_outlined,
          color: Colors.blue,
          subtitle: '${metrics.activeProjects} active',
        ),
        MetricCard(
          title: 'Completed',
          value: metrics.completedProjects.toString(),
          icon: Icons.check_circle_outline,
          color: Colors.green,
          subtitle: '${(metrics.completedProjects / metrics.totalProjects * 100).toStringAsFixed(1)}% completion rate',
        ),
        MetricCard(
          title: 'Delayed Projects',
          value: metrics.delayedProjects.toString(),
          icon: Icons.warning_amber_outlined,
          color: Colors.orange,
          subtitle: '${(metrics.delayedProjects / metrics.totalProjects * 100).toStringAsFixed(1)}% of total',
        ),
        MetricCard(
          title: 'Total Budget',
          value: '₹${_formatCurrency(metrics.totalBudget)}',
          icon: Icons.account_balance_wallet_outlined,
          color: Colors.purple,
          subtitle: 'Allocated funds',
        ),
        MetricCard(
          title: 'Utilized Budget',
          value: '₹${_formatCurrency(metrics.utilizedBudget)}',
          icon: Icons.money_outlined,
          color: Colors.teal,
          subtitle: '${metrics.budgetUtilizationPercentage.toStringAsFixed(1)}% utilized',
        ),
        MetricCard(
          title: 'Avg Completion',
          value: '${metrics.averageProjectCompletion.toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          color: Colors.indigo,
          subtitle: 'Across all projects',
        ),
        MetricCard(
          title: 'Total Agencies',
          value: metrics.totalAgencies.toString(),
          icon: Icons.business_outlined,
          color: Colors.cyan,
          subtitle: 'Coordinating agencies',
        ),
        MetricCard(
          title: 'Citizen Reports',
          value: metrics.totalReports.toString(),
          icon: Icons.report_outlined,
          color: Colors.red,
          subtitle: 'Community feedback',
        ),
      ],
    );
  }

  Widget _buildChartsSection(BuildContext context, DashboardMetrics metrics) {
    return Column(
      children: [
        // Project status distribution
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Projects by Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: ProjectStatusChart(
                    projectsByStatus: metrics.projectsByStatus,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Budget utilization by agency
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget Utilization by Agency',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, child) {
                    final chartDataAsync = ref.watch(budgetUtilizationChartProvider);
                    return chartDataAsync.when(
                      data: (chartData) => SizedBox(
                        height: 300,
                        child: BudgetUtilizationChart(data: chartData),
                      ),
                      loading: () => const SizedBox(
                        height: 300,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stack) => SizedBox(
                        height: 300,
                        child: Center(
                          child: Text('Error loading chart: $error'),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Project completion over time
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project Completion Trend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, child) {
                    final chartDataAsync = ref.watch(projectCompletionChartProvider);
                    return chartDataAsync.when(
                      data: (chartData) => SizedBox(
                        height: 300,
                        child: ProjectCompletionChart(data: chartData),
                      ),
                      loading: () => const SizedBox(
                        height: 300,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stack) => SizedBox(
                        height: 300,
                        child: Center(
                          child: Text('Error loading chart: $error'),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)} K';
    }
    return amount.toStringAsFixed(2);
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Filters'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ReportType>(
                decoration: const InputDecoration(
                  labelText: 'Report Type',
                  border: OutlineInputBorder(),
                ),
                initialValue: ref.read(reportFilterProvider).reportType,
                items: ReportType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getReportTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(reportFilterProvider.notifier).setReportType(value);
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Start Date'),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          final currentEnd = ref.read(reportFilterProvider).endDate;
                          ref.read(reportFilterProvider.notifier)
                              .setDateRange(date, currentEnd);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('End Date'),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          final currentStart = ref.read(reportFilterProvider).startDate;
                          ref.read(reportFilterProvider.notifier)
                              .setDateRange(currentStart, date);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(reportFilterProvider.notifier).reset();
              Navigator.of(context).pop();
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getReportTypeLabel(ReportType type) {
    switch (type) {
      case ReportType.projectPerformance:
        return 'Project Performance';
      case ReportType.fundUtilization:
        return 'Fund Utilization';
      case ReportType.agencyCoordination:
        return 'Agency Coordination';
      case ReportType.citizenEngagement:
        return 'Citizen Engagement';
      case ReportType.complianceStatus:
        return 'Compliance Status';
      case ReportType.timelineAnalysis:
        return 'Timeline Analysis';
      case ReportType.budgetVariance:
        return 'Budget Variance';
      case ReportType.riskAssessment:
        return 'Risk Assessment';
      case ReportType.custom:
        return 'Custom Report';
    }
  }
}