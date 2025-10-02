import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/citizen.dart';
import '../../models/citizen_report_model.dart';
import '../../providers/citizen_report_providers.dart';
import '../../../auth/providers/auth_providers.dart';
import 'submit_report_page.dart';
import 'report_detail_page.dart';

/// Page displaying list of citizen reports
class CitizenReportsListPage extends ConsumerStatefulWidget {
  const CitizenReportsListPage({super.key});

  @override
  ConsumerState<CitizenReportsListPage> createState() => _CitizenReportsListPageState();
}

class _CitizenReportsListPageState extends ConsumerState<CitizenReportsListPage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Reports'),
        ),
        body: const Center(
          child: Text('Please log in to view your reports'),
        ),
      );
    }

    final reportsAsync = ref.watch(citizenReportsProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: reportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.report_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reports yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Submit your first report to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(citizenReportsProvider(user.id));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return _ReportCard(report: report);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(citizenReportsProvider(user.id)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SubmitReportPage(),
            ),
          ).then((_) {
            // Refresh list after returning
            ref.invalidate(citizenReportsProvider(user.id));
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Submit Report'),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Reports',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Reports'),
              onTap: () {
                ref.read(reportFiltersProvider.notifier).clearFilters();
                Navigator.pop(context);
              },
            ),
            const Divider(),
            Text(
              'By Status',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            ...ReportStatus.values.map((status) {
              return ListTile(
                title: Text(_getStatusLabel(status)),
                trailing: Chip(
                  label: Text(_getStatusLabel(status)),
                  backgroundColor: _getStatusColor(status),
                ),
                onTap: () {
                  ref.read(reportFiltersProvider.notifier).setStatus(status);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(ReportStatus status) {
    switch (status) {
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.assigned:
        return 'Assigned';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.closed:
        return 'Closed';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.submitted:
        return Colors.blue[100]!;
      case ReportStatus.assigned:
        return Colors.orange[100]!;
      case ReportStatus.inProgress:
        return Colors.amber[100]!;
      case ReportStatus.resolved:
        return Colors.green[100]!;
      case ReportStatus.closed:
        return Colors.grey[300]!;
      case ReportStatus.rejected:
        return Colors.red[100]!;
    }
  }
}

class _ReportCard extends ConsumerWidget {
  final CitizenReportModel report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailPage(reportId: report.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PriorityChip(priority: report.priority),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text(_getTypeLabel(report.type)),
                    avatar: Icon(
                      _getTypeIcon(report.type),
                      size: 16,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(_getStatusLabel(report.status)),
                    backgroundColor: _getStatusColor(report.status),
                    padding: EdgeInsets.zero,
                  ),
                  const Spacer(),
                  if (report.upvotes > 0) ...[
                    Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${report.upvotes}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(report.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  if (report.address != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.address!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hr ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getTypeLabel(ReportType type) {
    switch (type) {
      case ReportType.complaint:
        return 'Complaint';
      case ReportType.suggestion:
        return 'Suggestion';
      case ReportType.inquiry:
        return 'Inquiry';
      case ReportType.projectUpdate:
        return 'Project Update';
      case ReportType.qualityIssue:
        return 'Quality Issue';
      case ReportType.fundMisuse:
        return 'Fund Misuse';
      case ReportType.other:
        return 'Other';
    }
  }

  IconData _getTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.complaint:
        return Icons.report_problem;
      case ReportType.suggestion:
        return Icons.lightbulb_outline;
      case ReportType.inquiry:
        return Icons.help_outline;
      case ReportType.projectUpdate:
        return Icons.update;
      case ReportType.qualityIssue:
        return Icons.warning_amber;
      case ReportType.fundMisuse:
        return Icons.gavel;
      case ReportType.other:
        return Icons.more_horiz;
    }
  }

  String _getStatusLabel(ReportStatus status) {
    switch (status) {
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.assigned:
        return 'Assigned';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.closed:
        return 'Closed';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.submitted:
        return Colors.blue[100]!;
      case ReportStatus.assigned:
        return Colors.orange[100]!;
      case ReportStatus.inProgress:
        return Colors.amber[100]!;
      case ReportStatus.resolved:
        return Colors.green[100]!;
      case ReportStatus.closed:
        return Colors.grey[300]!;
      case ReportStatus.rejected:
        return Colors.red[100]!;
    }
  }
}

class _PriorityChip extends StatelessWidget {
  final ReportPriority priority;

  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.flag,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            _getPriorityLabel(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getPriorityLabel() {
    switch (priority) {
      case ReportPriority.low:
        return 'Low';
      case ReportPriority.medium:
        return 'Medium';
      case ReportPriority.high:
        return 'High';
      case ReportPriority.urgent:
        return 'Urgent';
    }
  }

  Color _getPriorityColor() {
    switch (priority) {
      case ReportPriority.low:
        return Colors.green;
      case ReportPriority.medium:
        return Colors.orange;
      case ReportPriority.high:
        return Colors.deepOrange;
      case ReportPriority.urgent:
        return Colors.red;
    }
  }
}