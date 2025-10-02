import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/citizen.dart';
import '../../models/citizen_report_model.dart';
import '../../providers/citizen_report_providers.dart';
import '../../../auth/providers/auth_providers.dart';
import 'package:uuid/uuid.dart';

/// Page displaying detailed information about a specific report
class ReportDetailPage extends ConsumerStatefulWidget {
  final String reportId;

  const ReportDetailPage({super.key, required this.reportId});

  @override
  ConsumerState<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends ConsumerState<ReportDetailPage> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _upvoteReport() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await ref.read(citizenReportNotifierProvider.notifier).upvoteReport(
          widget.reportId,
          user.id,
        );

    // Refresh report data
    ref.invalidate(reportByIdProvider(widget.reportId));
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final comment = ReportComment(
      id: const Uuid().v4(),
      authorId: user.id,
      authorName: user.name,
      content: _commentController.text.trim(),
      createdAt: DateTime.now(),
      isOfficial: false,
    );

    await ref.read(citizenReportNotifierProvider.notifier).addComment(
          widget.reportId,
          comment,
        );

    _commentController.clear();
    
    // Refresh report data
    ref.invalidate(reportByIdProvider(widget.reportId));
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(reportByIdProvider(widget.reportId));
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) {
          if (report == null) {
            return const Center(child: Text('Report not found'));
          }

          final hasUpvoted = user != null && report.upvotedBy.contains(user.id);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(reportByIdProvider(widget.reportId));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Status and Priority
                Row(
                  children: [
                    Expanded(
                      child: _StatusChip(status: report.status),
                    ),
                    const SizedBox(width: 8),
                    _PriorityChip(priority: report.priority),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  report.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // Metadata
                Row(
                  children: [
                    Chip(
                      label: Text(_getTypeLabel(report.type)),
                      avatar: Icon(_getTypeIcon(report.type), size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(report.createdAt),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(report.description),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Location
                if (report.address != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Location',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(report.address!),
                          if (report.latitude != null && report.longitude != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${report.latitude!.toStringAsFixed(6)}, ${report.longitude!.toStringAsFixed(6)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Attachments
                if (report.attachments.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attachments (${report.attachments.length})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: report.attachments.map((url) {
                              return Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.image),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Upvotes
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: user != null ? _upvoteReport : null,
                          icon: Icon(
                            hasUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                            color: hasUpvoted ? Colors.blue : null,
                          ),
                        ),
                        Text(
                          '${report.upvotes} ${report.upvotes == 1 ? 'person' : 'people'} found this helpful',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Assignment Info
                if (report.assignedAgencyId != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assignment',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text('Assigned to: ${report.assignedAgencyId}'),
                          if (report.assignedAt != null)
                            Text(
                              'Assigned on: ${_formatDate(report.assignedAt!)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Comments
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comments (${report.comments.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ...report.comments.map((comment) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      child: Text(comment.authorName[0].toUpperCase()),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                comment.authorName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (comment.isOfficial) ...[
                                                const SizedBox(width: 4),
                                                const Icon(
                                                  Icons.verified,
                                                  size: 14,
                                                  color: Colors.blue,
                                                ),
                                              ],
                                            ],
                                          ),
                                          Text(
                                            _formatDate(comment.createdAt),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(comment.content),
                                const Divider(height: 24),
                              ],
                            ),
                          );
                        }),
                        if (user != null) ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: _addComment,
                              ),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
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
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
}

class _StatusChip extends StatelessWidget {
  final ReportStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusLabel(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel() {
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

  IconData _getStatusIcon() {
    switch (status) {
      case ReportStatus.submitted:
        return Icons.send;
      case ReportStatus.assigned:
        return Icons.assignment;
      case ReportStatus.inProgress:
        return Icons.hourglass_bottom;
      case ReportStatus.resolved:
        return Icons.check_circle;
      case ReportStatus.closed:
        return Icons.done_all;
      case ReportStatus.rejected:
        return Icons.cancel;
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case ReportStatus.submitted:
        return Colors.blue;
      case ReportStatus.assigned:
        return Colors.orange;
      case ReportStatus.inProgress:
        return Colors.amber;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.closed:
        return Colors.grey;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }
}

class _PriorityChip extends StatelessWidget {
  final ReportPriority priority;

  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getPriorityColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.flag,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            _getPriorityLabel(),
            style: const TextStyle(
              color: Colors.white,
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