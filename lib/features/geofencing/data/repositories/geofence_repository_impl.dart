import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/repositories/geofence_repository.dart';
import '../../models/geofence_model.dart';

/// Firebase implementation of GeofenceRepository
class GeofenceRepositoryImpl implements GeofenceRepository {
  final FirebaseDatabase _firebaseDatabase;
  final Box<Map<dynamic, dynamic>> _geofenceBox;
  final Box<Map<dynamic, dynamic>> _locationEventBox;

  GeofenceRepositoryImpl({
    required FirebaseDatabase firebaseDatabase,
    required Box<Map<dynamic, dynamic>> geofenceBox,
    required Box<Map<dynamic, dynamic>> locationEventBox,
  })  : _firebaseDatabase = firebaseDatabase,
        _geofenceBox = geofenceBox,
        _locationEventBox = locationEventBox;

  DatabaseReference get _geofencesRef =>
      _firebaseDatabase.ref('geofences');

  DatabaseReference get _locationEventsRef =>
      _firebaseDatabase.ref('location_events');

  @override
  Future<Geofence> createGeofence(Geofence geofence) async {
    try {
      // Save to Firebase
      await _geofencesRef.child(geofence.id).set(geofence.toJson());

      // Save to local cache
      await _geofenceBox.put(geofence.id, geofence.toJson());

      return geofence;
    } catch (e) {
      throw Exception('Failed to create geofence: $e');
    }
  }

  @override
  Future<Geofence> updateGeofence(Geofence geofence) async {
    try {
      // Update in Firebase
      await _geofencesRef.child(geofence.id).update(geofence.toJson());

      // Update in local cache
      await _geofenceBox.put(geofence.id, geofence.toJson());

      return geofence;
    } catch (e) {
      throw Exception('Failed to update geofence: $e');
    }
  }

  @override
  Future<void> deleteGeofence(String geofenceId) async {
    try {
      // Delete from Firebase
      await _geofencesRef.child(geofenceId).remove();

      // Delete from local cache
      await _geofenceBox.delete(geofenceId);
    } catch (e) {
      throw Exception('Failed to delete geofence: $e');
    }
  }

  @override
  Future<Geofence?> getGeofenceById(String id) async {
    try {
      // Try local cache first
      final localData = _geofenceBox.get(id);
      if (localData != null) {
        return Geofence.fromJson(Map<String, dynamic>.from(localData));
      }

      // Fetch from Firebase
      final snapshot = await _geofencesRef.child(id).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final geofence = Geofence.fromJson(data);

        // Cache locally
        await _geofenceBox.put(id, data);

        return geofence;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get geofence: $e');
    }
  }

  @override
  Future<List<Geofence>> getActiveGeofences() async {
    try {
      return await getGeofencesByStatus(GeofenceStatus.active);
    } catch (e) {
      throw Exception('Failed to get active geofences: $e');
    }
  }

  @override
  Future<List<Geofence>> getGeofencesByProject(String projectId) async {
    try {
      final snapshot = await _geofencesRef
          .orderByChild('projectId')
          .equalTo(projectId)
          .get();

      if (!snapshot.exists) return [];

      final geofences = <Geofence>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        final geofenceData = Map<String, dynamic>.from(entry.value as Map);
        geofences.add(Geofence.fromJson(geofenceData));
      }

      return geofences;
    } catch (e) {
      throw Exception('Failed to get geofences by project: $e');
    }
  }

  @override
  Future<List<Geofence>> getGeofencesByStatus(GeofenceStatus status) async {
    try {
      final snapshot = await _geofencesRef
          .orderByChild('status')
          .equalTo(status.name)
          .get();

      if (!snapshot.exists) return [];

      final geofences = <Geofence>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        final geofenceData = Map<String, dynamic>.from(entry.value as Map);
        geofences.add(Geofence.fromJson(geofenceData));
      }

      return geofences;
    } catch (e) {
      throw Exception('Failed to get geofences by status: $e');
    }
  }

  @override
  Future<void> saveLocationEvent(LocationEvent event) async {
    try {
      // Save to Firebase
      await _locationEventsRef.child(event.id).set(event.toJson());

      // Save to local cache
      await _locationEventBox.put(event.id, event.toJson());
    } catch (e) {
      throw Exception('Failed to save location event: $e');
    }
  }

  @override
  Future<List<LocationEvent>> getLocationHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _locationEventsRef
          .orderByChild('userId')
          .equalTo(userId);

      final snapshot = await query.get();

      if (!snapshot.exists) return [];

      final events = <LocationEvent>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        final eventData = Map<String, dynamic>.from(entry.value as Map);
        final event = LocationEvent.fromJson(eventData);

        // Filter by date range if provided
        if (startDate != null && event.timestamp.isBefore(startDate)) continue;
        if (endDate != null && event.timestamp.isAfter(endDate)) continue;

        events.add(event);
      }

      // Sort by timestamp descending
      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return events;
    } catch (e) {
      throw Exception('Failed to get location history: $e');
    }
  }

  @override
  Future<List<LocationEvent>> getGeofenceEvents(String geofenceId) async {
    try {
      final snapshot = await _locationEventsRef
          .orderByChild('geofenceId')
          .equalTo(geofenceId)
          .get();

      if (!snapshot.exists) return [];

      final events = <LocationEvent>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        final eventData = Map<String, dynamic>.from(entry.value as Map);
        events.add(LocationEvent.fromJson(eventData));
      }

      // Sort by timestamp descending
      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return events;
    } catch (e) {
      throw Exception('Failed to get geofence events: $e');
    }
  }

  @override
  Stream<Geofence> watchGeofence(String id) {
    return _geofencesRef.child(id).onValue.map((event) {
      if (!event.snapshot.exists) {
        throw Exception('Geofence not found');
      }
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return Geofence.fromJson(data);
    });
  }

  @override
  Stream<List<Geofence>> watchActiveGeofences() {
    return _geofencesRef
        .orderByChild('status')
        .equalTo(GeofenceStatus.active.name)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return <Geofence>[];

      final geofences = <Geofence>[];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      for (final entry in data.entries) {
        final geofenceData = Map<String, dynamic>.from(entry.value as Map);
        geofences.add(Geofence.fromJson(geofenceData));
      }

      return geofences;
    });
  }

  @override
  Stream<LocationEvent> watchLocationEvents({
    String? userId,
    String? projectId,
  }) {
    DatabaseReference query = _locationEventsRef;

    if (userId != null) {
      return query
          .orderByChild('userId')
          .equalTo(userId)
          .onChildAdded
          .map((event) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return LocationEvent.fromJson(data);
      });
    } else if (projectId != null) {
      return query
          .orderByChild('projectId')
          .equalTo(projectId)
          .onChildAdded
          .map((event) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return LocationEvent.fromJson(data);
      });
    }

    return query.onChildAdded.map((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return LocationEvent.fromJson(data);
    });
  }
}