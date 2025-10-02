import '../../features/compliance/models/compliance_model.dart';

/// Abstract repository for compliance-related operations
abstract class ComplianceRepository {
  // Compliance checklist operations
  Future<ComplianceChecklist> createChecklist(ComplianceChecklist checklist);
  Future<ComplianceChecklist> updateChecklist(ComplianceChecklist checklist);
  Future<void> deleteChecklist(String checklistId);
  Future<ComplianceChecklist?> getChecklistById(String id);
  Future<List<ComplianceChecklist>> getProjectChecklists(String projectId);
  Future<List<ComplianceChecklist>> getChecklistsByCategory(
    String projectId,
    ComplianceCategory category,
  );
  Future<List<ComplianceChecklist>> getChecklistsByStatus(
    String projectId,
    ComplianceStatus status,
  );
  Stream<ComplianceChecklist> watchChecklist(String id);
  Stream<List<ComplianceChecklist>> watchProjectChecklists(String projectId);

  // Checklist item operations
  Future<void> updateChecklistItem(
    String checklistId,
    ChecklistItem item,
  );

  // Audit trail operations
  Future<AuditTrail> createAuditEntry(AuditTrail entry);
  Future<List<AuditTrail>> getProjectAuditTrail(
    String projectId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  });
  Future<List<AuditTrail>> getUserAuditTrail(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<AuditTrail>> getEntityAuditTrail(
    String entityType,
    String entityId,
  );
  Stream<AuditTrail> watchProjectAuditTrail(String projectId);
}