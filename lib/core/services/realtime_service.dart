import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../domain/entities/project.dart';
import '../../domain/entities/agency.dart';
import '../../domain/entities/fund.dart';
import '../../domain/entities/citizen.dart';

/// Service for real-time data synchronization using Firebase Realtime Database and WebSocket
class RealtimeService {
  final FirebaseDatabase _database;
  IO.Socket? _socket;
  
  final _projectControllers = <String, StreamController<Project>>{};
  final _projectsController = StreamController<List<Project>>.broadcast();
  final _agenciesController = StreamController<List<Agency>>.broadcast();
  final _fundsController = StreamController<List<Fund>>.broadcast();
  final _alertsController = StreamController<List<Alert>>.broadcast();
  
  RealtimeService({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  /// Initializes WebSocket connection for real-time updates
  Future<void> initialize({String? socketUrl}) async {
    // Initialize Firebase listeners
    _setupFirebaseListeners();
    
    // Initialize WebSocket if URL provided
    if (socketUrl != null) {
      _initializeWebSocket(socketUrl);
    }
  }

  void _setupFirebaseListeners() {
    // Listen to projects node
    _database.ref('projects').onValue.listen((event) {
      if (event.snapshot.exists) {
        // Parse and emit projects
        // TODO: Implement parsing logic
        _projectsController.add([]);
      }
    });

    // Listen to agencies node
    _database.ref('agencies').onValue.listen((event) {
      if (event.snapshot.exists) {
        // Parse and emit agencies
        _agenciesController.add([]);
      }
    });

    // Listen to funds node
    _database.ref('funds').onValue.listen((event) {
      if (event.snapshot.exists) {
        // Parse and emit funds
        _fundsController.add([]);
      }
    });
  }

  void _initializeWebSocket(String url) {
    _socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket?.on('connect', (_) {
      print('WebSocket connected');
    });

    _socket?.on('project_update', (data) {
      // Handle project updates
      _handleProjectUpdate(data);
    });

    _socket?.on('alert', (data) {
      // Handle new alerts
      _handleAlert(data);
    });

    _socket?.on('disconnect', (_) {
      print('WebSocket disconnected');
    });
  }

  void _handleProjectUpdate(dynamic data) {
    // TODO: Parse and emit project update
  }

  void _handleAlert(dynamic data) {
    // TODO: Parse and emit alert
  }

  /// Watches a specific project for real-time updates
  Stream<Project> watchProject(String id) {
    if (!_projectControllers.containsKey(id)) {
      _projectControllers[id] = StreamController<Project>.broadcast();
      
      // Set up Firebase listener for specific project
      _database.ref('projects/$id').onValue.listen((event) {
        if (event.snapshot.exists) {
          // Parse and emit project
          // TODO: Implement parsing logic
        }
      });
    }
    
    return _projectControllers[id]!.stream;
  }

  /// Watches all projects for real-time updates
  Stream<List<Project>> watchProjects() {
    return _projectsController.stream;
  }

  /// Watches all agencies for real-time updates
  Stream<List<Agency>> watchAgencies() {
    return _agenciesController.stream;
  }

  /// Watches all funds for real-time updates
  Stream<List<Fund>> watchFunds() {
    return _fundsController.stream;
  }

  /// Watches system alerts
  Stream<List<Alert>> watchAlerts() {
    return _alertsController.stream;
  }

  /// Emits a project update to WebSocket server
  Future<void> emitProjectUpdate(Project project) async {
    _socket?.emit('project_update', {
      'projectId': project.id,
      'status': project.status.name,
      'completionPercentage': project.completionPercentage,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Also update Firebase
    await _database.ref('projects/${project.id}').update({
      'status': project.status.name,
      'completionPercentage': project.completionPercentage,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Emits an alert to WebSocket server
  Future<void> emitAlert(Alert alert) async {
    _socket?.emit('alert', {
      'id': alert.id,
      'type': alert.type.name,
      'severity': alert.severity.name,
      'title': alert.title,
      'description': alert.description,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Subscribes to notifications for a specific user
  void subscribeToUserNotifications(String userId) {
    _socket?.emit('subscribe_user', {'userId': userId});
  }

  /// Unsubscribes from notifications
  void unsubscribeFromUserNotifications(String userId) {
    _socket?.emit('unsubscribe_user', {'userId': userId});
  }

  // Generic CRUD operations for any collection

  /// Creates a new document in a collection
  Future<Map<String, dynamic>> create(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _database.ref('$collection/$id').set(data);
    return data;
  }

  /// Gets a document from a collection
  Future<Map<String, dynamic>?> get(String collection, String id) async {
    final snapshot = await _database.ref('$collection/$id').get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }

  /// Updates a document in a collection
  Future<void> update(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _database.ref('$collection/$id').update(data);
  }

  /// Deletes a document from a collection
  Future<void> delete(String collection, String id) async {
    await _database.ref('$collection/$id').remove();
  }

  /// Gets all documents from a collection
  Future<List<T>> getCollection<T>(
    String collection,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final snapshot = await _database.ref(collection).get();
    if (!snapshot.exists) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return data.entries
        .map((entry) => fromJson({
              'id': entry.key,
              ...Map<String, dynamic>.from(entry.value as Map),
            }))
        .toList();
  }

  /// Streams all documents from a collection
  Stream<List<T>> streamCollection<T>(
    String collection,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return _database.ref(collection).onValue.map((event) {
      if (!event.snapshot.exists) return <T>[];

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return data.entries
          .map((entry) => fromJson({
                'id': entry.key,
                ...Map<String, dynamic>.from(entry.value as Map),
              }))
          .toList();
    });
  }

  /// Streams a specific document from a collection
  Stream<T> stream<T>(
    String collection,
    String id,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return _database.ref('$collection/$id').onValue.map((event) {
      if (!event.snapshot.exists) {
        throw Exception('Document not found');
      }
      return fromJson({
        'id': id,
        ...Map<String, dynamic>.from(event.snapshot.value as Map),
      });
    });
  }

  /// Disposes all resources
  void dispose() {
    for (var controller in _projectControllers.values) {
      controller.close();
    }
    _projectControllers.clear();
    _projectsController.close();
    _agenciesController.close();
    _fundsController.close();
    _alertsController.close();
    _socket?.disconnect();
    _socket?.dispose();
  }
}