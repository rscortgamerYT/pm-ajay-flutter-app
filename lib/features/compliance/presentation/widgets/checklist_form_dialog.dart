import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/compliance_model.dart';
import '../../providers/compliance_providers.dart';

/// Dialog for creating or editing a compliance checklist
class ChecklistFormDialog extends ConsumerStatefulWidget {
  final String projectId;
  final ComplianceChecklist? checklist;
  final VoidCallback? onSaved;

  const ChecklistFormDialog({
    super.key,
    required this.projectId,
    this.checklist,
    this.onSaved,
  });

  @override
  ConsumerState<ChecklistFormDialog> createState() =>
      _ChecklistFormDialogState();
}

class _ChecklistFormDialogState extends ConsumerState<ChecklistFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  ComplianceCategory _selectedCategory = ComplianceCategory.general;
  final List<ChecklistItem> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.checklist?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.checklist?.description ?? '');
    _selectedCategory = widget.checklist?.category ?? ComplianceCategory.general;
    if (widget.checklist?.items != null) {
      _items.addAll(widget.checklist!.items);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.checklist != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Checklist' : 'Create Checklist'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Checklist Name',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ComplianceCategory>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: ComplianceCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Checklist Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addChecklistItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_items.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No items added yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ..._items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Checkbox(
                          value: item.isRequired,
                          onChanged: (value) {
                            setState(() {
                              _items[index] = item.copyWith(
                                isRequired: value ?? true,
                              );
                            });
                          },
                        ),
                        title: Text(item.title),
                        subtitle: item.description != null
                            ? Text(item.description!)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _editChecklistItem(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () {
                                setState(() {
                                  _items.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveChecklist,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  void _addChecklistItem() {
    showDialog(
      context: context,
      builder: (context) => _ChecklistItemDialog(
        onSaved: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  void _editChecklistItem(int index) {
    showDialog(
      context: context,
      builder: (context) => _ChecklistItemDialog(
        item: _items[index],
        onSaved: (item) {
          setState(() {
            _items[index] = item;
          });
        },
      ),
    );
  }

  Future<void> _saveChecklist() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one checklist item'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(complianceRepositoryProvider);

      if (widget.checklist != null) {
        final updatedChecklist = widget.checklist!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          items: _items,
        );
        await repository.updateChecklist(updatedChecklist);
      } else {
        final newChecklist = ComplianceChecklist(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          projectId: widget.projectId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          items: _items,
          createdAt: DateTime.now(),
          createdBy: 'current_user',
          status: ComplianceStatus.pending,
        );
        await repository.createChecklist(newChecklist);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.checklist != null
                  ? 'Checklist updated successfully'
                  : 'Checklist created successfully',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
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

class _ChecklistItemDialog extends StatefulWidget {
  final ChecklistItem? item;
  final Function(ChecklistItem) onSaved;

  const _ChecklistItemDialog({
    this.item,
    required this.onSaved,
  });

  @override
  State<_ChecklistItemDialog> createState() => _ChecklistItemDialogState();
}

class _ChecklistItemDialogState extends State<_ChecklistItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late bool _isRequired;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.item?.description ?? '');
    _isRequired = widget.item?.isRequired ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item != null ? 'Edit Item' : 'Add Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Item Title',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _isRequired,
              onChanged: (value) {
                setState(() {
                  _isRequired = value ?? true;
                });
              },
              title: const Text('Required Item'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
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
              final item = ChecklistItem(
                id: widget.item?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text.trim(),
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
                isRequired: _isRequired,
              );
              widget.onSaved(item);
              Navigator.pop(context);
            }
          },
          child: Text(widget.item != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}