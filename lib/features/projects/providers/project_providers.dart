import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/project.dart';
import '../../../core/repositories/project_repository.dart';
import '../../../core/repositories/impl/project_repository_impl.dart';
import '../../../core/services/realtime_service.dart';
import '../../../core/storage/local_storage_service.dart';

// ===== Service Providers =====

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  return RealtimeService();
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// ===== Repository Providers =====

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(
    realtimeService: ref.watch(realtimeServiceProvider),
    localStorage: ref.watch(localStorageServiceProvider),
  );
});

// ===== Data Providers =====

/// Fetches all projects
final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjects();
});

/// Fetches a single project by ID
final projectProvider = FutureProvider.family<Project, String>((ref, id) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjectById(id);
});

/// Fetches projects by implementing agency
final projectsByImplementingAgencyProvider = 
    FutureProvider.family<List<Project>, String>((ref, agencyId) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjectsByImplementingAgency(agencyId);
});

/// Fetches projects by executing agency
final projectsByExecutingAgencyProvider = 
    FutureProvider.family<List<Project>, String>((ref, agencyId) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjectsByExecutingAgency(agencyId);
});

/// Fetches projects by status
final projectsByStatusProvider = 
    FutureProvider.family<List<Project>, ProjectStatus>((ref, status) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjectsByStatus(status);
});

/// Fetches projects by type
final projectsByTypeProvider = 
    FutureProvider.family<List<Project>, ProjectType>((ref, type) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjectsByType(type);
});

/// Fetches delayed projects
final delayedProjectsProvider = FutureProvider<List<Project>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getDelayedProjects();
});

/// Fetches projects within a geographic area
final projectsInAreaProvider = FutureProvider.family<
    List<Project>, 
    ({double latitude, double longitude, double radiusKm})
>((ref, params) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjectsInArea(
    latitude: params.latitude,
    longitude: params.longitude,
    radiusKm: params.radiusKm,
  );
});

// ===== Stream Providers =====

/// Stream of real-time project updates
final projectStreamProvider = StreamProvider.family<Project, String>((ref, id) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchProject(id);
});

/// Stream of all projects
final projectsStreamProvider = StreamProvider<List<Project>>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchProjects();
});

// ===== State Notifier Providers =====

/// State notifier for managing project operations
final projectNotifierProvider = 
    StateNotifierProvider<ProjectNotifier, AsyncValue<List<Project>>>((ref) {
  return ProjectNotifier(ref.watch(projectRepositoryProvider));
});

class ProjectNotifier extends StateNotifier<AsyncValue<List<Project>>> {
  final ProjectRepository _repository;
  
  ProjectNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProjects();
  }
  
  Future<void> loadProjects() async {
    state = const AsyncValue.loading();
    try {
      final projects = await _repository.getProjects();
      state = AsyncValue.data(projects);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> refreshProjects() async {
    // Clear cache and reload
    if (_repository is ProjectRepositoryImpl) {
      (_repository as ProjectRepositoryImpl).clearCache();
    }
    await loadProjects();
  }
  
  Future<void> createProject(Project project) async {
    try {
      await _repository.createProject(project);
      await loadProjects(); // Reload list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> updateProject(Project project) async {
    try {
      await _repository.updateProject(project);
      await loadProjects(); // Reload list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> deleteProject(String id) async {
    try {
      await _repository.deleteProject(id);
      await loadProjects(); // Reload list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  List<Project> getProjectsByStatus(ProjectStatus status) {
    return state.whenData((projects) {
      return projects.where((p) => p.status == status).toList();
    }).value ?? [];
  }
  
  List<Project> getDelayedProjects() {
    return state.whenData((projects) {
      return projects.where((p) => p.isDelayed).toList();
    }).value ?? [];
  }
}

// ===== Computed Providers =====

/// Computed statistics from projects
final projectStatsProvider = Provider<ProjectStats>((ref) {
  final projects = ref.watch(projectsProvider).value ?? [];
  
  return ProjectStats(
    total: projects.length,
    inProgress: projects.where((p) => p.status == ProjectStatus.inProgress).length,
    completed: projects.where((p) => p.status == ProjectStatus.completed).length,
    delayed: projects.where((p) => p.isDelayed).length,
    approved: projects.where((p) => p.status == ProjectStatus.approved).length,
    averageCompletion: projects.isEmpty 
        ? 0.0 
        : projects.fold(0.0, (sum, p) => sum + p.completionPercentage) / projects.length,
  );
});

class ProjectStats {
  final int total;
  final int inProgress;
  final int completed;
  final int delayed;
  final int approved;
  final double averageCompletion;
  
  ProjectStats({
    required this.total,
    required this.inProgress,
    required this.completed,
    required this.delayed,
    required this.approved,
    required this.averageCompletion,
  });
}