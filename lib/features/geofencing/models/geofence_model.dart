import 'package:equatable/equatable.dart';
import '../../../domain/entities/project.dart';

/// Represents a geofence area for project monitoring
class Geofence extends Equatable {
  final String id;
  final String projectId;
  final String name;
  final GeoLocation center;
  final double radiusMeters;
  final GeofenceStatus status;
  final DateTime createdAt;
  final DateTime? activatedAt;
  final List<String> triggeredBy; // User IDs who have entered
  final Map<String, dynamic> metadata;

  const Geofence({
    required this.id,
    required this.projectId,
    required this.name,
    required this.center,
    required this.radiusMeters,
    required this.status,
    required this.createdAt,
    this.activatedAt,
    this.triggeredBy = const [],
    this.metadata = const {},
  });

  Geofence copyWith({
    String? id,
    String? projectId,
    String? name,
    GeoLocation? center,
    double? radiusMeters,
    GeofenceStatus? status,
    DateTime? createdAt,
    DateTime? activatedAt,
    List<String>? triggeredBy,
    Map<String, dynamic>? metadata,
  }) {
    return Geofence(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      center: center ?? this.center,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      activatedAt: activatedAt ?? this.activatedAt,
      triggeredBy: triggeredBy ?? this.triggeredBy,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'center': {
        'latitude': center.latitude,
        'longitude': center.longitude,
      },
      'radiusMeters': radiusMeters,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'activatedAt': activatedAt?.toIso8601String(),
      'triggeredBy': triggeredBy,
      'metadata': metadata,
    };
  }

  factory Geofence.fromJson(Map<String, dynamic> json) {
    return Geofence(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      center: GeoLocation(
        latitude: json['center']['latitude'] as double,
        longitude: json['center']['longitude'] as double,
      ),
      radiusMeters: (json['radiusMeters'] as num).toDouble(),
      status: GeofenceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GeofenceStatus.inactive,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      activatedAt: json['activatedAt'] != null
          ? DateTime.parse(json['activatedAt'] as String)
          : null,
      triggeredBy: (json['triggeredBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        name,
        center,
        radiusMeters,
        status,
        createdAt,
        activatedAt,
        triggeredBy,
        metadata,
      ];
}

enum GeofenceStatus {
  active,
  inactive,
  monitoring,
  triggered,
}

/// Represents a location tracking event
class LocationEvent extends Equatable {
  final String id;
  final String userId;
  final String? projectId;
  final GeoLocation location;
  final DateTime timestamp;
  final LocationEventType type;
  final String? geofenceId;
  final double? accuracy;
  final double? speed;
  final Map<String, dynamic> metadata;

  const LocationEvent({
    required this.id,
    required this.userId,
    this.projectId,
    required this.location,
    required this.timestamp,
    required this.type,
    this.geofenceId,
    this.accuracy,
    this.speed,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'projectId': projectId,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'geofenceId': geofenceId,
      'accuracy': accuracy,
      'speed': speed,
      'metadata': metadata,
    };
  }

  factory LocationEvent.fromJson(Map<String, dynamic> json) {
    return LocationEvent(
      id: json['id'] as String,
      userId: json['userId'] as String,
      projectId: json['projectId'] as String?,
      location: GeoLocation(
        latitude: json['location']['latitude'] as double,
        longitude: json['location']['longitude'] as double,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: LocationEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LocationEventType.update,
      ),
      geofenceId: json['geofenceId'] as String?,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        projectId,
        location,
        timestamp,
        type,
        geofenceId,
        accuracy,
        speed,
        metadata,
      ];
}

enum LocationEventType {
  enter,
  exit,
  update,
  checkIn,
  checkOut,
}