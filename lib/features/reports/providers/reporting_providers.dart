import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/reporting_service.dart';
import '../../../core/repositories/agency_repository.dart';
import '../../../core/repositories/fund_repository.dart';
import '../../../core/repositories/impl/agency_repository_impl.dart';
import '../../../core/repositories/impl/fund_repository_impl.dart';
import '../../../core/services/realtime_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../projects/providers/project_providers.dart';
import '../../citizen/providers/citizen_report_providers.dart';
import '../models/report_model.dart';

/// Provider for realtime service (if not already defined elsewhere)
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  return RealtimeService();
});

/// Provider for local storage service (if not already defined elsewhere)
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

/// Provider for agency repository
final agencyRepositoryProvider = Provider<AgencyRepository>((ref) {
  return AgencyRepositoryImpl(
    realtimeService: ref.watch(realtimeServiceProvider),
    localStorage: ref.watch(localStorageServiceProvider),
  );
});

/// Provider for fund repository
final fundRepositoryProvider = Provider<FundRepository>((ref) {
  return FundRepositoryImpl(
    realtimeService: ref.watch(realtimeServiceProvider),
    localStorage: ref.watch(localStorageServiceProvider),
  );
});

/// Provider for the reporting service
final reportingServiceProvider = Provider<ReportingService>((ref) {
  return ReportingService(
    projectRepo: ref.watch(projectRepositoryProvider),
    agencyRepo: ref.watch(agencyRepositoryProvider),
    fundRepo: ref.watch(fundRepositoryProvider),
    citizenReportRepo: ref.watch(citizenReportRepositoryProvider),
  );
});

/// Provider for dashboard metrics
final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) async {
  final service = ref.watch(reportingServiceProvider);
  return service.generateDashboardMetrics();
});

/// Provider for project performance report
final projectPerformanceReportProvider = FutureProvider.family<
    Map<String, dynamic>,
    ProjectPerformanceReportParams
>((ref, params) async {
  final service = ref.watch(reportingServiceProvider);
  return service.generateProjectPerformanceReport(
    projectId: params.projectId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// Provider for fund utilization report
final fundUtilizationReportProvider = FutureProvider.family<
    Map<String, dynamic>,
    FundUtilizationReportParams
>((ref, params) async {
  final service = ref.watch(reportingServiceProvider);
  return service.generateFundUtilizationReport(
    fundId: params.fundId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// Provider for agency coordination report
final agencyCoordinationReportProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(reportingServiceProvider);
  return service.generateAgencyCoordinationReport();
});

/// Provider for citizen engagement report
final citizenEngagementReportProvider = FutureProvider.family<
    Map<String, dynamic>,
    DateRangeParams
>((ref, params) async {
  final service = ref.watch(reportingServiceProvider);
  return service.generateCitizenEngagementReport(
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// Provider for project completion chart data
final projectCompletionChartProvider = FutureProvider<List<ChartData>>((ref) async {
  final service = ref.watch(reportingServiceProvider);
  return service.generateProjectCompletionChartData();
});

/// Provider for budget utilization chart data
final budgetUtilizationChartProvider = FutureProvider<List<ChartData>>((ref) async {
  final service = ref.watch(reportingServiceProvider);
  return service.generateBudgetUtilizationChartData();
});

/// Parameters for project performance report
class ProjectPerformanceReportParams {
  final String? projectId;
  final DateTime? startDate;
  final DateTime? endDate;

  const ProjectPerformanceReportParams({
    this.projectId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectPerformanceReportParams &&
          runtimeType == other.runtimeType &&
          projectId == other.projectId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode =>
      projectId.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}

/// Parameters for fund utilization report
class FundUtilizationReportParams {
  final String? fundId;
  final DateTime? startDate;
  final DateTime? endDate;

  const FundUtilizationReportParams({
    this.fundId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FundUtilizationReportParams &&
          runtimeType == other.runtimeType &&
          fundId == other.fundId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode =>
      fundId.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}

/// Parameters for date range queries
class DateRangeParams {
  final DateTime? startDate;
  final DateTime? endDate;

  const DateRangeParams({
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRangeParams &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}

/// State notifier for managing report filters and generation
class ReportFilterNotifier extends StateNotifier<ReportFilterState> {
  ReportFilterNotifier() : super(const ReportFilterState());

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void setProjectId(String? projectId) {
    state = state.copyWith(projectId: projectId);
  }

  void setFundId(String? fundId) {
    state = state.copyWith(fundId: fundId);
  }

  void setReportType(ReportType type) {
    state = state.copyWith(reportType: type);
  }

  void reset() {
    state = const ReportFilterState();
  }
}

/// State for report filters
class ReportFilterState {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? projectId;
  final String? fundId;
  final ReportType reportType;

  const ReportFilterState({
    this.startDate,
    this.endDate,
    this.projectId,
    this.fundId,
    this.reportType = ReportType.projectPerformance,
  });

  ReportFilterState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? projectId,
    String? fundId,
    ReportType? reportType,
  }) {
    return ReportFilterState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      projectId: projectId ?? this.projectId,
      fundId: fundId ?? this.fundId,
      reportType: reportType ?? this.reportType,
    );
  }
}

/// Provider for report filter state
final reportFilterProvider = StateNotifierProvider<ReportFilterNotifier, ReportFilterState>((ref) {
  return ReportFilterNotifier();
});

/// Provider for filtered report based on current filter state
final filteredReportProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final filter = ref.watch(reportFilterProvider);
  final service = ref.watch(reportingServiceProvider);

  switch (filter.reportType) {
    case ReportType.projectPerformance:
      return service.generateProjectPerformanceReport(
        projectId: filter.projectId,
        startDate: filter.startDate,
        endDate: filter.endDate,
      );
    case ReportType.fundUtilization:
      return service.generateFundUtilizationReport(
        fundId: filter.fundId,
        startDate: filter.startDate,
        endDate: filter.endDate,
      );
    case ReportType.agencyCoordination:
      return service.generateAgencyCoordinationReport();
    case ReportType.citizenEngagement:
      return service.generateCitizenEngagementReport(
        startDate: filter.startDate,
        endDate: filter.endDate,
      );
    default:
      return {};
  }
});