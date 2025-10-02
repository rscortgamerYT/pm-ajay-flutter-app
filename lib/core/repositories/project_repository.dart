import '../../domain/entities/project.dart';

/// Abstract repository for project-related operations
/// This enables dependency injection and testability
abstract class ProjectRepository {
  /// Fetches all projects
  Future<List<Project>> getProjects();
  
  /// Fetches a single project by ID
  Future<Project> getProjectById(String id);
  
  /// Creates a new project
  Future<Project> createProject(Project project);
  
  /// Updates an existing project
  Future<Project> updateProject(Project project);
  
  /// Deletes a project
  Future<void> deleteProject(String id);
  
  /// Fetches projects by implementing agency
  Future<List<Project>> getProjectsByImplementingAgency(String agencyId);
  
  /// Fetches projects by executing agency
  Future<List<Project>> getProjectsByExecutingAgency(String agencyId);
  
  /// Fetches projects by status
  Future<List<Project>> getProjectsByStatus(ProjectStatus status);
  
  /// Fetches projects by type
  Future<List<Project>> getProjectsByType(ProjectType type);
  
  /// Fetches delayed projects
  Future<List<Project>> getDelayedProjects();
  
  /// Fetches projects within a geographic area
  Future<List<Project>> getProjectsInArea({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });
  
  /// Stream of real-time project updates
  Stream<Project> watchProject(String id);
  
  /// Stream of all projects
  Stream<List<Project>> watchProjects();
}