import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../../features/geofencing/models/geofence_model.dart';
import '../../domain/entities/project.dart';
import '../repositories/geofence_repository.dart';

/// Service for managing geofencing and location tracking
class GeofencingService {
  final GeofenceRepository _repository;
  StreamSubscription<Position>? _positionSubscription;
  final Map<String, Geofence> _activeGeofences = {};
  final StreamController<LocationEvent> _locationEventController =
      StreamController<LocationEvent>.broadcast();

  GeofencingService({required GeofenceRepository repository})
      : _repository = repository;

  Stream<LocationEvent> get locationEventStream => _locationEventController.stream;

  /// Initialize geofencing service and start monitoring
  Future<void> initialize() async {
    // Check location permissions
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }

    // Load active geofences
    final geofences = await _repository.getActiveGeofences();
    for (final geofence in geofences) {
      _activeGeofences[geofence.id] = geofence;
    }

    // Start location monitoring
    await startLocationTracking();
  }

  /// Start continuous location tracking
  Future<void> startLocationTracking() async {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_handlePositionUpdate);
  }

  /// Stop location tracking
  Future<void> stopLocationTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Handle position updates and check geofence triggers
  void _handlePositionUpdate(Position position) async {
    final location = GeoLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    // Check all active geofences
    for (final geofence in _activeGeofences.values) {
      final distance = _calculateDistance(
        location.latitude,
        location.longitude,
        geofence.center.latitude,
        geofence.center.longitude,
      );

      final isInside = distance <= geofence.radiusMeters;
      final wasInside = geofence.status == GeofenceStatus.triggered;

      if (isInside && !wasInside) {
        // Entered geofence
        await _triggerGeofenceEvent(
          geofence,
          location,
          LocationEventType.enter,
          position.accuracy,
          position.speed,
        );
      } else if (!isInside && wasInside) {
        // Exited geofence
        await _triggerGeofenceEvent(
          geofence,
          location,
          LocationEventType.exit,
          position.accuracy,
          position.speed,
        );
      }
    }

    // Emit location update event
    final event = LocationEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user', // Should come from auth service
      location: location,
      timestamp: DateTime.now(),
      type: LocationEventType.update,
      accuracy: position.accuracy,
      speed: position.speed,
    );

    _locationEventController.add(event);
    await _repository.saveLocationEvent(event);
  }

  /// Trigger geofence entry/exit event
  Future<void> _triggerGeofenceEvent(
    Geofence geofence,
    GeoLocation location,
    LocationEventType type,
    double? accuracy,
    double? speed,
  ) async {
    final event = LocationEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user',
      projectId: geofence.projectId,
      location: location,
      timestamp: DateTime.now(),
      type: type,
      geofenceId: geofence.id,
      accuracy: accuracy,
      speed: speed,
    );

    _locationEventController.add(event);
    await _repository.saveLocationEvent(event);

    // Update geofence status
    final updatedGeofence = geofence.copyWith(
      status: type == LocationEventType.enter
          ? GeofenceStatus.triggered
          : GeofenceStatus.monitoring,
      triggeredBy: type == LocationEventType.enter
          ? [...geofence.triggeredBy, 'current_user']
          : geofence.triggeredBy,
    );

    await _repository.updateGeofence(updatedGeofence);
    _activeGeofences[geofence.id] = updatedGeofence;
  }

  /// Create a new geofence for a project
  Future<Geofence> createGeofence({
    required String projectId,
    required String name,
    required GeoLocation center,
    required double radiusMeters,
  }) async {
    final geofence = Geofence(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: projectId,
      name: name,
      center: center,
      radiusMeters: radiusMeters,
      status: GeofenceStatus.active,
      createdAt: DateTime.now(),
      activatedAt: DateTime.now(),
    );

    final created = await _repository.createGeofence(geofence);
    _activeGeofences[created.id] = created;
    return created;
  }

  /// Get current device location
  Future<GeoLocation> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return GeoLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  /// Check if a location is within a geofence
  bool isLocationInGeofence(GeoLocation location, Geofence geofence) {
    final distance = _calculateDistance(
      location.latitude,
      location.longitude,
      geofence.center.latitude,
      geofence.center.longitude,
    );
    return distance <= geofence.radiusMeters;
  }

  /// Get location history for a user
  Future<List<LocationEvent>> getLocationHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _repository.getLocationHistory(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get geofences for a project
  Future<List<Geofence>> getProjectGeofences(String projectId) async {
    return _repository.getGeofencesByProject(projectId);
  }

/// Update an existing geofence
  Future<Geofence> updateGeofence(Geofence geofence) async {
    final updated = await _repository.updateGeofence(geofence);
    
    // Update local cache if geofence is active
    if (updated.status == GeofenceStatus.active) {
      _activeGeofences[updated.id] = updated;
    } else {
      _activeGeofences.remove(updated.id);
    }
    
    return updated;
  }
  /// Delete a geofence
  Future<void> deleteGeofence(String geofenceId) async {
    await _repository.deleteGeofence(geofenceId);
    _activeGeofences.remove(geofenceId);
  }

  /// Dispose resources
  void dispose() {
    _positionSubscription?.cancel();
    _locationEventController.close();
  }
}