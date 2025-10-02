import '../../../features/documents/models/document_model.dart';

/// Repository interface for document management operations
abstract class DocumentRepository {
  /// Upload a new document
  Future<DocumentModel> uploadDocument(DocumentModel document, String filePath);

  /// Get document by ID
  Future<DocumentModel?> getDocumentById(String id);

  /// Get all documents
  Future<List<DocumentModel>> getAllDocuments();

  /// Get documents by project
  Future<List<DocumentModel>> getDocumentsByProject(String projectId);

  /// Get documents by agency
  Future<List<DocumentModel>> getDocumentsByAgency(String agencyId);

  /// Get documents by type
  Future<List<DocumentModel>> getDocumentsByType(DocumentType type);

  /// Get documents by status
  Future<List<DocumentModel>> getDocumentsByStatus(DocumentStatus status);

  /// Get documents uploaded by user
  Future<List<DocumentModel>> getDocumentsByUploader(String userId);

  /// Search documents by text (name, description, OCR text)
  Future<List<DocumentModel>> searchDocuments(String query);

  /// Update document metadata
  Future<DocumentModel> updateDocument(DocumentModel document);

  /// Delete document
  Future<void> deleteDocument(String id);

  /// Add new version to document
  Future<DocumentModel> addDocumentVersion(
    String documentId,
    DocumentVersion version,
  );

  /// Add approval to document
  Future<DocumentModel> addApproval(
    String documentId,
    DocumentApproval approval,
  );

  /// Update document status
  Future<DocumentModel> updateDocumentStatus(
    String documentId,
    DocumentStatus newStatus,
  );

  /// Perform OCR on document
  Future<String> performOCR(String filePath);

  /// Generate document thumbnail
  Future<String> generateThumbnail(String filePath);

  /// Get documents expiring soon (within days)
  Future<List<DocumentModel>> getExpiringDocuments(int withinDays);

  /// Get documents by tags
  Future<List<DocumentModel>> getDocumentsByTags(List<String> tags);

  /// Stream real-time document updates
  Stream<List<DocumentModel>> streamDocuments();

  /// Stream updates for a specific document
  Stream<DocumentModel> streamDocumentById(String id);

  /// Get document statistics
  Future<DocumentStatistics> getDocumentStatistics();
}

/// Statistics for document management
class DocumentStatistics {
  final int totalDocuments;
  final int pendingApprovals;
  final int approvedDocuments;
  final int expiringDocuments;
  final Map<DocumentType, int> documentsByType;
  final Map<DocumentStatus, int> documentsByStatus;
  final int totalStorageBytes;
  final int documentsWithOCR;

  const DocumentStatistics({
    required this.totalDocuments,
    required this.pendingApprovals,
    required this.approvedDocuments,
    required this.expiringDocuments,
    required this.documentsByType,
    required this.documentsByStatus,
    required this.totalStorageBytes,
    required this.documentsWithOCR,
  });
}