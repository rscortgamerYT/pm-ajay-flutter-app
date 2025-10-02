import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/repositories/compliance_repository.dart';
import '../../models/compliance_model.dart';

/// Firebase implementation of ComplianceRepository
class ComplianceRepositoryImpl implements ComplianceRepository {
  final FirebaseDatabase _firebaseDatabase;
  final Box<Map<dynamic, dynamic>> _checklistBox;
  final Box<Map<dynamic, dynamic>> _auditTrailBox;

  ComplianceRepositoryImpl({
    required FirebaseDatabase firebaseDatabase,
    required Box<Map<dynamic, dynamic>> checklistBox,
    required Box<Map<dynamic, dynamic>> auditTrailBox,
  })  : _firebaseDatabase = firebaseDatabase,
        _checklistBox = checklistBox,
        _auditTrailBox = auditTrailBox;

  DatabaseReference get _checklistsRef =>
      _firebaseDatabase.ref('compliance_checklists');
  DatabaseReference get _auditTrailRef =>
      _firebaseDatabase.ref('audit_trail');

  // Compliance checklist operations

  @override
  Future<ComplianceChecklist> createChecklist(
      ComplianceChecklist checklist) async {
    try {
      await _checklistsRef.child(checklist.id).set(checklist.toJson());
      await _checklistBox.put(checklist.id, checklist.toJson());
      return checklist;
    } catch (e) {
      throw Exception('Failed to create checklist: $e');
    }
  }

  @override
  Future<ComplianceChecklist> updateChecklist(
      ComplianceChecklist checklist) async {
    try {
      await _checklistsRef.child(checklist.id).update(checklist.toJson());
      await _checklistBox.put(checklist.id, checklist.toJson());
      return checklist;
    } catch (e) {
      throw Exception('Failed to update checklist: $e');
    }
  }

  @override
  Future<void> deleteChecklist(String checklistId) async {
    try {
      await _checklistsRef.child(checklistId).remove();
      await _checklistBox.delete(checklistId);
    } catch (e) {
      throw Exception('Failed to delete checklist: $e');
    }
  }

  @override
  Future<ComplianceChecklist?> getChecklistById(String id) async {
    try {
      final localData = _checklistBox.get(id);
      if (localData != null) {
        return ComplianceChecklist.fromJson(
            Map<String, dynamic>.from(localData));
      }

      final snapshot = await _checklistsRef.child(id).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final checklist = ComplianceChecklist.fromJson(data);
        await _checklistBox.put(id, data);
        return checklist;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get checklist: $e');
    }
  }

  @override
  Future<List<ComplianceChecklist>> getProjectChecklists(
      String projectId) async {
    try {
      final snapshot = await _checklistsRef
          .orderByChild('projectId')
          .equalTo(projectId)
          .get();

      if (!snapshot.exists) return [];

      final checklists = <ComplianceChecklist>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        final checklistData = Map<String, dynamic>.from(entry.value as Map);
        checklists.add(ComplianceChecklist.fromJson(checklistData));
      }

      checklists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return checklists;
    } catch (e) {
      throw Exception('Failed to get project checklists: $e');
    }
  }

  @override
  Future<List<ComplianceChecklist>> getChecklistsByCategory(
    String projectId,
    ComplianceCategory category,
  ) async {
    try {
      final allChecklists = await getProjectChecklists(projectId);
      return allChecklists
          .where((checklist) => checklist.category == category)
          .toList();
    } catch (e) {
      throw Exception('Failed to get checklists by category: $e');
    }
  }

  @override
  Future<List<ComplianceChecklist>> getChecklistsByStatus(
    String projectId,
    ComplianceStatus status,
  ) async {
    try {
      final allChecklists = await getProjectChecklists(projectId);
      return allChecklists
          .where((checklist) => checklist.status == status)
          .toList();
    } catch (e) {
      throw Exception('Failed to get checklists by status: $e');
    }
  }

  @override
  Stream<ComplianceChecklist> watchChecklist(String id) {
    return _checklistsRef.child(id).onValue.map((event) {
      if (!event.snapshot.exists) {
        throw Exception('Checklist not found');
      }
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return ComplianceChecklist.fromJson(data);
    });
  }

  @override
  Stream<List<ComplianceChecklist>> watchProjectChecklists(String projectId) {
    return _checklistsRef
        .orderByChild('projectId')
        .equalTo(projectId)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return <ComplianceChecklist>[];

      final checklists = <ComplianceChecklist>[];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      for (final entry in data.entries) {
        final checklistData = Map<String, dynamic>.from(entry.value as Map);
        checklists.add(ComplianceChecklist.fromJson(checklistData));
      }

      checklists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return checklists;
    });
  }

  @override
  Future<void> updateChecklistItem(
    String checklistId,
    ChecklistItem item,
  ) async {
    try {
      final checklist = await getChecklistById(checklistId);
      if (checklist == null) {
        throw Exception('Checklist not found');
      }

      final updatedItems = checklist.items.map((i) {
        return i.id == item.id ? item : i;
      }).toList();

      final allCompleted = updatedItems.every((i) => i.isCompleted);
      final updatedChecklist = checklist.copyWith(
        items: updatedItems,
        status: allCompleted
            ? ComplianceStatus.completed
            : ComplianceStatus.inProgress,
        completedAt: allCompleted ? DateTime.now() : null,
      );

      await updateChecklist(updatedChecklist);
    } catch (e) {
      throw Exception('Failed to update checklist item: $e');
    }
  }

  // Audit trail operations

  @override
  Future<AuditTrail> createAuditEntry(AuditTrail entry) async {
    try {
      await _auditTrailRef.child(entry.id).set(entry.toJson());
      await _auditTrailBox.put(entry.id, entry.toJson());
      return entry;
    } catch (e) {
      throw Exception('Failed to create audit entry: $e');
    }
  }

  @override
  Future<List<AuditTrail>> getProjectAuditTrail(
    String projectId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      final snapshot = await _auditTrailRef
          .orderByChild('projectId')
          .equalTo(projectId)
          .limitToLast(limit)
          .get();

      if (!snapshot.exists) return [];

      final entries = <AuditTrail>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        final auditData = Map<String, dynamic>.from(entry.value as Map);
        final audit = AuditTrail.fromJson(auditData);

        if (startDate != null && audit.timestamp.isBefore(startDate)) continue;
        if (endDate != null && audit.timestamp.isAfter(endDate)) continue;

        entries.add(audit);
      }

      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return entries;
    } catch (e) {
      throw Exception('Failed to get project audit trail: $e');
    }
  }

  @override
  Future<List<AuditTrail>> getUserAuditTrail(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final snapshot = await _auditTrailRef
          .orderByChild('userId')
          .equalTo(userId)
          .get();

      if (!snapshot.exists) return [];

      final entries = <AuditTrail>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        final auditData = Map<String, dynamic>.from(entry.value as Map);
        final audit = AuditTrail.fromJson(auditData);

        if (startDate != null && audit.timestamp.isBefore(startDate)) continue;
        if (endDate != null && audit.timestamp.isAfter(endDate)) continue;

        entries.add(audit);
      }

      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return entries;
    } catch (e) {
      throw Exception('Failed to get user audit trail: $e');
    }
  }

  @override
  Future<List<AuditTrail>> getEntityAuditTrail(
    String entityType,
    String entityId,
  ) async {
    try {
      final snapshot = await _auditTrailRef
          .orderByChild('entityId')
          .equalTo(entityId)
          .get();

      if (!snapshot.exists) return [];

      final entries = <AuditTrail>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        final auditData = Map<String, dynamic>.from(entry.value as Map);
        final audit = AuditTrail.fromJson(auditData);

        if (audit.entityType == entityType) {
          entries.add(audit);
        }
      }

      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return entries;
    } catch (e) {
      throw Exception('Failed to get entity audit trail: $e');
    }
  }

  @override
  Stream<AuditTrail> watchProjectAuditTrail(String projectId) {
    return _auditTrailRef
        .orderByChild('projectId')
        .equalTo(projectId)
        .onChildAdded
        .map((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return AuditTrail.fromJson(data);
    });
  }
}