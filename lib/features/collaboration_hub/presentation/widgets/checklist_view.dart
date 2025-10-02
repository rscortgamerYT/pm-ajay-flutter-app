import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pm_ajay/features/collaboration_hub/models/server_model.dart';
import 'package:pm_ajay/features/collaboration_hub/providers/collaboration_hub_providers.dart';

class ChecklistView extends ConsumerStatefulWidget {
  final ChannelModel channel;

  const ChecklistView({
    super.key,
    required this.channel,
  });

  @override
  ConsumerState<ChecklistView> createState() => _ChecklistViewState();
}

class _ChecklistViewState extends ConsumerState<ChecklistView> {
  final TextEditingController _titleController = TextEditingController();
  
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addChecklistItem() {
    showDialog(
      context: context,
      builder: (context) => _AddChecklistItemDialog(
        onAdd: (title, description, assignee, dueDate, priority) {
          final item = ChecklistItem(
            id: 'item-${DateTime.now().millisecondsSinceEpoch}',
            channelId: widget.channel.id,
            title: title,
            description: description,
            isCompleted: false,
            assignee: assignee,
            dueDate: dueDate,
            priority: priority,
            createdAt: DateTime.now(),
          );
          
          ref.read(channelChecklistsProvider(widget.channel.id).notifier)
              .addItem(item);
        },
      ),
    );
  }

  void _toggleItem(ChecklistItem item) {
    ref.read(channelChecklistsProvider(widget.channel.id).notifier)
        .toggleItem(item.id);
  }

  void _deleteItem(String itemId) {
    ref.read(channelChecklistsProvider(widget.channel.id).notifier)
        .removeItem(itemId);
  }

  void _editItem(ChecklistItem item) {
    showDialog(
      context: context,
      builder: (context) => _EditChecklistItemDialog(
        item: item,
        onUpdate: (title, description, assignee, dueDate, priority) {
          final updatedItem = item.copyWith(
            title: title,
            description: description,
            assignee: assignee,
            dueDate: dueDate,
            priority: priority,
          );
          
          ref.read(channelChecklistsProvider(widget.channel.id).notifier)
              .updateItem(updatedItem);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(channelChecklistsProvider(widget.channel.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completedItems = items.where((item) => item.isCompleted).length;
    final totalItems = items.length;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

    return Column(
      children: [
        // Channel header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF36393F) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.checklist, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    widget.channel.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _addChecklistItem,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Task'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '$completedItems / $totalItems tasks completed',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress == 1.0 ? Colors.green : Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Checklist items
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.checklist_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first task to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildChecklistItem(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(ChecklistItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOverdue = item.dueDate != null &&
        item.dueDate!.isBefore(DateTime.now()) &&
        !item.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _editItem(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: item.isCompleted,
                    onChanged: (_) => _toggleItem(item),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isCompleted
                                ? Colors.grey[600]
                                : null,
                          ),
                        ),
                        if (item.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              decoration: item.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (item.priority != null)
                              _buildPriorityChip(item.priority!),
                            if (item.assignee != null)
                              Chip(
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    item.assignee![0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                label: Text(item.assignee!),
                                visualDensity: VisualDensity.compact,
                              ),
                            if (item.dueDate != null)
                              Chip(
                                avatar: Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: isOverdue ? Colors.red : Colors.blue,
                                ),
                                label: Text(
                                  _formatDate(item.dueDate!),
                                  style: TextStyle(
                                    color: isOverdue ? Colors.red : null,
                                    fontWeight: isOverdue
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                ),
                                backgroundColor: isOverdue
                                    ? Colors.red.withOpacity(0.1)
                                    : null,
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteItem(item.id),
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    Color color;
    IconData icon;
    
    switch (priority) {
      case TaskPriority.high:
        color = Colors.red;
        icon = Icons.arrow_upward;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        icon = Icons.drag_handle;
        break;
      case TaskPriority.low:
        color = Colors.green;
        icon = Icons.arrow_downward;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        priority.toString().split('.').last.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color.withOpacity(0.1),
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      final days = difference.inDays.abs();
      return days == 0 ? 'Today (Overdue)' : '$days days overdue';
    } else if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _AddChecklistItemDialog extends StatefulWidget {
  final Function(String title, String? description, String? assignee,
      DateTime? dueDate, TaskPriority? priority) onAdd;

  const _AddChecklistItemDialog({required this.onAdd});

  @override
  State<_AddChecklistItemDialog> createState() =>
      _AddChecklistItemDialogState();
}

class _AddChecklistItemDialogState extends State<_AddChecklistItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assigneeController = TextEditingController();
  DateTime? _selectedDate;
  TaskPriority? _selectedPriority;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _assigneeController,
                decoration: const InputDecoration(
                  labelText: 'Assignee (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Due Date (optional)'
                    : 'Due: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority (optional)',
                  border: OutlineInputBorder(),
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedPriority = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAdd(
                _titleController.text,
                _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                _assigneeController.text.isEmpty
                    ? null
                    : _assigneeController.text,
                _selectedDate,
                _selectedPriority,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _EditChecklistItemDialog extends StatefulWidget {
  final ChecklistItem item;
  final Function(String title, String? description, String? assignee,
      DateTime? dueDate, TaskPriority? priority) onUpdate;

  const _EditChecklistItemDialog({
    required this.item,
    required this.onUpdate,
  });

  @override
  State<_EditChecklistItemDialog> createState() =>
      _EditChecklistItemDialogState();
}

class _EditChecklistItemDialogState extends State<_EditChecklistItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _assigneeController;
  late DateTime? _selectedDate;
  late TaskPriority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _descriptionController =
        TextEditingController(text: widget.item.description ?? '');
    _assigneeController =
        TextEditingController(text: widget.item.assignee ?? '');
    _selectedDate = widget.item.dueDate;
    _selectedPriority = widget.item.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _assigneeController,
                decoration: const InputDecoration(
                  labelText: 'Assignee (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Due Date (optional)'
                    : 'Due: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority (optional)',
                  border: OutlineInputBorder(),
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedPriority = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onUpdate(
                _titleController.text,
                _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                _assigneeController.text.isEmpty
                    ? null
                    : _assigneeController.text,
                _selectedDate,
                _selectedPriority,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}