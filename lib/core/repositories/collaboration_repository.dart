import '../../features/collaboration/models/message_model.dart';

/// Abstract repository for collaboration-related operations
abstract class CollaborationRepository {
  // Message operations
  Future<Message> sendMessage(Message message);
  Future<Message> updateMessage(Message message);
  Future<void> deleteMessage(String messageId);
  Future<Message?> getMessageById(String id);
  Future<List<Message>> getProjectMessages(String projectId, {int limit = 50});
  Stream<Message> watchProjectMessages(String projectId);
  Stream<List<Message>> watchAllProjectMessages(String projectId);

  // Task assignment operations
  Future<TaskAssignment> createTask(TaskAssignment task);
  Future<TaskAssignment> updateTask(TaskAssignment task);
  Future<void> deleteTask(String taskId);
  Future<TaskAssignment?> getTaskById(String id);
  Future<List<TaskAssignment>> getProjectTasks(String projectId);
  Future<List<TaskAssignment>> getUserTasks(String userId);
  Future<List<TaskAssignment>> getTasksByStatus(String projectId, TaskStatus status);
  Stream<TaskAssignment> watchTask(String id);
  Stream<List<TaskAssignment>> watchProjectTasks(String projectId);
  Stream<List<TaskAssignment>> watchUserTasks(String userId);
}