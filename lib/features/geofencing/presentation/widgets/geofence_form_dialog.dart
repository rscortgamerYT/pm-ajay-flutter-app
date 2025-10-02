import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../domain/entities/project.dart';
import '../../models/geofence_model.dart';
import '../../providers/geofencing_providers.dart';

/// Dialog for creating or editing a geofence
class GeofenceFormDialog extends ConsumerStatefulWidget {
  final String projectId;
  final Geofence? geofence;
  final VoidCallback? onSaved;

  const GeofenceFormDialog({
    super.key,
    required this.projectId,
    this.geofence,
    this.onSaved,
  });

  @override
  ConsumerState<GeofenceFormDialog> createState() =>
      _GeofenceFormDialogState();
}

class _GeofenceFormDialogState extends ConsumerState<GeofenceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _radiusController;
  GeofenceStatus _selectedStatus = GeofenceStatus.active;
  bool _isLoading = false;
  GeoLocation? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.geofence?.name ?? '');
    _latitudeController = TextEditingController(
      text: widget.geofence?.center.latitude.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.geofence?.center.longitude.toString() ?? '',
    );
    _radiusController = TextEditingController(
      text: widget.geofence?.radiusMeters.toString() ?? '100',
    );
    _selectedStatus = widget.geofence?.status ?? GeofenceStatus.active;
    _selectedLocation = widget.geofence?.center;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.geofence != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Geofence' : 'Create Geofence'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
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
                    labelText: 'Geofence Name',
                    hintText: 'Enter a descriptive name',
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          final lat = double.tryParse(value);
                          if (lat == null || lat < -90 || lat > 90) {
                            return 'Invalid';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final lat = double.tryParse(value);
                          final lng = double.tryParse(_longitudeController.text);
                          if (lat != null && lng != null) {
                            setState(() {
                              _selectedLocation = GeoLocation(
                                latitude: lat,
                                longitude: lng,
                              );
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _longitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          final lng = double.tryParse(value);
                          if (lng == null || lng < -180 || lng > 180) {
                            return 'Invalid';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final lat = double.tryParse(_latitudeController.text);
                          final lng = double.tryParse(value);
                          if (lat != null && lng != null) {
                            setState(() {
                              _selectedLocation = GeoLocation(
                                latitude: lat,
                                longitude: lng,
                              );
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _useCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use Current Location'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _radiusController,
                  decoration: const InputDecoration(
                    labelText: 'Radius (meters)',
                    hintText: 'Enter radius in meters',
                    prefixIcon: Icon(Icons.radio_button_unchecked),
                    suffixText: 'm',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a radius';
                    }
                    final radius = double.tryParse(value);
                    if (radius == null || radius <= 0) {
                      return 'Please enter a valid radius';
                    }
                    if (radius < 10) {
                      return 'Radius must be at least 10 meters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<GeofenceStatus>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.settings),
                  ),
                  items: GeofenceStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(status),
                            color: _getStatusColor(status),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(status.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedLocation != null) ...[
                  const Divider(),
                  const Text(
                    'Preview',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          _selectedLocation!.latitude,
                          _selectedLocation!.longitude,
                        ),
                        zoom: 15,
                      ),
                      circles: {
                        Circle(
                          circleId: const CircleId('preview'),
                          center: LatLng(
                            _selectedLocation!.latitude,
                            _selectedLocation!.longitude,
                          ),
                          radius: double.tryParse(_radiusController.text) ?? 100,
                          fillColor: Colors.blue.withOpacity(0.2),
                          strokeColor: Colors.blue,
                          strokeWidth: 2,
                        ),
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('preview'),
                          position: LatLng(
                            _selectedLocation!.latitude,
                            _selectedLocation!.longitude,
                          ),
                        ),
                      },
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
                  ),
                ],
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
          onPressed: _isLoading ? null : _saveGeofence,
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

  Future<void> _useCurrentLocation() async {
    try {
      setState(() => _isLoading = true);

      final service = ref.read(geofencingServiceProvider);
      final location = await service.getCurrentLocation();

      setState(() {
        _latitudeController.text = location.latitude.toStringAsFixed(6);
        _longitudeController.text = location.longitude.toStringAsFixed(6);
        _selectedLocation = location;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveGeofence() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(geofencingServiceProvider);
      final latitude = double.parse(_latitudeController.text);
      final longitude = double.parse(_longitudeController.text);
      final radius = double.parse(_radiusController.text);

      final location = GeoLocation(
        latitude: latitude,
        longitude: longitude,
      );

      if (widget.geofence != null) {
        // Update existing geofence
        final updatedGeofence = widget.geofence!.copyWith(
          name: _nameController.text.trim(),
          center: location,
          radiusMeters: radius,
          status: _selectedStatus,
          activatedAt: _selectedStatus == GeofenceStatus.active
              ? (widget.geofence!.activatedAt ?? DateTime.now())
              : null,
        );
        await service.updateGeofence(updatedGeofence);
      } else {
        // Create new geofence
        await service.createGeofence(
          projectId: widget.projectId,
          name: _nameController.text.trim(),
          center: location,
          radiusMeters: radius,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.geofence != null
                  ? 'Geofence updated successfully'
                  : 'Geofence created successfully',
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