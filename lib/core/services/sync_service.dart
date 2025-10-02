import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../storage/local_storage_service.dart';
import '../repositories/project_repository.dart';
import '../repositories/agency_repository.dart';
import '../repositories/fund_repository.dart';

/// Service for synchronizing local data with remote server
class SyncService {
  final LocalStorageService _localStorage;
  final ProjectRepository _projectRepository;
  final AgencyRepository _agencyRepository;
  final FundRepository _fundRepository;
  final Connectivity _connectivity;
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  
  SyncService({
    required LocalStorageService localStorage,
    required ProjectRepository projectRepository,
    required AgencyRepository agencyRepository,
    required FundRepository fundRepository,
    Connectivity? connectivity,
  })  : _localStorage = localStorage,
        _projectRepository = projectRepository,
        _agencyRepository = agencyRepository,
        _fundRepository = fundRepository,
        _connectivity = connectivity ?? Connectivity();

  /// Initializes automatic background sync
  void initialize({Duration syncInterval = const Duration(minutes: 5)}) {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        syncAll();
      }
    });
    
    // Set up periodic sync
    _syncTimer = Timer.periodic(syncInterval, (_) async {
      final hasConnection = await _hasInternetConnection();
      if (hasConnection) {
        syncAll();
      }
    });
  }

  /// Synchronizes all pending operations
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
        syncedOperations: 0,
      );
    }
    
    _isSyncing = true;
    
    try {
      final hasConnection = await _hasInternetConnection();
      if (!hasConnection) {
        return SyncResult(
          success: false,
          message: 'No internet connection',
          syncedOperations: 0,
        );
      }
      
      final queue = await _localStorage.getSyncQueue();
      int syncedCount = 0;
      final failedOperations = <Map<String, dynamic>>[];
      
      for (final operation in queue) {
        try {
          await _processSyncOperation(operation);
          syncedCount++;
        } catch (e) {
          failedOperations.add({
            ...operation,
            'error': e.toString(),
          });
        }
      }
      
      // Clear successfully synced operations
      await _localStorage.clearSyncQueue();
      
      // Re-add failed operations
      for (final op in failedOperations) {
        await _localStorage.addToSyncQueue(op);
      }
      
      return SyncResult(
        success: true,
        message: 'Sync completed successfully',
        syncedOperations: syncedCount,
        failedOperations: failedOperations.length,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Adds an operation to sync queue
  Future<void> queueOperation(SyncOperation operation) async {
    await _localStorage.addToSyncQueue(operation.toMap());
    
    // Try immediate sync if online
    final hasConnection = await _hasInternetConnection();
    if (hasConnection && !_isSyncing) {
      syncAll();
    }
  }

  /// Processes a single sync operation
  Future<void> _processSyncOperation(Map<String, dynamic> operation) async {
    final type = operation['type'] as String;
    final entity = operation['entity'] as String;
    final data = operation['data'] as Map<String, dynamic>;
    
    switch (entity) {
      case 'project':
        await _syncProjectOperation(type, data);
        break;
      case 'agency':
        await _syncAgencyOperation(type, data);
        break;
      case 'fund':
        await _syncFundOperation(type, data);
        break;
      default:
        throw Exception('Unknown entity type: $entity');
    }
  }

  Future<void> _syncProjectOperation(String type, Map<String, dynamic> data) async {
    // TODO: Implement actual API calls
    // For now, this is a placeholder
    switch (type) {
      case 'create':
        // await _projectRepository.createProject(project);
        break;
      case 'update':
        // await _projectRepository.updateProject(project);
        break;
      case 'delete':
        // await _projectRepository.deleteProject(id);
        break;
    }
  }

  Future<void> _syncAgencyOperation(String type, Map<String, dynamic> data) async {
    // TODO: Implement actual API calls
  }

  Future<void> _syncFundOperation(String type, Map<String, dynamic> data) async {
    // TODO: Implement actual API calls
  }

  /// Checks if device has internet connection
  Future<bool> _hasInternetConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Gets current sync queue size
  Future<int> getQueueSize() async {
    final queue = await _localStorage.getSyncQueue();
    return queue.length;
  }

  /// Checks if sync is currently in progress
  bool get isSyncing => _isSyncing;

  /// Disposes resources
  void dispose() {
    _syncTimer?.cancel();
  }
}

/// Represents a sync operation to be queued
class SyncOperation {
  final String type; // create, update, delete
  final String entity; // project, agency, fund, etc.
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  SyncOperation({
    required this.type,
    required this.entity,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'entity': entity,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory SyncOperation.fromMap(Map<String, dynamic> map) {
    return SyncOperation(
      type: map['type'] as String,
      entity: map['entity'] as String,
      data: map['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

/// Result of a sync operation
class SyncResult {
  final bool success;
  final String message;
  final int syncedOperations;
  final int failedOperations;
  
  SyncResult({
    required this.success,
    required this.message,
    required this.syncedOperations,
    this.failedOperations = 0,
  });
}