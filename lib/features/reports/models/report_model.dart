import 'package:equatable/equatable.dart';

/// Represents an analytical report in the system
class AnalyticalReport extends Equatable {
  final String id;
  final String name;
  final String description;
  final ReportType type;
  final ReportFormat format;
  final String generatedBy;
  final ReportStatus status;
  final Map<String, dynamic> filters;
  final Map<String, dynamic> data;
  final DateTime generatedAt;
  final DateTime? scheduledAt;
  final List<String> recipients;
  final bool isScheduled;
  final String? scheduleFrequency; // daily, weekly, monthly
  final DateTime? nextScheduledRun;

  const AnalyticalReport({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.format,
    required this.generatedBy,
    required this.status,
    required this.filters,
    required this.data,
    required this.generatedAt,
    this.scheduledAt,
    this.recipients = const [],
    this.isScheduled = false,
    this.scheduleFrequency,
    this.nextScheduledRun,
  });

  AnalyticalReport copyWith({
    String? id,
    String? name,
    String? description,
    ReportType? type,
    ReportFormat? format,
    String? generatedBy,
    ReportStatus? status,
    Map<String, dynamic>? filters,
    Map<String, dynamic>? data,
    DateTime? generatedAt,
    DateTime? scheduledAt,
    List<String>? recipients,
    bool? isScheduled,
    String? scheduleFrequency,
    DateTime? nextScheduledRun,
  }) {
    return AnalyticalReport(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      format: format ?? this.format,
      generatedBy: generatedBy ?? this.generatedBy,
      status: status ?? this.status,
      filters: filters ?? this.filters,
      data: data ?? this.data,
      generatedAt: generatedAt ?? this.generatedAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      recipients: recipients ?? this.recipients,
      isScheduled: isScheduled ?? this.isScheduled,
      scheduleFrequency: scheduleFrequency ?? this.scheduleFrequency,
      nextScheduledRun: nextScheduledRun ?? this.nextScheduledRun,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        format,
        generatedBy,
        status,
        filters,
        data,
        generatedAt,
        scheduledAt,
        recipients,
        isScheduled,
        scheduleFrequency,
        nextScheduledRun,
      ];
}

enum ReportType {
  projectPerformance,
  fundUtilization,
  agencyCoordination,
  citizenEngagement,
  complianceStatus,
  timelineAnalysis,
  budgetVariance,
  riskAssessment,
  custom,
}

enum ReportFormat {
  pdf,
  excel,
  csv,
  json,
}

enum ReportStatus {
  generating,
  completed,
  failed,
}

/// Represents dashboard metrics
class DashboardMetrics extends Equatable {
  final int totalProjects;
  final int activeProjects;
  final int completedProjects;
  final int delayedProjects;
  final double totalBudget;
  final double utilizedBudget;
  final double budgetUtilizationPercentage;
  final int totalAgencies;
  final int totalCitizens;
  final int totalReports;
  final double averageProjectCompletion;
  final Map<String, int> projectsByStatus;
  final Map<String, double> budgetByAgency;
  final List<ProjectTrend> recentTrends;

  const DashboardMetrics({
    required this.totalProjects,
    required this.activeProjects,
    required this.completedProjects,
    required this.delayedProjects,
    required this.totalBudget,
    required this.utilizedBudget,
    required this.budgetUtilizationPercentage,
    required this.totalAgencies,
    required this.totalCitizens,
    required this.totalReports,
    required this.averageProjectCompletion,
    required this.projectsByStatus,
    required this.budgetByAgency,
    required this.recentTrends,
  });

  @override
  List<Object?> get props => [
        totalProjects,
        activeProjects,
        completedProjects,
        delayedProjects,
        totalBudget,
        utilizedBudget,
        budgetUtilizationPercentage,
        totalAgencies,
        totalCitizens,
        totalReports,
        averageProjectCompletion,
        projectsByStatus,
        budgetByAgency,
        recentTrends,
      ];
}

class ProjectTrend extends Equatable {
  final String projectId;
  final String projectName;
  final double completionChange;
  final double budgetChange;
  final DateTime timestamp;

  const ProjectTrend({
    required this.projectId,
    required this.projectName,
    required this.completionChange,
    required this.budgetChange,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        projectId,
        projectName,
        completionChange,
        budgetChange,
        timestamp,
      ];
}

/// Represents chart data for visualizations
class ChartData extends Equatable {
  final String label;
  final double value;
  final String? category;
  final DateTime? timestamp;

  const ChartData({
    required this.label,
    required this.value,
    this.category,
    this.timestamp,
  });

  @override
  List<Object?> get props => [label, value, category, timestamp];
}