import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/repositories/geofence_repository.dart';
import '../../../core/services/geofencing_service.dart';
import '../data/repositories/geofence_repository_impl.dart';
import '../models/geofence_model.dart';

/// Provider for geofence Hive box
final geofenceBoxProvider = FutureProvider<Box<Map<dynamic, dynamic>>>((ref) async {
  return await Hive.openBox<Map<dynamic, dynamic>>('geofences');
});

/// Provider for location event Hive box
final locationEventBoxProvider = FutureProvider<Box<Map<dynamic, dynamic>>>((ref) async {
  return await Hive.openBox<Map<dynamic, dynamic>>('location_events');
});

/// Provider for GeofenceRepository
final geofenceRepositoryProvider = Provider<GeofenceRepository>((ref) {
  final geofenceBox = ref.watch(geofenceBoxProvider).value;
  final locationEventBox = ref.watch(locationEventBoxProvider).value;

  if (geofenceBox == null || locationEventBox == null) {
    throw Exception('Geofence boxes not initialized');
  }

  return GeofenceRepositoryImpl(
    firebaseDatabase: FirebaseDatabase.instance,
    geofenceBox: geofenceBox,
    locationEventBox: locationEventBox,
  );
});

/// Provider for GeofencingService
final geofencingServiceProvider = Provider<GeofencingService>((ref) {
  final repository = ref.watch(geofenceRepositoryProvider);
  return GeofencingService(repository: repository);
});

/// Provider for active geofences stream
final activeGeofencesProvider = StreamProvider<List<Geofence>>((ref) {
  final repository = ref.watch(geofenceRepositoryProvider);
  return repository.watchActiveGeofences();
});

/// Provider for geofences by project
final geofencesByProjectProvider = FutureProvider.family<List<Geofence>, String>((ref, projectId) async {
  final repository = ref.watch(geofenceRepositoryProvider);
  return repository.getGeofencesByProject(projectId);
});

/// Provider for location events stream
final locationEventsProvider = StreamProvider.family<LocationEvent, LocationEventsParams>((ref, params) {
  final repository = ref.watch(geofenceRepositoryProvider);
  return repository.watchLocationEvents(
    userId: params.userId,
    projectId: params.projectId,
  );
});

/// Provider for location history
final locationHistoryProvider = FutureProvider.family<List<LocationEvent>, LocationHistoryParams>((ref, params) async {
  final repository = ref.watch(geofenceRepositoryProvider);
  return repository.getLocationHistory(
    userId: params.userId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// Provider for geofence events
final geofenceEventsProvider = FutureProvider.family<List<LocationEvent>, String>((ref, geofenceId) async {
  final repository = ref.watch(geofenceRepositoryProvider);
  return repository.getGeofenceEvents(geofenceId);
});

/// Provider for single geofence stream
final geofenceProvider = StreamProvider.family<Geofence, String>((ref, geofenceId) {
  final repository = ref.watch(geofenceRepositoryProvider);
  return repository.watchGeofence(geofenceId);
});

/// Parameters for location events stream
class LocationEventsParams {
  final String? userId;
  final String? projectId;

  const LocationEventsParams({
    this.userId,
    this.projectId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationEventsParams &&
        other.userId == userId &&
        other.projectId == projectId;
  }

  @override
  int get hashCode => Object.hash(userId, projectId);
}

/// Parameters for location history
class LocationHistoryParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LocationHistoryParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationHistoryParams &&
        other.userId == userId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(userId, startDate, endDate);
}