import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/compliance_model.dart';
import '../../providers/compliance_providers.dart';
import '../widgets/checklist_form_dialog.dart';

class ComplianceChecklistPage extends ConsumerWidget {
  final String projectId;
  final String projectName;

  const ComplianceChecklistPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklistsAsync = ref.watch(projectChecklistsProvider(projectId));
    final statsAsync = ref.watch(complianceStatsProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(projectName),
            const Text(
              'Compliance Monitoring',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to audit trail page
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(projectChecklistsProvider(projectId));
              ref.invalidate(complianceStatsProvider(projectId));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          statsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
            data: (stats) => _buildStatsCard(stats),
          ),
          Expanded(
            child: checklistsAsync.when(
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
                        ref.invalidate(projectChecklistsProvider(projectId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (checklists) {
                if (checklists.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checklist, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No checklists created yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: checklists.length,
                  itemBuilder: (context, index) {
                    return _buildChecklistCard(
                      context,
                      ref,
                      checklists[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateChecklistDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Checklist'),
      ),
    );
  }

  Widget _buildStatsCard(ComplianceStatistics stats) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  stats.totalChecklists,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Completed',
                  stats.completedChecklists,
                  Colors.green,
                ),
                _buildStatItem(
                  'In Progress',
                  stats.inProgressChecklists,
                  Colors.orange,
                ),
                _buildStatItem(
                  'Pending',
                  stats.pendingChecklists,
                  Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Overall Completion',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '${(stats.completionRate * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: stats.completionRate,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation(Colors.green),
                ),
                const SizedBox(height: 8),
                Text(
                  '${stats.completedItems} of ${stats.totalItems} items completed',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildChecklistCard(
    BuildContext context,
    WidgetRef ref,
    ComplianceChecklist checklist,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(checklist.category),
          child: Icon(
            _getCategoryIcon(checklist.category),
            color: Colors.white,
          ),
        ),
        title: Text(checklist.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(checklist.category.name),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(checklist.status.name),
                  backgroundColor: _getStatusColor(checklist.status),
                  labelStyle: const TextStyle(fontSize: 11, color: Colors.white),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                Text(
                  '${(checklist.completionPercentage * 100).toStringAsFixed(0)}% Complete',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        children: checklist.items.map((item) {
          return _buildChecklistItem(context, ref, checklist.id, item);
        }).toList(),
      ),
    );
  }

  Widget _buildChecklistItem(
    BuildContext context,
    WidgetRef ref,
    String checklistId,
    ChecklistItem item,
  ) {
    return CheckboxListTile(
      value: item.isCompleted,
      onChanged: (value) async {
        final updatedItem = item.copyWith(
          isCompleted: value ?? false,
          completedAt: value == true ? DateTime.now() : null,
          completedBy: value == true ? 'current_user' : null,
        );

        try {
          final repository = ref.read(complianceRepositoryProvider);
          await repository.updateChecklistItem(checklistId, updatedItem);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      title: Text(item.title),
      subtitle: item.description != null ? Text(item.description!) : null,
      secondary: item.isRequired
          ? const Icon(Icons.star, color: Colors.orange, size: 16)
          : null,
    );
  }

  Color _getCategoryColor(ComplianceCategory category) {
    switch (category) {
      case ComplianceCategory.environmental:
        return Colors.green;
      case ComplianceCategory.safety:
        return Colors.red;
      case ComplianceCategory.legal:
        return Colors.blue;
      case ComplianceCategory.financial:
        return Colors.purple;
      case ComplianceCategory.technical:
        return Colors.indigo;
      case ComplianceCategory.quality:
        return Colors.teal;
      case ComplianceCategory.general:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(ComplianceCategory category) {
    switch (category) {
      case ComplianceCategory.environmental:
        return Icons.eco;
      case ComplianceCategory.safety:
        return Icons.security;
      case ComplianceCategory.legal:
        return Icons.gavel;
      case ComplianceCategory.financial:
        return Icons.account_balance;
      case ComplianceCategory.technical:
        return Icons.engineering;
      case ComplianceCategory.quality:
        return Icons.verified;
      case ComplianceCategory.general:
        return Icons.checklist;
    }
  }

  Color _getStatusColor(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.completed:
        return Colors.green;
      case ComplianceStatus.inProgress:
        return Colors.blue;
      case ComplianceStatus.pending:
        return Colors.orange;
      case ComplianceStatus.failed:
        return Colors.red;
      case ComplianceStatus.exempt:
        return Colors.grey;
    }
  }

  void _showCreateChecklistDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ChecklistFormDialog(
        projectId: projectId,
        onSaved: () {
          ref.invalidate(projectChecklistsProvider(projectId));
          ref.invalidate(complianceStatsProvider(projectId));
        },
      ),
    );
  }
}