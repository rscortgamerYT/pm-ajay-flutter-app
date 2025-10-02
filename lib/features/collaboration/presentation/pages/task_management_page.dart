import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/message_model.dart';
import '../../providers/collaboration_providers.dart';
import '../widgets/task_form_dialog.dart';

class TaskManagementPage extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;

  const TaskManagementPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  ConsumerState<TaskManagementPage> createState() =>
      _TaskManagementPageState();
}

class _TaskManagementPageState extends ConsumerState<TaskManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TaskStatus _filterStatus = TaskStatus.pending;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(projectTasksProvider(widget.projectId));
    final statsAsync = ref.watch(projectTaskStatsProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.projectName),
            const Text(
              'Task Management',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(projectTasksProvider(widget.projectId));
              ref.invalidate(projectTaskStatsProvider(widget.projectId));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'In Progress'),
            Tab(text: 'Review'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          statsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
            data: (stats) => _buildStatsCard(stats),
          ),
          Expanded(
            child: tasksAsync.when(
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
                        ref.invalidate(
                            projectTasksProvider(widget.projectId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (tasks) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaskList(tasks),
                    _buildTaskList(
                        tasks.where((t) => t.status == TaskStatus.pending).toList()),
                    _buildTaskList(tasks
                        .where((t) => t.status == TaskStatus.inProgress)
                        .toList()),
                    _buildTaskList(
                        tasks.where((t) => t.status == TaskStatus.review).toList()),
                    _buildTaskList(tasks
                        .where((t) => t.status == TaskStatus.completed)
                        .toList()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  Widget _buildStatsCard(TaskStatistics stats) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', stats.total, Colors.blue),
                _buildStatItem('Pending', stats.pending, Colors.orange),
                _buildStatItem('In Progress', stats.inProgress, Colors.purple),
                _buildStatItem('Completed', stats.completed, Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Completion Rate',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: stats.completionRate,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation(Colors.green),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(stats.completionRate * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    if (stats.highPriority > 0)
                      Chip(
                        label: Text('${stats.highPriority} High Priority'),
                        backgroundColor: Colors.red.shade100,
                        labelStyle: const TextStyle(fontSize: 11),
                      ),
                    if (stats.overdue > 0)
                      Chip(
                        label: Text('${stats.overdue} Overdue'),
                        backgroundColor: Colors.orange.shade100,
                        labelStyle: const TextStyle(fontSize: 11),
                      ),
                  ],
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

  Widget _buildTaskList(List<TaskAssignment> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tasks found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(TaskAssignment task) {
    final isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        task.status != TaskStatus.completed;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor(task.priority),
          child: Icon(
            _getPriorityIcon(task.priority),
            color: Colors.white,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.status == TaskStatus.completed
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.assigneeName),
            Row(
              children: [
                Chip(
                  label: Text(task.status.name),
                  backgroundColor: _getStatusColor(task.status),
                  labelStyle: const TextStyle(fontSize: 11, color: Colors.white),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                if (task.dueDate != null)
                  Text(
                    isOverdue
                        ? 'Overdue: ${_formatDate(task.dueDate!)}'
                        : 'Due: ${_formatDate(task.dueDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleTaskAction(value, task),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('View Details'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (task.status != TaskStatus.completed)
              const PopupMenuItem(
                value: 'complete',
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Mark Complete'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => _showTaskDetails(task),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return Colors.red;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.low:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return Icons.priority_high;
      case TaskPriority.high:
        return Icons.arrow_upward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.low:
        return Icons.arrow_downward;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.review:
        return Colors.purple;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  void _handleTaskAction(String action, TaskAssignment task) async {
    switch (action) {
      case 'view':
        _showTaskDetails(task);
        break;
      case 'edit':
        _showEditTaskDialog(task);
        break;
      case 'complete':
        await _completeTask(task);
        break;
      case 'delete':
        _confirmDelete(task);
        break;
    }
  }

  void _showTaskDetails(TaskAssignment task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(task.description),
              const SizedBox(height: 16),
              _buildDetailRow('Assignee', task.assigneeName),
              _buildDetailRow('Priority', task.priority.name),
              _buildDetailRow('Status', task.status.name),
              if (task.dueDate != null)
                _buildDetailRow('Due Date', _formatDate(task.dueDate!)),
              _buildDetailRow('Created', _formatDate(task.createdAt)),
              if (task.completedAt != null)
                _buildDetailRow('Completed', _formatDate(task.completedAt!)),
              if (task.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: task.tags
                      .map((tag) => Chip(
                            label: Text(tag),
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(
        projectId: widget.projectId,
        onSaved: () {
          ref.invalidate(projectTasksProvider(widget.projectId));
          ref.invalidate(projectTaskStatsProvider(widget.projectId));
        },
      ),
    );
  }

  void _showEditTaskDialog(TaskAssignment task) {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(
        projectId: widget.projectId,
        task: task,
        onSaved: () {
          ref.invalidate(projectTasksProvider(widget.projectId));
          ref.invalidate(projectTaskStatsProvider(widget.projectId));
        },
      ),
    );
  }

  Future<void> _completeTask(TaskAssignment task) async {
    try {
      final repository = ref.read(collaborationRepositoryProvider);
      final updatedTask = task.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
      );
      await repository.updateTask(updatedTask);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task marked as complete')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDelete(TaskAssignment task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTask(task);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(TaskAssignment task) async {
    try {
      final repository = ref.read(collaborationRepositoryProvider);
      await repository.deleteTask(task.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}