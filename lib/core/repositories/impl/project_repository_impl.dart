import 'dart:async';
import 'dart:math';
import '../../../domain/entities/project.dart';
import '../project_repository.dart';
import '../../data/demo_data_provider.dart';
import '../../services/realtime_service.dart';
import '../../storage/local_storage_service.dart';

/// Concrete implementation of ProjectRepository
/// Currently uses demo data, will be replaced with actual API calls
class ProjectRepositoryImpl implements ProjectRepository {
  final RealtimeService _realtimeService;
  final LocalStorageService _localStorage;
  
  // In-memory cache for quick access
  List<Project>? _cachedProjects;
  
  ProjectRepositoryImpl({
    required RealtimeService realtimeService,
    required LocalStorageService localStorage,
  })  : _realtimeService = realtimeService,
        _localStorage = localStorage;

  @override
  Future<List<Project>> getProjects() async {
    // Try to get from cache first
    if (_cachedProjects != null) {
      return _cachedProjects!;
    }
    
    // Try to get from local storage
    final cached = await _localStorage.getProjects();
    if (cached.isNotEmpty) {
      _cachedProjects = cached;
      return cached;
    }
    
    // Fallback to demo data (will be replaced with API call)
    final projects = DemoDataProvider.getDemoProjects();
    
    // Cache the result
    _cachedProjects = projects;
    await _localStorage.saveProjects(projects);
    
    return projects;
  }

  @override
  Future<Project> getProjectById(String id) async {
    final projects = await getProjects();
    return projects.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Project not found: $id'),
    );
  }

  @override
  Future<Project> createProject(Project project) async {
    // TODO: Implement API call
    final projects = await getProjects();
    final updatedProjects = [...projects, project];
    
    // Update cache and storage
    _cachedProjects = updatedProjects;
    await _localStorage.saveProjects(updatedProjects);
    
    return project;
  }

  @override
  Future<Project> updateProject(Project project) async {
    final projects = await getProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    
    if (index == -1) {
      throw Exception('Project not found: ${project.id}');
    }
    
    final updatedProjects = [...projects];
    updatedProjects[index] = project;
    
    // Update cache and storage
    _cachedProjects = updatedProjects;
    await _localStorage.saveProjects(updatedProjects);
    
    return project;
  }

  @override
  Future<void> deleteProject(String id) async {
    final projects = await getProjects();
    final updatedProjects = projects.where((p) => p.id != id).toList();
    
    // Update cache and storage
    _cachedProjects = updatedProjects;
    await _localStorage.saveProjects(updatedProjects);
  }

  @override
  Future<List<Project>> getProjectsByImplementingAgency(String agencyId) async {
    final projects = await getProjects();
    return projects.where((p) => p.implementingAgencyId == agencyId).toList();
  }

  @override
  Future<List<Project>> getProjectsByExecutingAgency(String agencyId) async {
    final projects = await getProjects();
    return projects.where((p) => p.executingAgencyId == agencyId).toList();
  }

  @override
  Future<List<Project>> getProjectsByStatus(ProjectStatus status) async {
    final projects = await getProjects();
    return projects.where((p) => p.status == status).toList();
  }

  @override
  Future<List<Project>> getProjectsByType(ProjectType type) async {
    final projects = await getProjects();
    return projects.where((p) => p.type == type).toList();
  }

  @override
  Future<List<Project>> getDelayedProjects() async {
    final projects = await getProjects();
    return projects.where((p) => p.isDelayed).toList();
  }

  @override
  Future<List<Project>> getProjectsInArea({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    final projects = await getProjects();
    
    return projects.where((project) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        project.location.latitude,
        project.location.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  @override
  Stream<Project> watchProject(String id) {
    return _realtimeService.watchProject(id);
  }

  @override
  Stream<List<Project>> watchProjects() {
    return _realtimeService.watchProjects();
  }

  /// Calculates distance between two coordinates using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }
  
  /// Clears the cache (useful for refresh)
  void clearCache() {
    _cachedProjects = null;
  }
}