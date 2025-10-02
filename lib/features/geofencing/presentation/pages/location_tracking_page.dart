import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/geofence_model.dart';
import '../../providers/geofencing_providers.dart';

class LocationTrackingPage extends ConsumerStatefulWidget {
  final String userId;
  final String? projectId;

  const LocationTrackingPage({
    super.key,
    required this.userId,
    this.projectId,
  });

  @override
  ConsumerState<LocationTrackingPage> createState() =>
      _LocationTrackingPageState();
}

class _LocationTrackingPageState extends ConsumerState<LocationTrackingPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final historyParams = LocationHistoryParams(
      userId: widget.userId,
      startDate: _startDate,
      endDate: _endDate,
    );
    final historyAsync = ref.watch(locationHistoryProvider(historyParams));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showDateFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(locationHistoryProvider(historyParams));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_startDate != null || _endDate != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filtered: ${_formatDateRange()}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: historyAsync.when(
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
                        ref.invalidate(locationHistoryProvider(historyParams));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (events) {
                if (events.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No location history available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _buildLocationEventCard(event);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationEventCard(LocationEvent event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getEventColor(event.type),
          child: Icon(
            _getEventIcon(event.type),
            color: Colors.white,
          ),
        ),
        title: Text(_getEventTitle(event.type)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${event.location.latitude.toStringAsFixed(6)}, '
              '${event.location.longitude.toStringAsFixed(6)}',
            ),
            Text(_formatTimestamp(event.timestamp)),
            if (event.accuracy != null)
              Text('Accuracy: ${event.accuracy!.toStringAsFixed(1)}m'),
            if (event.speed != null && event.speed! > 0)
              Text('Speed: ${(event.speed! * 3.6).toStringAsFixed(1)} km/h'),
          ],
        ),
        trailing: event.geofenceId != null
            ? const Icon(Icons.place, color: Colors.blue)
            : null,
        onTap: () => _showEventDetails(event),
      ),
    );
  }

  Color _getEventColor(LocationEventType type) {
    switch (type) {
      case LocationEventType.enter:
        return Colors.green;
      case LocationEventType.exit:
        return Colors.orange;
      case LocationEventType.checkIn:
        return Colors.blue;
      case LocationEventType.checkOut:
        return Colors.purple;
      case LocationEventType.update:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(LocationEventType type) {
    switch (type) {
      case LocationEventType.enter:
        return Icons.login;
      case LocationEventType.exit:
        return Icons.logout;
      case LocationEventType.checkIn:
        return Icons.check_circle;
      case LocationEventType.checkOut:
        return Icons.cancel;
      case LocationEventType.update:
        return Icons.my_location;
    }
  }

  String _getEventTitle(LocationEventType type) {
    switch (type) {
      case LocationEventType.enter:
        return 'Entered Geofence';
      case LocationEventType.exit:
        return 'Exited Geofence';
      case LocationEventType.checkIn:
        return 'Checked In';
      case LocationEventType.checkOut:
        return 'Checked Out';
      case LocationEventType.update:
        return 'Location Update';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat('MMM dd, yyyy HH:mm').format(timestamp);
    }
  }

  String _formatDateRange() {
    if (_startDate != null && _endDate != null) {
      return '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}';
    } else if (_startDate != null) {
      return 'From ${DateFormat('MMM dd').format(_startDate!)}';
    } else if (_endDate != null) {
      return 'Until ${DateFormat('MMM dd').format(_endDate!)}';
    }
    return '';
  }

  void _showDateFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(
                _startDate != null
                    ? DateFormat('MMM dd, yyyy').format(_startDate!)
                    : 'Not set',
              ),
              trailing: const Icon(Icons.calendar_today),
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
              title: const Text('End Date'),
              subtitle: Text(
                _endDate != null
                    ? DateFormat('MMM dd, yyyy').format(_endDate!)
                    : 'Not set',
              ),
              trailing: const Icon(Icons.calendar_today),
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(LocationEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getEventTitle(event.type)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Time', _formatTimestamp(event.timestamp)),
              _buildDetailRow(
                'Location',
                '${event.location.latitude.toStringAsFixed(6)}, '
                    '${event.location.longitude.toStringAsFixed(6)}',
              ),
              if (event.accuracy != null)
                _buildDetailRow(
                  'Accuracy',
                  '${event.accuracy!.toStringAsFixed(1)} meters',
                ),
              if (event.speed != null)
                _buildDetailRow(
                  'Speed',
                  '${(event.speed! * 3.6).toStringAsFixed(1)} km/h',
                ),
              if (event.geofenceId != null)
                _buildDetailRow('Geofence ID', event.geofenceId!),
              if (event.projectId != null)
                _buildDetailRow('Project ID', event.projectId!),
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
}