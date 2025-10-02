import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/repositories/collaboration_repository.dart';
import '../../models/message_model.dart';

/// Firebase implementation of CollaborationRepository
class CollaborationRepositoryImpl implements CollaborationRepository {
  final FirebaseDatabase _firebaseDatabase;
  final Box<Map<dynamic, dynamic>> _messageBox;
  final Box<Map<dynamic, dynamic>> _taskBox;

  CollaborationRepositoryImpl({
    required FirebaseDatabase firebaseDatabase,
    required Box<Map<dynamic, dynamic>> messageBox,
    required Box<Map<dynamic, dynamic>> taskBox,
  })  : _firebaseDatabase = firebaseDatabase,
        _messageBox = messageBox,
        _taskBox = taskBox;

  DatabaseReference get _messagesRef => _firebaseDatabase.ref('messages');
  DatabaseReference get _tasksRef => _firebaseDatabase.ref('tasks');

  // Message operations

  @override
  Future<Message> sendMessage(Message message) async {
    try {
      await _messagesRef.child(message.id).set(message.toJson());
      await _messageBox.put(message.id, message.toJson());
      return message;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<Message> updateMessage(Message message) async {
    try {
      await _messagesRef.child(message.id).update(message.toJson());
      await _messageBox.put(message.id, message.toJson());
      return message;
    } catch (e) {
      throw Exception('Failed to update message: $e');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await _messagesRef.child(messageId).remove();
      await _messageBox.delete(messageId);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  @override
  Future<Message?> getMessageById(String id) async {
    try {
      final localData = _messageBox.get(id);
      if (localData != null) {
        return Message.fromJson(Map<String, dynamic>.from(localData));
      }

      final snapshot = await _messagesRef.child(id).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final message = Message.fromJson(data);
        await _messageBox.put(id, data);
        return message;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get message: $e');
    }
  }

  @override
  Future<List<Message>> getProjectMessages(String projectId, {int limit = 50}) async {
    try {
      final snapshot = await _messagesRef
          .orderByChild('projectId')
          .equalTo(projectId)
          .limitToLast(limit)
          .get();

      if (!snapshot.exists) return [];

      final messages = <Message>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        final messageData = Map<String, dynamic>.from(entry.value as Map);
        messages.add(Message.fromJson(messageData));
      }

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    } catch (e) {
      throw Exception('Failed to get project messages: $e');
    }
  }

  @override
  Stream<Message> watchProjectMessages(String projectId) {
    return _messagesRef
        .orderByChild('projectId')
        .equalTo(projectId)
        .onChildAdded
        .map((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return Message.fromJson(data);
    });
  }

  @override
  Stream<List<Message>> watchAllProjectMessages(String projectId) {
    return _messagesRef
        .orderByChild('projectId')
        .equalTo(projectId)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return <Message>[];

      final messages = <Message>[];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      for (final entry in data.entries) {
        final messageData = Map<String, dynamic>.from(entry.value as Map);
        messages.add(Message.fromJson(messageData));
      }

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  // Task assignment operations

  @override
  Future<TaskAssignment> createTask(TaskAssignment task) async {
    try {
      await _tasksRef.child(task.id).set(task.toJson());
      await _taskBox.put(task.id, task.toJson());
      return task;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  @override
  Future<TaskAssignment> updateTask(TaskAssignment task) async {
    try {
      await _tasksRef.child(task.id).update(task.toJson());
      await _taskBox.put(task.id, task.toJson());
      return task;
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksRef.child(taskId).remove();
      await _taskBox.delete(taskId);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  @override
  Future<TaskAssignment?> getTaskById(String id) async {
    try {
      final localData = _taskBox.get(id);
      if (localData != null) {
        return TaskAssignment.fromJson(Map<String, dynamic>.from(localData));
      }

      final snapshot = await _tasksRef.child(id).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final task = TaskAssignment.fromJson(data);
        await _taskBox.put(id, data);
        return task;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get task: $e');
    }
  }

  @override
  Future<List<TaskAssignment>> getProjectTasks(String projectId) async {
    try {
      final snapshot = await _tasksRef
          .orderByChild('projectId')
          .equalTo(projectId)
          .get();

      if (!snapshot.exists) return [];

      final tasks = <TaskAssignment>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        final taskData = Map<String, dynamic>.from(entry.value as Map);
        tasks.add(TaskAssignment.fromJson(taskData));
      }

      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    } catch (e) {
      throw Exception('Failed to get project tasks: $e');
    }
  }

  @override
  Future<List<TaskAssignment>> getUserTasks(String userId) async {
    try {
      final snapshot = await _tasksRef
          .orderByChild('assigneeId')
          .equalTo(userId)
          .get();

      if (!snapshot.exists) return [];

      final tasks = <TaskAssignment>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        final taskData = Map<String, dynamic>.from(entry.value as Map);
        tasks.add(TaskAssignment.fromJson(taskData));
      }

      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    } catch (e) {
      throw Exception('Failed to get user tasks: $e');
    }
  }

  @override
  Future<List<TaskAssignment>> getTasksByStatus(
    String projectId,
    TaskStatus status,
  ) async {
    try {
      final allTasks = await getProjectTasks(projectId);
      return allTasks.where((task) => task.status == status).toList();
    } catch (e) {
      throw Exception('Failed to get tasks by status: $e');
    }
  }

  @override
  Stream<TaskAssignment> watchTask(String id) {
    return _tasksRef.child(id).onValue.map((event) {
      if (!event.snapshot.exists) {
        throw Exception('Task not found');
      }
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return TaskAssignment.fromJson(data);
    });
  }

  @override
  Stream<List<TaskAssignment>> watchProjectTasks(String projectId) {
    return _tasksRef
        .orderByChild('projectId')
        .equalTo(projectId)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return <TaskAssignment>[];

      final tasks = <TaskAssignment>[];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      for (final entry in data.entries) {
        final taskData = Map<String, dynamic>.from(entry.value as Map);
        tasks.add(TaskAssignment.fromJson(taskData));
      }

      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    });
  }

  @override
  Stream<List<TaskAssignment>> watchUserTasks(String userId) {
    return _tasksRef
        .orderByChild('assigneeId')
        .equalTo(userId)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return <TaskAssignment>[];

      final tasks = <TaskAssignment>[];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      for (final entry in data.entries) {
        final taskData = Map<String, dynamic>.from(entry.value as Map);
        tasks.add(TaskAssignment.fromJson(taskData));
      }

      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    });
  }
}