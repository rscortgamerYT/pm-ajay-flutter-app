import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/repositories/compliance_repository.dart';
import '../data/repositories/compliance_repository_impl.dart';
import '../models/compliance_model.dart';

/// Provider for checklist Hive box
final checklistBoxProvider = FutureProvider<Box<Map<dynamic, dynamic>>>((ref) async {
  return await Hive.openBox<Map<dynamic, dynamic>>('compliance_checklists');
});

/// Provider for audit trail Hive box
final auditTrailBoxProvider = FutureProvider<Box<Map<dynamic, dynamic>>>((ref) async {
  return await Hive.openBox<Map<dynamic, dynamic>>('audit_trail');
});

/// Provider for ComplianceRepository
final complianceRepositoryProvider = Provider<ComplianceRepository>((ref) {
  final checklistBox = ref.watch(checklistBoxProvider).value;
  final auditTrailBox = ref.watch(auditTrailBoxProvider).value;

  if (checklistBox == null || auditTrailBox == null) {
    throw Exception('Compliance boxes not initialized');
  }

  return ComplianceRepositoryImpl(
    firebaseDatabase: FirebaseDatabase.instance,
    checklistBox: checklistBox,
    auditTrailBox: auditTrailBox,
  );
});

/// Provider for project checklists stream
final projectChecklistsProvider = StreamProvider.family<List<ComplianceChecklist>, String>((ref, projectId) {
  final repository = ref.watch(complianceRepositoryProvider);
  return repository.watchProjectChecklists(projectId);
});

/// Provider for single checklist stream
final checklistProvider = StreamProvider.family<ComplianceChecklist, String>((ref, checklistId) {
  final repository = ref.watch(complianceRepositoryProvider);
  return repository.watchChecklist(checklistId);
});

/// Provider for project audit trail
final projectAuditTrailProvider = FutureProvider.family<List<AuditTrail>, AuditTrailParams>((ref, params) async {
  final repository = ref.watch(complianceRepositoryProvider);
  return repository.getProjectAuditTrail(
    params.projectId,
    startDate: params.startDate,
    endDate: params.endDate,
    limit: params.limit,
  );
});

/// Provider for new audit entries stream
final newAuditEntriesProvider = StreamProvider.family<AuditTrail, String>((ref, projectId) {
  final repository = ref.watch(complianceRepositoryProvider);
  return repository.watchProjectAuditTrail(projectId);
});

/// Provider for checklists by category
final checklistsByCategoryProvider = FutureProvider.family<List<ComplianceChecklist>, ChecklistCategoryParams>((ref, params) async {
  final repository = ref.watch(complianceRepositoryProvider);
  return repository.getChecklistsByCategory(params.projectId, params.category);
});

/// Provider for checklists by status
final checklistsByStatusProvider = FutureProvider.family<List<ComplianceChecklist>, ChecklistStatusParams>((ref, params) async {
  final repository = ref.watch(complianceRepositoryProvider);
  return repository.getChecklistsByStatus(params.projectId, params.status);
});

/// Provider for compliance statistics
final complianceStatsProvider = FutureProvider.family<ComplianceStatistics, String>((ref, projectId) async {
  final repository = ref.watch(complianceRepositoryProvider);
  final checklists = await repository.getProjectChecklists(projectId);

  final totalItems = checklists.fold<int>(0, (sum, checklist) => sum + checklist.items.length);
  final completedItems = checklists.fold<int>(0, (sum, checklist) {
    return sum + checklist.items.where((item) => item.isCompleted).length;
  });

  return ComplianceStatistics(
    totalChecklists: checklists.length,
    completedChecklists: checklists.where((c) => c.status == ComplianceStatus.completed).length,
    inProgressChecklists: checklists.where((c) => c.status == ComplianceStatus.inProgress).length,
    pendingChecklists: checklists.where((c) => c.status == ComplianceStatus.pending).length,
    failedChecklists: checklists.where((c) => c.status == ComplianceStatus.failed).length,
    totalItems: totalItems,
    completedItems: completedItems,
    averageCompletion: checklists.isEmpty ? 0.0 : checklists.fold<double>(0.0, (sum, c) => sum + c.completionPercentage) / checklists.length,
  );
});

/// Parameters for audit trail queries
class AuditTrailParams {
  final String projectId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int limit;

  const AuditTrailParams({
    required this.projectId,
    this.startDate,
    this.endDate,
    this.limit = 100,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditTrailParams &&
        other.projectId == projectId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(projectId, startDate, endDate, limit);
}

/// Parameters for checklist category queries
class ChecklistCategoryParams {
  final String projectId;
  final ComplianceCategory category;

  const ChecklistCategoryParams({
    required this.projectId,
    required this.category,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChecklistCategoryParams &&
        other.projectId == projectId &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(projectId, category);
}

/// Parameters for checklist status queries
class ChecklistStatusParams {
  final String projectId;
  final ComplianceStatus status;

  const ChecklistStatusParams({
    required this.projectId,
    required this.status,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChecklistStatusParams &&
        other.projectId == projectId &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(projectId, status);
}

/// Compliance statistics model
class ComplianceStatistics {
  final int totalChecklists;
  final int completedChecklists;
  final int inProgressChecklists;
  final int pendingChecklists;
  final int failedChecklists;
  final int totalItems;
  final int completedItems;
  final double averageCompletion;

  const ComplianceStatistics({
    required this.totalChecklists,
    required this.completedChecklists,
    required this.inProgressChecklists,
    required this.pendingChecklists,
    required this.failedChecklists,
    required this.totalItems,
    required this.completedItems,
    required this.averageCompletion,
  });

  double get completionRate => totalItems > 0 ? completedItems / totalItems : 0.0;
  double get checklistCompletionRate => totalChecklists > 0 ? completedChecklists / totalChecklists : 0.0;
}