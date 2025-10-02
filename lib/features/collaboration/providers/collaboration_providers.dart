import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/repositories/collaboration_repository.dart';
import '../data/repositories/collaboration_repository_impl.dart';
import '../models/message_model.dart';

/// Provider for message Hive box
final messageBoxProvider = FutureProvider<Box<Map<dynamic, dynamic>>>((ref) async {
  return await Hive.openBox<Map<dynamic, dynamic>>('messages');
});

/// Provider for task Hive box
final taskBoxProvider = FutureProvider<Box<Map<dynamic, dynamic>>>((ref) async {
  return await Hive.openBox<Map<dynamic, dynamic>>('tasks');
});

/// Provider for CollaborationRepository
final collaborationRepositoryProvider = Provider<CollaborationRepository>((ref) {
  final messageBox = ref.watch(messageBoxProvider).value;
  final taskBox = ref.watch(taskBoxProvider).value;

  if (messageBox == null || taskBox == null) {
    throw Exception('Collaboration boxes not initialized');
  }

  return CollaborationRepositoryImpl(
    firebaseDatabase: FirebaseDatabase.instance,
    messageBox: messageBox,
    taskBox: taskBox,
  );
});

/// Provider for project messages stream
final projectMessagesProvider = StreamProvider.family<List<Message>, String>((ref, projectId) {
  final repository = ref.watch(collaborationRepositoryProvider);
  return repository.watchAllProjectMessages(projectId);
});

/// Provider for new project messages (individual)
final newProjectMessageProvider = StreamProvider.family<Message, String>((ref, projectId) {
  final repository = ref.watch(collaborationRepositoryProvider);
  return repository.watchProjectMessages(projectId);
});

/// Provider for project messages (future)
final projectMessagesListProvider = FutureProvider.family<List<Message>, ProjectMessagesParams>((ref, params) async {
  final repository = ref.watch(collaborationRepositoryProvider);
  return repository.getProjectMessages(params.projectId, limit: params.limit);
});

/// Provider for project tasks stream
final projectTasksProvider = StreamProvider.family<List<TaskAssignment>, String>((ref, projectId) {
  final repository = ref.watch(collaborationRepositoryProvider);
  return repository.watchProjectTasks(projectId);
});

/// Provider for user tasks stream
final userTasksProvider = StreamProvider.family<List<TaskAssignment>, String>((ref, userId) {
  final repository = ref.watch(collaborationRepositoryProvider);
  return repository.watchUserTasks(userId);
});

/// Provider for single task stream
final taskProvider = StreamProvider.family<TaskAssignment, String>((ref, taskId) {
  final repository = ref.watch(collaborationRepositoryProvider);
  return repository.watchTask(taskId);
});

/// Provider for tasks by status
final tasksByStatusProvider = FutureProvider.family<List<TaskAssignment>, TasksByStatusParams>((ref, params) async {
  final repository = ref.watch(collaborationRepositoryProvider);
  return repository.getTasksByStatus(params.projectId, params.status);
});

/// Provider for user's pending tasks count
final pendingTasksCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final repository = ref.watch(collaborationRepositoryProvider);
  final tasks = await repository.getUserTasks(userId);
  return tasks.where((task) => task.status == TaskStatus.pending || task.status == TaskStatus.inProgress).length;
});

/// Provider for project task statistics
final projectTaskStatsProvider = FutureProvider.family<TaskStatistics, String>((ref, projectId) async {
  final repository = ref.watch(collaborationRepositoryProvider);
  final tasks = await repository.getProjectTasks(projectId);

  return TaskStatistics(
    total: tasks.length,
    pending: tasks.where((t) => t.status == TaskStatus.pending).length,
    inProgress: tasks.where((t) => t.status == TaskStatus.inProgress).length,
    review: tasks.where((t) => t.status == TaskStatus.review).length,
    completed: tasks.where((t) => t.status == TaskStatus.completed).length,
    cancelled: tasks.where((t) => t.status == TaskStatus.cancelled).length,
    highPriority: tasks.where((t) => t.priority == TaskPriority.high || t.priority == TaskPriority.urgent).length,
    overdue: tasks.where((t) => t.dueDate != null && t.dueDate!.isBefore(DateTime.now()) && t.status != TaskStatus.completed).length,
  );
});

/// Parameters for fetching project messages
class ProjectMessagesParams {
  final String projectId;
  final int limit;

  const ProjectMessagesParams({
    required this.projectId,
    this.limit = 50,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectMessagesParams &&
        other.projectId == projectId &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(projectId, limit);
}

/// Parameters for fetching tasks by status
class TasksByStatusParams {
  final String projectId;
  final TaskStatus status;

  const TasksByStatusParams({
    required this.projectId,
    required this.status,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TasksByStatusParams &&
        other.projectId == projectId &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(projectId, status);
}

/// Task statistics model
class TaskStatistics {
  final int total;
  final int pending;
  final int inProgress;
  final int review;
  final int completed;
  final int cancelled;
  final int highPriority;
  final int overdue;

  const TaskStatistics({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.review,
    required this.completed,
    required this.cancelled,
    required this.highPriority,
    required this.overdue,
  });

  double get completionRate => total > 0 ? completed / total : 0.0;
  double get progressRate => total > 0 ? (completed + inProgress) / total : 0.0;
}