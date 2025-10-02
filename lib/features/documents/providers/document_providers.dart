import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/document_repository.dart';
import '../../../core/repositories/impl/document_repository_impl.dart';
import '../../../core/services/realtime_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../models/document_model.dart';

// ===== Repository Provider =====

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  final localStorage = ref.watch(localStorageProvider);
  return DocumentRepositoryImpl(realtimeService, localStorage);
});

// Placeholder providers for dependencies
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  throw UnimplementedError('RealtimeService must be initialized in main.dart');
});

final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('LocalStorageService must be initialized in main.dart');
});

// ===== Data Providers =====

/// Provides all documents stream
final allDocumentsStreamProvider = StreamProvider<List<DocumentModel>>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.streamDocuments();
});

/// Provides all documents
final allDocumentsProvider = FutureProvider<List<DocumentModel>>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getAllDocuments();
});

/// Provides documents for a specific project
final projectDocumentsProvider = FutureProvider.family<List<DocumentModel>, String>(
  (ref, projectId) async {
    final repository = ref.watch(documentRepositoryProvider);
    return repository.getDocumentsByProject(projectId);
  },
);

/// Provides documents for a specific agency
final agencyDocumentsProvider = FutureProvider.family<List<DocumentModel>, String>(
  (ref, agencyId) async {
    final repository = ref.watch(documentRepositoryProvider);
    return repository.getDocumentsByAgency(agencyId);
  },
);

/// Provides documents by type
final documentsByTypeProvider = FutureProvider.family<List<DocumentModel>, DocumentType>(
  (ref, type) async {
    final repository = ref.watch(documentRepositoryProvider);
    return repository.getDocumentsByType(type);
  },
);

/// Provides documents by status
final documentsByStatusProvider = FutureProvider.family<List<DocumentModel>, DocumentStatus>(
  (ref, status) async {
    final repository = ref.watch(documentRepositoryProvider);
    return repository.getDocumentsByStatus(status);
  },
);

/// Provides documents uploaded by user
final userDocumentsProvider = FutureProvider.family<List<DocumentModel>, String>(
  (ref, userId) async {
    final repository = ref.watch(documentRepositoryProvider);
    return repository.getDocumentsByUploader(userId);
  },
);

/// Provides a specific document by ID
final documentByIdProvider = FutureProvider.family<DocumentModel?, String>(
  (ref, id) async {
    final repository = ref.watch(documentRepositoryProvider);
    return repository.getDocumentById(id);
  },
);

/// Streams a specific document by ID
final documentStreamProvider = StreamProvider.family<DocumentModel, String>(
  (ref, id) {
    final repository = ref.watch(documentRepositoryProvider);
    return repository.streamDocumentById(id);
  },
);

/// Provides expiring documents
final expiringDocumentsProvider = FutureProvider.family<List<DocumentModel>, int>(
  (ref, withinDays) async {
    final repository = ref.watch(documentRepositoryProvider);
    return repository.getExpiringDocuments(withinDays);
  },
);

/// Provides documents by tags
final documentsByTagsProvider = FutureProvider.family<List<DocumentModel>, List<String>>(
  (ref, tags) async {
    final repository = ref.watch(documentRepositoryProvider);
    return repository.getDocumentsByTags(tags);
  },
);

/// Provides document statistics
final documentStatisticsProvider = FutureProvider<DocumentStatistics>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getDocumentStatistics();
});

/// Provides search results
final documentSearchProvider = FutureProvider.family<List<DocumentModel>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];
    final repository = ref.watch(documentRepositoryProvider);
    return repository.searchDocuments(query);
  },
);

// ===== State Notifier for Document Management =====

class DocumentNotifier extends StateNotifier<AsyncValue<DocumentModel?>> {
  final DocumentRepository _repository;

  DocumentNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Upload a new document
  Future<void> uploadDocument(DocumentModel document, String filePath) async {
    state = const AsyncValue.loading();
    try {
      final newDocument = await _repository.uploadDocument(document, filePath);
      state = AsyncValue.data(newDocument);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update document metadata
  Future<void> updateDocument(DocumentModel document) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.updateDocument(document);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update document status
  Future<void> updateStatus(String documentId, DocumentStatus newStatus) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.updateDocumentStatus(documentId, newStatus);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add new version to document
  Future<void> addVersion(String documentId, DocumentVersion version) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.addDocumentVersion(documentId, version);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add approval to document
  Future<void> addApproval(String documentId, DocumentApproval approval) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.addApproval(documentId, approval);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete a document
  Future<void> deleteDocument(String documentId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteDocument(documentId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Perform OCR on document
  Future<String> performOCR(String filePath) async {
    return _repository.performOCR(filePath);
  }

  /// Clear current state
  void clear() {
    state = const AsyncValue.data(null);
  }
}

final documentNotifierProvider =
    StateNotifierProvider<DocumentNotifier, AsyncValue<DocumentModel?>>(
  (ref) {
    final repository = ref.watch(documentRepositoryProvider);
    return DocumentNotifier(repository);
  },
);

// ===== Filter State Management =====

class DocumentFilters {
  final DocumentType? type;
  final DocumentStatus? status;
  final String? projectId;
  final String? agencyId;
  final List<String>? tags;
  final String? searchQuery;

  const DocumentFilters({
    this.type,
    this.status,
    this.projectId,
    this.agencyId,
    this.tags,
    this.searchQuery,
  });

  DocumentFilters copyWith({
    DocumentType? type,
    DocumentStatus? status,
    String? projectId,
    String? agencyId,
    List<String>? tags,
    String? searchQuery,
  }) {
    return DocumentFilters(
      type: type ?? this.type,
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      agencyId: agencyId ?? this.agencyId,
      tags: tags ?? this.tags,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class DocumentFiltersNotifier extends StateNotifier<DocumentFilters> {
  DocumentFiltersNotifier() : super(const DocumentFilters());

  void setType(DocumentType? type) {
    state = state.copyWith(type: type);
  }

  void setStatus(DocumentStatus? status) {
    state = state.copyWith(status: status);
  }

  void setProjectId(String? projectId) {
    state = state.copyWith(projectId: projectId);
  }

  void setAgencyId(String? agencyId) {
    state = state.copyWith(agencyId: agencyId);
  }

  void setTags(List<String>? tags) {
    state = state.copyWith(tags: tags);
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = const DocumentFilters();
  }
}

final documentFiltersProvider =
    StateNotifierProvider<DocumentFiltersNotifier, DocumentFilters>(
  (ref) => DocumentFiltersNotifier(),
);

/// Provides filtered documents based on current filters
final filteredDocumentsProvider = FutureProvider<List<DocumentModel>>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  final filters = ref.watch(documentFiltersProvider);

  List<DocumentModel> documents;

  // Apply primary filter
  if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
    documents = await repository.searchDocuments(filters.searchQuery!);
  } else if (filters.projectId != null) {
    documents = await repository.getDocumentsByProject(filters.projectId!);
  } else if (filters.agencyId != null) {
    documents = await repository.getDocumentsByAgency(filters.agencyId!);
  } else if (filters.type != null) {
    documents = await repository.getDocumentsByType(filters.type!);
  } else if (filters.status != null) {
    documents = await repository.getDocumentsByStatus(filters.status!);
  } else if (filters.tags != null && filters.tags!.isNotEmpty) {
    documents = await repository.getDocumentsByTags(filters.tags!);
  } else {
    documents = await repository.getAllDocuments();
  }

  // Apply additional filters
  if (filters.type != null) {
    documents = documents.where((d) => d.type == filters.type).toList();
  }
  if (filters.status != null) {
    documents = documents.where((d) => d.status == filters.status).toList();
  }

  return documents;
});