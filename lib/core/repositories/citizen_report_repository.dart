import '../../../features/citizen/models/citizen_report_model.dart';
import '../../../domain/entities/citizen.dart';

/// Repository interface for citizen report operations
abstract class CitizenReportRepository {
  /// Submit a new citizen report
  Future<CitizenReportModel> submitReport(CitizenReportModel report);

  /// Get report by ID
  Future<CitizenReportModel?> getReportById(String id);

  /// Get all reports for a specific citizen
  Future<List<CitizenReportModel>> getReportsByCitizen(String citizenId);

  /// Get reports by status
  Future<List<CitizenReportModel>> getReportsByStatus(ReportStatus status);

  /// Get reports by type
  Future<List<CitizenReportModel>> getReportsByType(ReportType type);

  /// Get reports within a radius (km) of a location
  Future<List<CitizenReportModel>> getReportsNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
  );

  /// Get trending reports (by upvotes)
  Future<List<CitizenReportModel>> getTrendingReports({int limit = 10});

  /// Update report status
  Future<CitizenReportModel> updateReportStatus(
    String reportId,
    ReportStatus newStatus,
  );

  /// Assign report to agency/officer
  Future<CitizenReportModel> assignReport(
    String reportId,
    String agencyId,
    String officerId,
  );

  /// Add upvote to report
  Future<CitizenReportModel> upvoteReport(String reportId, String userId);

  /// Remove upvote from report
  Future<CitizenReportModel> removeUpvote(String reportId, String userId);

  /// Add comment to report
  Future<CitizenReportModel> addComment(
    String reportId,
    ReportComment comment,
  );

  /// Get reports assigned to specific officer
  Future<List<CitizenReportModel>> getReportsAssignedToOfficer(
    String officerId,
  );

  /// Get reports assigned to specific agency
  Future<List<CitizenReportModel>> getReportsAssignedToAgency(
    String agencyId,
  );

  /// Search reports by text query
  Future<List<CitizenReportModel>> searchReports(String query);

  /// Stream real-time report updates
  Stream<List<CitizenReportModel>> streamReports();

  /// Stream updates for a specific report
  Stream<CitizenReportModel> streamReportById(String id);

  /// Delete report
  Future<void> deleteReport(String id);

  /// Get report statistics
  Future<ReportStatistics> getReportStatistics();
}

/// Statistics for citizen reports
class ReportStatistics {
  final int totalReports;
  final int pendingReports;
  final int assignedReports;
  final int resolvedReports;
  final Map<ReportType, int> reportsByType;
  final Map<ReportPriority, int> reportsByPriority;
  final double averageResolutionTimeHours;
  final List<CitizenReportModel> mostUpvotedReports;

  const ReportStatistics({
    required this.totalReports,
    required this.pendingReports,
    required this.assignedReports,
    required this.resolvedReports,
    required this.reportsByType,
    required this.reportsByPriority,
    required this.averageResolutionTimeHours,
    required this.mostUpvotedReports,
  });
}