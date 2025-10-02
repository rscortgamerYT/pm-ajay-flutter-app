import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/geofence_model.dart';
import '../../providers/geofencing_providers.dart';
import '../widgets/geofence_form_dialog.dart';
import '../widgets/geofence_map_widget.dart';

class GeofenceManagementPage extends ConsumerStatefulWidget {
  final String projectId;

  const GeofenceManagementPage({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<GeofenceManagementPage> createState() =>
      _GeofenceManagementPageState();
}

class _GeofenceManagementPageState
    extends ConsumerState<GeofenceManagementPage> {
  Geofence? _selectedGeofence;

  @override
  Widget build(BuildContext context) {
    final geofencesAsync =
        ref.watch(geofencesByProjectProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofence Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(geofencesByProjectProvider(widget.projectId));
            },
          ),
        ],
      ),
      body: geofencesAsync.when(
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
                  ref.invalidate(geofencesByProjectProvider(widget.projectId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (geofences) => Column(
          children: [
            // Map View
            Expanded(
              flex: 2,
              child: GeofenceMapWidget(
                geofences: geofences,
                selectedGeofence: _selectedGeofence,
                onGeofenceSelected: (geofence) {
                  setState(() {
                    _selectedGeofence = geofence;
                  });
                },
              ),
            ),
            // Geofence List
            Expanded(
              child: _buildGeofenceList(geofences),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGeofenceDialog(),
        icon: const Icon(Icons.add_location),
        label: const Text('Add Geofence'),
      ),
    );
  }

  Widget _buildGeofenceList(List<Geofence> geofences) {
    if (geofences.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No geofences created yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: geofences.length,
      itemBuilder: (context, index) {
        final geofence = geofences[index];
        final isSelected = _selectedGeofence?.id == geofence.id;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: isSelected ? Colors.blue.shade50 : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(geofence.status),
              child: Icon(
                _getStatusIcon(geofence.status),
                color: Colors.white,
              ),
            ),
            title: Text(geofence.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Radius: ${geofence.radiusMeters.toStringAsFixed(0)}m'),
                Text('Status: ${geofence.status.name}'),
                if (geofence.triggeredBy.isNotEmpty)
                  Text('Triggered by: ${geofence.triggeredBy.length} users'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, geofence),
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
                PopupMenuItem(
                  value: geofence.status == GeofenceStatus.active
                      ? 'deactivate'
                      : 'activate',
                  child: ListTile(
                    leading: Icon(
                      geofence.status == GeofenceStatus.active
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    title: Text(
                      geofence.status == GeofenceStatus.active
                          ? 'Deactivate'
                          : 'Activate',
                    ),
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
            onTap: () {
              setState(() {
                _selectedGeofence = geofence;
              });
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(GeofenceStatus status) {
    switch (status) {
      case GeofenceStatus.active:
        return Colors.green;
      case GeofenceStatus.monitoring:
        return Colors.blue;
      case GeofenceStatus.triggered:
        return Colors.orange;
      case GeofenceStatus.inactive:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(GeofenceStatus status) {
    switch (status) {
      case GeofenceStatus.active:
        return Icons.check_circle;
      case GeofenceStatus.monitoring:
        return Icons.radar;
      case GeofenceStatus.triggered:
        return Icons.warning;
      case GeofenceStatus.inactive:
        return Icons.pause_circle;
    }
  }

  void _handleMenuAction(String action, Geofence geofence) async {
    switch (action) {
      case 'view':
        _showGeofenceDetails(geofence);
        break;
      case 'edit':
        _showEditGeofenceDialog(geofence);
        break;
      case 'activate':
        await _toggleGeofenceStatus(geofence, GeofenceStatus.active);
        break;
      case 'deactivate':
        await _toggleGeofenceStatus(geofence, GeofenceStatus.inactive);
        break;
      case 'delete':
        _confirmDelete(geofence);
        break;
    }
  }

  void _showGeofenceDetails(Geofence geofence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(geofence.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Status', geofence.status.name),
              _buildDetailRow(
                'Radius',
                '${geofence.radiusMeters.toStringAsFixed(0)} meters',
              ),
              _buildDetailRow(
                'Location',
                '${geofence.center.latitude.toStringAsFixed(6)}, '
                    '${geofence.center.longitude.toStringAsFixed(6)}',
              ),
              _buildDetailRow(
                'Created',
                _formatDateTime(geofence.createdAt),
              ),
              if (geofence.activatedAt != null)
                _buildDetailRow(
                  'Activated',
                  _formatDateTime(geofence.activatedAt!),
                ),
              if (geofence.triggeredBy.isNotEmpty)
                _buildDetailRow(
                  'Triggered By',
                  '${geofence.triggeredBy.length} users',
                ),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showCreateGeofenceDialog() {
    showDialog(
      context: context,
      builder: (context) => GeofenceFormDialog(
        projectId: widget.projectId,
        onSaved: () {
          ref.invalidate(geofencesByProjectProvider(widget.projectId));
        },
      ),
    );
  }

  void _showEditGeofenceDialog(Geofence geofence) {
    showDialog(
      context: context,
      builder: (context) => GeofenceFormDialog(
        projectId: widget.projectId,
        geofence: geofence,
        onSaved: () {
          ref.invalidate(geofencesByProjectProvider(widget.projectId));
        },
      ),
    );
  }

  Future<void> _toggleGeofenceStatus(
    Geofence geofence,
    GeofenceStatus newStatus,
  ) async {
    try {
      final service = ref.read(geofencingServiceProvider);
      final updatedGeofence = geofence.copyWith(
        status: newStatus,
        activatedAt: newStatus == GeofenceStatus.active ? DateTime.now() : null,
      );

      await service.updateGeofence(updatedGeofence);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Geofence ${newStatus == GeofenceStatus.active ? 'activated' : 'deactivated'}',
            ),
          ),
        );
        ref.invalidate(geofencesByProjectProvider(widget.projectId));
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

  void _confirmDelete(Geofence geofence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Geofence'),
        content: Text('Are you sure you want to delete "${geofence.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteGeofence(geofence);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGeofence(Geofence geofence) async {
    try {
      final service = ref.read(geofencingServiceProvider);
      await service.deleteGeofence(geofence.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geofence deleted')),
        );
        ref.invalidate(geofencesByProjectProvider(widget.projectId));

        if (_selectedGeofence?.id == geofence.id) {
          setState(() {
            _selectedGeofence = null;
          });
        }
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