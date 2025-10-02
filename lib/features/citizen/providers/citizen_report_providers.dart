import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/citizen_report_repository.dart';
import '../../../core/repositories/impl/citizen_report_repository_impl.dart';
import '../../../core/services/realtime_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../models/citizen_report_model.dart';
import '../../../domain/entities/citizen.dart';

// ===== Repository Provider =====

final citizenReportRepositoryProvider = Provider<CitizenReportRepository>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  final localStorage = ref.watch(localStorageProvider);
  return CitizenReportRepositoryImpl(realtimeService, localStorage);
});

// Placeholder providers for dependencies
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  throw UnimplementedError('RealtimeService must be initialized in main.dart');
});

final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('LocalStorageService must be initialized in main.dart');
});

// ===== Data Providers =====

/// Provides all citizen reports stream
final allReportsStreamProvider = StreamProvider<List<CitizenReportModel>>((ref) {
  final repository = ref.watch(citizenReportRepositoryProvider);
  return repository.streamReports();
});

/// Provides reports for a specific citizen
final citizenReportsProvider = FutureProvider.family<List<CitizenReportModel>, String>(
  (ref, citizenId) async {
    final repository = ref.watch(citizenReportRepositoryProvider);
    return repository.getReportsByCitizen(citizenId);
  },
);

/// Provides reports by status
final reportsByStatusProvider = FutureProvider.family<List<CitizenReportModel>, ReportStatus>(
  (ref, status) async {
    final repository = ref.watch(citizenReportRepositoryProvider);
    return repository.getReportsByStatus(status);
  },
);

/// Provides reports by type
final reportsByTypeProvider = FutureProvider.family<List<CitizenReportModel>, ReportType>(
  (ref, type) async {
    final repository = ref.watch(citizenReportRepositoryProvider);
    return repository.getReportsByType(type);
  },
);

/// Provides trending reports
final trendingReportsProvider = FutureProvider<List<CitizenReportModel>>((ref) async {
  final repository = ref.watch(citizenReportRepositoryProvider);
  return repository.getTrendingReports(limit: 10);
});

/// Provides reports near a location
final reportsNearLocationProvider = FutureProvider.family<
    List<CitizenReportModel>,
    ({double latitude, double longitude, double radiusKm})>(
  (ref, params) async {
    final repository = ref.watch(citizenReportRepositoryProvider);
    return repository.getReportsNearLocation(
      params.latitude,
      params.longitude,
      params.radiusKm,
    );
  },
);

/// Provides a specific report by ID
final reportByIdProvider = FutureProvider.family<CitizenReportModel?, String>(
  (ref, id) async {
    final repository = ref.watch(citizenReportRepositoryProvider);
    return repository.getReportById(id);
  },
);

/// Streams a specific report by ID
final reportStreamProvider = StreamProvider.family<CitizenReportModel, String>(
  (ref, id) {
    final repository = ref.watch(citizenReportRepositoryProvider);
    return repository.streamReportById(id);
  },
);

/// Provides reports assigned to an officer
final officerReportsProvider = FutureProvider.family<List<CitizenReportModel>, String>(
  (ref, officerId) async {
    final repository = ref.watch(citizenReportRepositoryProvider);
    return repository.getReportsAssignedToOfficer(officerId);
  },
);

/// Provides reports assigned to an agency
final agencyReportsProvider = FutureProvider.family<List<CitizenReportModel>, String>(
  (ref, agencyId) async {
    final repository = ref.watch(citizenReportRepositoryProvider);
    return repository.getReportsAssignedToAgency(agencyId);
  },
);

/// Provides report statistics
final reportStatisticsProvider = FutureProvider<ReportStatistics>((ref) async {
  final repository = ref.watch(citizenReportRepositoryProvider);
  return repository.getReportStatistics();
});

/// Provides search results
final reportSearchProvider = FutureProvider.family<List<CitizenReportModel>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];
    final repository = ref.watch(citizenReportRepositoryProvider);
    return repository.searchReports(query);
  },
);

// ===== State Notifier for Report Management =====

class CitizenReportNotifier extends StateNotifier<AsyncValue<CitizenReportModel?>> {
  final CitizenReportRepository _repository;

  CitizenReportNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Submit a new report
  Future<void> submitReport(CitizenReportModel report) async {
    state = const AsyncValue.loading();
    try {
      final newReport = await _repository.submitReport(report);
      state = AsyncValue.data(newReport);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update report status
  Future<void> updateStatus(String reportId, ReportStatus newStatus) async {
    state = const AsyncValue.loading();
    try {
      final updatedReport = await _repository.updateReportStatus(reportId, newStatus);
      state = AsyncValue.data(updatedReport);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Assign report to agency and officer
  Future<void> assignReport(
    String reportId,
    String agencyId,
    String officerId,
  ) async {
    state = const AsyncValue.loading();
    try {
      final updatedReport = await _repository.assignReport(
        reportId,
        agencyId,
        officerId,
      );
      state = AsyncValue.data(updatedReport);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add upvote to report
  Future<void> upvoteReport(String reportId, String userId) async {
    try {
      final updatedReport = await _repository.upvoteReport(reportId, userId);
      state = AsyncValue.data(updatedReport);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Remove upvote from report
  Future<void> removeUpvote(String reportId, String userId) async {
    try {
      final updatedReport = await _repository.removeUpvote(reportId, userId);
      state = AsyncValue.data(updatedReport);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add comment to report
  Future<void> addComment(String reportId, ReportComment comment) async {
    try {
      final updatedReport = await _repository.addComment(reportId, comment);
      state = AsyncValue.data(updatedReport);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete a report
  Future<void> deleteReport(String reportId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteReport(reportId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Clear current state
  void clear() {
    state = const AsyncValue.data(null);
  }
}

final citizenReportNotifierProvider =
    StateNotifierProvider<CitizenReportNotifier, AsyncValue<CitizenReportModel?>>(
  (ref) {
    final repository = ref.watch(citizenReportRepositoryProvider);
    return CitizenReportNotifier(repository);
  },
);

// ===== Filter State Management =====

class ReportFilters {
  final ReportStatus? status;
  final ReportType? type;
  final ReportPriority? priority;
  final String? searchQuery;

  const ReportFilters({
    this.status,
    this.type,
    this.priority,
    this.searchQuery,
  });

  ReportFilters copyWith({
    ReportStatus? status,
    ReportType? type,
    ReportPriority? priority,
    String? searchQuery,
  }) {
    return ReportFilters(
      status: status ?? this.status,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ReportFiltersNotifier extends StateNotifier<ReportFilters> {
  ReportFiltersNotifier() : super(const ReportFilters());

  void setStatus(ReportStatus? status) {
    state = state.copyWith(status: status);
  }

  void setType(ReportType? type) {
    state = state.copyWith(type: type);
  }

  void setPriority(ReportPriority? priority) {
    state = state.copyWith(priority: priority);
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = const ReportFilters();
  }
}

final reportFiltersProvider =
    StateNotifierProvider<ReportFiltersNotifier, ReportFilters>(
  (ref) => ReportFiltersNotifier(),
);

/// Provides filtered reports based on current filters
final filteredReportsProvider = FutureProvider<List<CitizenReportModel>>((ref) async {
  final repository = ref.watch(citizenReportRepositoryProvider);
  final filters = ref.watch(reportFiltersProvider);

  List<CitizenReportModel> reports;

  // Apply primary filter
  if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
    reports = await repository.searchReports(filters.searchQuery!);
  } else if (filters.status != null) {
    reports = await repository.getReportsByStatus(filters.status!);
  } else if (filters.type != null) {
    reports = await repository.getReportsByType(filters.type!);
  } else {
    // Get all reports via stream (convert to future)
    reports = await repository.streamReports().first;
  }

  // Apply additional filters
  if (filters.priority != null) {
    reports = reports.where((r) => r.priority == filters.priority).toList();
  }

  return reports;
});