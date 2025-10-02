import '../../../features/documents/models/document_model.dart';
import '../document_repository.dart';
import '../../services/realtime_service.dart';
import '../../storage/local_storage_service.dart';

/// Concrete implementation of document repository
class DocumentRepositoryImpl implements DocumentRepository {
  final RealtimeService _realtimeService;
  final LocalStorageService _localStorage;

  // In-memory cache
  final Map<String, DocumentModel> _documentCache = {};
  final List<DocumentModel> _allDocumentsCache = [];
  DateTime? _lastCacheUpdate;

  DocumentRepositoryImpl(this._realtimeService, this._localStorage);

  // Cache management
  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!).inMinutes < 5;
  }

  void _invalidateCache() {
    _lastCacheUpdate = null;
    _documentCache.clear();
    _allDocumentsCache.clear();
  }

  Future<List<DocumentModel>> _getAllDocuments() async {
    if (_isCacheValid() && _allDocumentsCache.isNotEmpty) {
      return _allDocumentsCache;
    }

    final documents = await _realtimeService.getCollection<DocumentModel>(
      'documents',
      (data) => _fromJson(data),
    );

    _allDocumentsCache.clear();
    _allDocumentsCache.addAll(documents);
    _lastCacheUpdate = DateTime.now();

    for (final doc in documents) {
      _documentCache[doc.id] = doc;
    }

    return documents;
  }

  @override
  Future<DocumentModel> uploadDocument(
    DocumentModel document,
    String filePath,
  ) async {
    // TODO: Implement actual file upload to cloud storage
    // For now, simulate upload
    
    // Perform OCR if it's an image or PDF
    String? ocrText;
    if (_isOCRSupported(document.mimeType)) {
      try {
        ocrText = await performOCR(filePath);
      } catch (e) {
        // OCR failed, continue without it
      }
    }

    // Generate thumbnail if applicable
    String? thumbnailUrl;
    if (_isThumbnailSupported(document.mimeType)) {
      try {
        thumbnailUrl = await generateThumbnail(filePath);
      } catch (e) {
        // Thumbnail generation failed, continue without it
      }
    }

    final updatedDocument = document.copyWith(
      ocrText: ocrText,
      thumbnailUrl: thumbnailUrl,
    );

    final newDocument = await _realtimeService.create(
      'documents',
      updatedDocument.id,
      _toJson(updatedDocument),
    );

    final created = _fromJson(newDocument);
    _documentCache[created.id] = created;
    _invalidateCache();

    return created;
  }

  @override
  Future<DocumentModel?> getDocumentById(String id) async {
    if (_documentCache.containsKey(id)) {
      return _documentCache[id];
    }

    final data = await _realtimeService.get('documents', id);
    if (data == null) return null;

    final document = _fromJson(data);
    _documentCache[id] = document;

    return document;
  }

  @override
  Future<List<DocumentModel>> getAllDocuments() async {
    return _getAllDocuments();
  }

  @override
  Future<List<DocumentModel>> getDocumentsByProject(String projectId) async {
    final allDocs = await _getAllDocuments();
    return allDocs.where((d) => d.projectId == projectId).toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  @override
  Future<List<DocumentModel>> getDocumentsByAgency(String agencyId) async {
    final allDocs = await _getAllDocuments();
    return allDocs.where((d) => d.agencyId == agencyId).toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  @override
  Future<List<DocumentModel>> getDocumentsByType(DocumentType type) async {
    final allDocs = await _getAllDocuments();
    return allDocs.where((d) => d.type == type).toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  @override
  Future<List<DocumentModel>> getDocumentsByStatus(
    DocumentStatus status,
  ) async {
    final allDocs = await _getAllDocuments();
    return allDocs.where((d) => d.status == status).toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  @override
  Future<List<DocumentModel>> getDocumentsByUploader(String userId) async {
    final allDocs = await _getAllDocuments();
    return allDocs.where((d) => d.uploadedBy == userId).toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  @override
  Future<List<DocumentModel>> searchDocuments(String query) async {
    final allDocs = await _getAllDocuments();
    final lowerQuery = query.toLowerCase();

    return allDocs.where((doc) {
      return doc.name.toLowerCase().contains(lowerQuery) ||
          doc.description.toLowerCase().contains(lowerQuery) ||
          (doc.ocrText?.toLowerCase().contains(lowerQuery) ?? false) ||
          doc.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  @override
  Future<DocumentModel> updateDocument(DocumentModel document) async {
    await _realtimeService.update(
      'documents',
      document.id,
      _toJson(document),
    );

    _documentCache[document.id] = document;
    _invalidateCache();

    return document;
  }

  @override
  Future<void> deleteDocument(String id) async {
    await _realtimeService.delete('documents', id);
    _documentCache.remove(id);
    _invalidateCache();
  }

  @override
  Future<DocumentModel> addDocumentVersion(
    String documentId,
    DocumentVersion version,
  ) async {
    final document = await getDocumentById(documentId);
    if (document == null) {
      throw Exception('Document not found');
    }

    final updatedDocument = document.copyWith(
      versions: [...document.versions, version],
      updatedAt: DateTime.now(),
    );

    return updateDocument(updatedDocument);
  }

  @override
  Future<DocumentModel> addApproval(
    String documentId,
    DocumentApproval approval,
  ) async {
    final document = await getDocumentById(documentId);
    if (document == null) {
      throw Exception('Document not found');
    }

    final updatedDocument = document.copyWith(
      approvals: [...document.approvals, approval],
      updatedAt: DateTime.now(),
    );

    // Auto-update status if all approvals are in
    // TODO: Implement approval logic based on business rules

    return updateDocument(updatedDocument);
  }

  @override
  Future<DocumentModel> updateDocumentStatus(
    String documentId,
    DocumentStatus newStatus,
  ) async {
    final document = await getDocumentById(documentId);
    if (document == null) {
      throw Exception('Document not found');
    }

    final updatedDocument = document.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    return updateDocument(updatedDocument);
  }

  @override
  Future<String> performOCR(String filePath) async {
    // TODO: Implement actual OCR using Google ML Kit or Tesseract
    // For now, return placeholder
    return 'OCR text extraction coming soon';
  }

  @override
  Future<String> generateThumbnail(String filePath) async {
    // TODO: Implement actual thumbnail generation
    // For now, return placeholder
    return 'thumbnail_url_placeholder';
  }

  @override
  Future<List<DocumentModel>> getExpiringDocuments(int withinDays) async {
    final allDocs = await _getAllDocuments();
    final now = DateTime.now();
    final threshold = now.add(Duration(days: withinDays));

    return allDocs.where((doc) {
      if (doc.expiryDate == null) return false;
      return doc.expiryDate!.isAfter(now) &&
          doc.expiryDate!.isBefore(threshold);
    }).toList()
      ..sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));
  }

  @override
  Future<List<DocumentModel>> getDocumentsByTags(List<String> tags) async {
    final allDocs = await _getAllDocuments();
    return allDocs.where((doc) {
      return tags.any((tag) => doc.tags.contains(tag));
    }).toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  @override
  Stream<List<DocumentModel>> streamDocuments() {
    return _realtimeService
        .streamCollection<DocumentModel>(
          'documents',
          (data) => _fromJson(data),
        )
        .map((documents) {
      _allDocumentsCache.clear();
      _allDocumentsCache.addAll(documents);
      _lastCacheUpdate = DateTime.now();

      for (final doc in documents) {
        _documentCache[doc.id] = doc;
      }

      return documents;
    });
  }

  @override
  Stream<DocumentModel> streamDocumentById(String id) {
    return _realtimeService
        .stream<DocumentModel>(
          'documents',
          id,
          (data) => _fromJson(data),
        )
        .map((doc) {
      _documentCache[id] = doc;
      return doc;
    });
  }

  @override
  Future<DocumentStatistics> getDocumentStatistics() async {
    final allDocs = await _getAllDocuments();

    final totalDocuments = allDocs.length;
    final pendingApprovals =
        allDocs.where((d) => d.status == DocumentStatus.pending).length;
    final approvedDocuments =
        allDocs.where((d) => d.status == DocumentStatus.approved).length;

    final now = DateTime.now();
    final expiringDocuments = allDocs.where((d) {
      if (d.expiryDate == null) return false;
      return d.expiryDate!.isAfter(now) &&
          d.expiryDate!.isBefore(now.add(const Duration(days: 30)));
    }).length;

    final documentsByType = <DocumentType, int>{};
    for (final type in DocumentType.values) {
      documentsByType[type] = allDocs.where((d) => d.type == type).length;
    }

    final documentsByStatus = <DocumentStatus, int>{};
    for (final status in DocumentStatus.values) {
      documentsByStatus[status] =
          allDocs.where((d) => d.status == status).length;
    }

    final totalStorageBytes =
        allDocs.fold<int>(0, (sum, doc) => sum + doc.fileSizeBytes);

    final documentsWithOCR = allDocs.where((d) => d.ocrText != null).length;

    return DocumentStatistics(
      totalDocuments: totalDocuments,
      pendingApprovals: pendingApprovals,
      approvedDocuments: approvedDocuments,
      expiringDocuments: expiringDocuments,
      documentsByType: documentsByType,
      documentsByStatus: documentsByStatus,
      totalStorageBytes: totalStorageBytes,
      documentsWithOCR: documentsWithOCR,
    );
  }

  // Helper methods
  bool _isOCRSupported(String mimeType) {
    return mimeType.contains('image') || mimeType.contains('pdf');
  }

  bool _isThumbnailSupported(String mimeType) {
    return mimeType.contains('image') ||
        mimeType.contains('pdf') ||
        mimeType.contains('video');
  }

  // JSON serialization helpers
  Map<String, dynamic> _toJson(DocumentModel doc) {
    return {
      'id': doc.id,
      'name': doc.name,
      'description': doc.description,
      'type': doc.type.toString(),
      'fileUrl': doc.fileUrl,
      'thumbnailUrl': doc.thumbnailUrl,
      'fileSizeBytes': doc.fileSizeBytes,
      'mimeType': doc.mimeType,
      'uploadedBy': doc.uploadedBy,
      'projectId': doc.projectId,
      'agencyId': doc.agencyId,
      'status': doc.status.toString(),
      'tags': doc.tags,
      'metadata': doc.metadata,
      'ocrText': doc.ocrText,
      'isConfidential': doc.isConfidential,
      'uploadedAt': doc.uploadedAt.toIso8601String(),
      'expiryDate': doc.expiryDate?.toIso8601String(),
      'updatedAt': doc.updatedAt.toIso8601String(),
      'versions': doc.versions.map((v) => {
        'id': v.id,
        'versionNumber': v.versionNumber,
        'fileUrl': v.fileUrl,
        'uploadedBy': v.uploadedBy,
        'changeDescription': v.changeDescription,
        'uploadedAt': v.uploadedAt.toIso8601String(),
      }).toList(),
      'approvals': doc.approvals.map((a) => {
        'id': a.id,
        'approverId': a.approverId,
        'approverName': a.approverName,
        'approved': a.approved,
        'comments': a.comments,
        'timestamp': a.timestamp.toIso8601String(),
      }).toList(),
    };
  }

  DocumentModel _fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: DocumentType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      fileUrl: json['fileUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      fileSizeBytes: json['fileSizeBytes'] as int,
      mimeType: json['mimeType'] as String,
      uploadedBy: json['uploadedBy'] as String,
      projectId: json['projectId'] as String?,
      agencyId: json['agencyId'] as String?,
      status: DocumentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
      ocrText: json['ocrText'] as String?,
      isConfidential: json['isConfidential'] as bool? ?? false,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      versions: (json['versions'] as List<dynamic>?)
              ?.map((v) => DocumentVersion(
                    id: v['id'] as String,
                    versionNumber: v['versionNumber'] as int,
                    fileUrl: v['fileUrl'] as String,
                    uploadedBy: v['uploadedBy'] as String,
                    changeDescription: v['changeDescription'] as String?,
                    uploadedAt: DateTime.parse(v['uploadedAt'] as String),
                  ))
              .toList() ??
          [],
      approvals: (json['approvals'] as List<dynamic>?)
              ?.map((a) => DocumentApproval(
                    id: a['id'] as String,
                    approverId: a['approverId'] as String,
                    approverName: a['approverName'] as String,
                    approved: a['approved'] as bool,
                    comments: a['comments'] as String?,
                    timestamp: DateTime.parse(a['timestamp'] as String),
                  ))
              .toList() ??
          [],
    );
  }
}