import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/geofence_model.dart';

/// Widget to display geofences on a map
class GeofenceMapWidget extends StatefulWidget {
  final List<Geofence> geofences;
  final Geofence? selectedGeofence;
  final ValueChanged<Geofence>? onGeofenceSelected;

  const GeofenceMapWidget({
    super.key,
    required this.geofences,
    this.selectedGeofence,
    this.onGeofenceSelected,
  });

  @override
  State<GeofenceMapWidget> createState() => _GeofenceMapWidgetState();
}

class _GeofenceMapWidgetState extends State<GeofenceMapWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _updateMapElements();
  }

  @override
  void didUpdateWidget(GeofenceMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.geofences != widget.geofences ||
        oldWidget.selectedGeofence != widget.selectedGeofence) {
      _updateMapElements();
    }
  }

  void _updateMapElements() {
    _markers.clear();
    _circles.clear();

    for (final geofence in widget.geofences) {
      final isSelected = widget.selectedGeofence?.id == geofence.id;

      // Add marker for geofence center
      _markers.add(
        Marker(
          markerId: MarkerId(geofence.id),
          position: LatLng(
            geofence.center.latitude,
            geofence.center.longitude,
          ),
          infoWindow: InfoWindow(
            title: geofence.name,
            snippet: 'Radius: ${geofence.radiusMeters.toStringAsFixed(0)}m',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerHue(geofence.status),
          ),
          onTap: () => widget.onGeofenceSelected?.call(geofence),
        ),
      );

      // Add circle for geofence boundary
      _circles.add(
        Circle(
          circleId: CircleId(geofence.id),
          center: LatLng(
            geofence.center.latitude,
            geofence.center.longitude,
          ),
          radius: geofence.radiusMeters,
          fillColor: _getCircleFillColor(geofence.status, isSelected),
          strokeColor: _getCircleStrokeColor(geofence.status, isSelected),
          strokeWidth: isSelected ? 3 : 2,
        ),
      );
    }

    setState(() {});
  }

  double _getMarkerHue(GeofenceStatus status) {
    switch (status) {
      case GeofenceStatus.active:
        return BitmapDescriptor.hueGreen;
      case GeofenceStatus.monitoring:
        return BitmapDescriptor.hueBlue;
      case GeofenceStatus.triggered:
        return BitmapDescriptor.hueOrange;
      case GeofenceStatus.inactive:
        return BitmapDescriptor.hueRed;
    }
  }

  Color _getCircleFillColor(GeofenceStatus status, bool isSelected) {
    final baseColor = _getStatusColor(status);
    final opacity = isSelected ? 0.3 : 0.2;
    return baseColor.withOpacity(opacity);
  }

  Color _getCircleStrokeColor(GeofenceStatus status, bool isSelected) {
    final baseColor = _getStatusColor(status);
    return isSelected ? baseColor : baseColor.withOpacity(0.8);
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

  LatLng _getInitialPosition() {
    if (widget.geofences.isEmpty) {
      // Default to India center if no geofences
      return const LatLng(20.5937, 78.9629);
    }

    final geofence = widget.selectedGeofence ?? widget.geofences.first;
    return LatLng(
      geofence.center.latitude,
      geofence.center.longitude,
    );
  }

  double _getInitialZoom() {
    if (widget.geofences.isEmpty) {
      return 5.0;
    }

    final geofence = widget.selectedGeofence ?? widget.geofences.first;
    // Adjust zoom based on geofence radius
    if (geofence.radiusMeters < 100) {
      return 17.0;
    } else if (geofence.radiusMeters < 500) {
      return 15.0;
    } else if (geofence.radiusMeters < 1000) {
      return 14.0;
    } else {
      return 12.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _getInitialPosition(),
        zoom: _getInitialZoom(),
      ),
      markers: _markers,
      circles: _circles,
      mapType: MapType.normal,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      onMapCreated: (controller) {
        _mapController = controller;
      },
      onTap: (_) {
        // Deselect when tapping empty area
        widget.onGeofenceSelected?.call(widget.geofences.first);
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}