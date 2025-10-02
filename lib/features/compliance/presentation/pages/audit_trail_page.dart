import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/compliance_model.dart';
import '../../providers/compliance_providers.dart';

class AuditTrailPage extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;

  const AuditTrailPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  ConsumerState<AuditTrailPage> createState() => _AuditTrailPageState();
}

class _AuditTrailPageState extends ConsumerState<AuditTrailPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  AuditAction? _filterAction;

  @override
  Widget build(BuildContext context) {
    final auditParams = AuditTrailParams(
      projectId: widget.projectId,
      startDate: _startDate,
      endDate: _endDate,
    );
    final auditTrailAsync = ref.watch(projectAuditTrailProvider(auditParams));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.projectName),
            const Text(
              'Audit Trail',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(projectAuditTrailProvider(auditParams));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_startDate != null || _endDate != null || _filterAction != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _buildFilterText(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                        _filterAction = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: auditTrailAsync.when(
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
                      onPressed: () {
                        ref.invalidate(projectAuditTrailProvider(auditParams));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (entries) {
                final filteredEntries = _filterAction != null
                    ? entries.where((e) => e.action == _filterAction).toList()
                    : entries;

                if (filteredEntries.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No audit entries found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredEntries.length,
                  itemBuilder: (context, index) {
                    final entry = filteredEntries[index];
                    final showDateHeader = index == 0 ||
                        !_isSameDay(
                            entry.timestamp, filteredEntries[index - 1].timestamp);

                    return Column(
                      children: [
                        if (showDateHeader)
                          _buildDateHeader(entry.timestamp),
                        _buildAuditCard(entry),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime timestamp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              DateFormat('MMM dd, yyyy').format(timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildAuditCard(AuditTrail entry) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getActionColor(entry.action),
          child: Icon(
            _getActionIcon(entry.action),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          _getActionTitle(entry.action),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${entry.entityType}: ${entry.entityName ?? entry.entityId}'),
            if (entry.notes != null && entry.notes!.isNotEmpty)
              Text(entry.notes!),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  entry.userName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('hh:mm a').format(entry.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: (entry.previousData != null || entry.newData != null)
            ? IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showDetailsDialog(entry),
              )
            : null,
      ),
    );
  }

  String _getActionTitle(AuditAction action) {
    switch (action) {
      case AuditAction.create:
        return 'Created';
      case AuditAction.update:
        return 'Updated';
      case AuditAction.delete:
        return 'Deleted';
      case AuditAction.approve:
        return 'Approved';
      case AuditAction.reject:
        return 'Rejected';
      case AuditAction.submit:
        return 'Submitted';
      case AuditAction.review:
        return 'Reviewed';
      case AuditAction.export:
        return 'Exported';
      case AuditAction.access:
        return 'Accessed';
      case AuditAction.other:
        return 'Other';
    }
  }

  Color _getActionColor(AuditAction action) {
    switch (action) {
      case AuditAction.create:
        return Colors.green;
      case AuditAction.update:
        return Colors.blue;
      case AuditAction.delete:
        return Colors.red;
      case AuditAction.approve:
        return Colors.green;
      case AuditAction.reject:
        return Colors.red;
      case AuditAction.submit:
        return Colors.orange;
      case AuditAction.review:
        return Colors.purple;
      case AuditAction.export:
        return Colors.indigo;
      case AuditAction.access:
        return Colors.teal;
      case AuditAction.other:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(AuditAction action) {
    switch (action) {
      case AuditAction.create:
        return Icons.add_circle;
      case AuditAction.update:
        return Icons.edit;
      case AuditAction.delete:
        return Icons.delete;
      case AuditAction.approve:
        return Icons.check_circle;
      case AuditAction.reject:
        return Icons.cancel;
      case AuditAction.submit:
        return Icons.send;
      case AuditAction.review:
        return Icons.rate_review;
      case AuditAction.export:
        return Icons.download;
      case AuditAction.access:
        return Icons.visibility;
      case AuditAction.other:
        return Icons.more_horiz;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _buildFilterText() {
    final parts = <String>[];
    if (_startDate != null) {
      parts.add('From ${DateFormat('MMM dd, yyyy').format(_startDate!)}');
    }
    if (_endDate != null) {
      parts.add('To ${DateFormat('MMM dd, yyyy').format(_endDate!)}');
    }
    if (_filterAction != null) {
      parts.add('Action: ${_getActionTitle(_filterAction!)}');
    }
    return parts.join(' • ');
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _FilterDialog(
        startDate: _startDate,
        endDate: _endDate,
        filterAction: _filterAction,
      ),
    );

    if (result != null) {
      setState(() {
        _startDate = result['startDate'] as DateTime?;
        _endDate = result['endDate'] as DateTime?;
        _filterAction = result['filterAction'] as AuditAction?;
      });
    }
  }

  Future<void> _showDetailsDialog(AuditTrail entry) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getActionTitle(entry.action)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('User', entry.userName),
              _buildDetailRow(
                'Time',
                DateFormat('MMM dd, yyyy hh:mm a').format(entry.timestamp),
              ),
              _buildDetailRow('Entity Type', entry.entityType),
              _buildDetailRow('Entity ID', entry.entityId),
              if (entry.entityName != null)
                _buildDetailRow('Entity Name', entry.entityName!),
              if (entry.notes != null && entry.notes!.isNotEmpty)
                _buildDetailRow('Notes', entry.notes!),
              if (entry.previousData != null && entry.previousData!.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Previous Data',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...entry.previousData!.entries.map((e) => _buildDetailRow(
                      e.key,
                      e.value.toString(),
                    )),
              ],
              if (entry.newData != null && entry.newData!.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'New Data',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...entry.newData!.entries.map((e) => _buildDetailRow(
                      e.key,
                      e.value.toString(),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final AuditAction? filterAction;

  const _FilterDialog({
    this.startDate,
    this.endDate,
    this.filterAction,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late AuditAction? _filterAction;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _filterAction = widget.filterAction;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Audit Trail'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                _startDate == null
                    ? 'Select Start Date'
                    : DateFormat('MMM dd, yyyy').format(_startDate!),
              ),
              trailing: _startDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _startDate = null),
                    )
                  : null,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _startDate = date);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                _endDate == null
                    ? 'Select End Date'
                    : DateFormat('MMM dd, yyyy').format(_endDate!),
              ),
              trailing: _endDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _endDate = null),
                    )
                  : null,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: _startDate ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _endDate = date);
                }
              },
            ),
            const Divider(),
            DropdownButtonFormField<AuditAction>(
              initialValue: _filterAction,
              decoration: const InputDecoration(
                labelText: 'Action Type',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Actions'),
                ),
                ...AuditAction.values.map((action) => DropdownMenuItem(
                      value: action,
                      child: Text(_getActionTitle(action)),
                    )),
              ],
              onChanged: (value) => setState(() => _filterAction = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _startDate = null;
              _endDate = null;
              _filterAction = null;
            });
          },
          child: const Text('Clear All'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'startDate': _startDate,
              'endDate': _endDate,
              'filterAction': _filterAction,
            });
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  String _getActionTitle(AuditAction action) {
    switch (action) {
      case AuditAction.create:
        return 'Created';
      case AuditAction.update:
        return 'Updated';
      case AuditAction.delete:
        return 'Deleted';
      case AuditAction.approve:
        return 'Approved';
      case AuditAction.reject:
        return 'Rejected';
      case AuditAction.submit:
        return 'Submitted';
      case AuditAction.review:
        return 'Reviewed';
      case AuditAction.export:
        return 'Exported';
      case AuditAction.access:
        return 'Accessed';
      case AuditAction.other:
        return 'Other';
    }
  }
}