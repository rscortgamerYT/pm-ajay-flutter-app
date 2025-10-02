import '../../features/geofencing/models/geofence_model.dart';

/// Abstract repository for geofence-related operations
abstract class GeofenceRepository {
  /// Create a new geofence
  Future<Geofence> createGeofence(Geofence geofence);

  /// Update an existing geofence
  Future<Geofence> updateGeofence(Geofence geofence);

  /// Delete a geofence
  Future<void> deleteGeofence(String geofenceId);

  /// Get a geofence by ID
  Future<Geofence?> getGeofenceById(String id);

  /// Get all active geofences
  Future<List<Geofence>> getActiveGeofences();

  /// Get geofences for a specific project
  Future<List<Geofence>> getGeofencesByProject(String projectId);

  /// Get geofences by status
  Future<List<Geofence>> getGeofencesByStatus(GeofenceStatus status);

  /// Save a location event
  Future<void> saveLocationEvent(LocationEvent event);

  /// Get location history for a user
  Future<List<LocationEvent>> getLocationHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get location events for a geofence
  Future<List<LocationEvent>> getGeofenceEvents(String geofenceId);

  /// Stream geofence updates
  Stream<Geofence> watchGeofence(String id);

  /// Stream all active geofences
  Stream<List<Geofence>> watchActiveGeofences();

  /// Stream location events
  Stream<LocationEvent> watchLocationEvents({
    String? userId,
    String? projectId,
  });
}