import 'dart:math';
import '../../../features/citizen/models/citizen_report_model.dart';
import '../../../domain/entities/citizen.dart';
import '../citizen_report_repository.dart';
import '../../services/realtime_service.dart';
import '../../storage/local_storage_service.dart';

/// Concrete implementation of citizen report repository
class CitizenReportRepositoryImpl implements CitizenReportRepository {
  final RealtimeService _realtimeService;
  final LocalStorageService _localStorage;

  // In-memory cache
  final Map<String, CitizenReportModel> _reportCache = {};
  final List<CitizenReportModel> _allReportsCache = [];
  DateTime? _lastCacheUpdate;

  CitizenReportRepositoryImpl(this._realtimeService, this._localStorage);

  // Cache management
  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!).inMinutes < 5;
  }

  void _invalidateCache() {
    _lastCacheUpdate = null;
    _reportCache.clear();
    _allReportsCache.clear();
  }

  Future<List<CitizenReportModel>> _getAllReports() async {
    if (_isCacheValid() && _allReportsCache.isNotEmpty) {
      return _allReportsCache;
    }

    final reports = await _realtimeService.getCollection<CitizenReportModel>(
      'citizen_reports',
      (data) => _fromJson(data),
    );

    _allReportsCache.clear();
    _allReportsCache.addAll(reports);
    _lastCacheUpdate = DateTime.now();

    // Update individual cache
    for (final report in reports) {
      _reportCache[report.id] = report;
    }

    return reports;
  }

  @override
  Future<CitizenReportModel> submitReport(CitizenReportModel report) async {
    final newReport = await _realtimeService.create(
      'citizen_reports',
      report.id,
      _toJson(report),
    );

    final createdReport = _fromJson(newReport);
    _reportCache[createdReport.id] = createdReport;
    _invalidateCache();

    // Save to local storage for offline access
    await _localStorage.saveReport(createdReport);

    return createdReport;
  }

  @override
  Future<CitizenReportModel?> getReportById(String id) async {
    // Check cache first
    if (_reportCache.containsKey(id)) {
      return _reportCache[id];
    }

    // Check local storage
    final localReport = await _localStorage.getReport(id);
    if (localReport != null) {
      _reportCache[id] = localReport;
      return localReport;
    }

    // Fetch from remote
    final data = await _realtimeService.get('citizen_reports', id);
    if (data == null) return null;

    final report = _fromJson(data);
    _reportCache[id] = report;

    // Cache locally
    await _localStorage.saveReport(report);

    return report;
  }

  @override
  Future<List<CitizenReportModel>> getReportsByCitizen(String citizenId) async {
    final allReports = await _getAllReports();
    return allReports.where((r) => r.citizenId == citizenId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<CitizenReportModel>> getReportsByStatus(ReportStatus status) async {
    final allReports = await _getAllReports();
    return allReports.where((r) => r.status == status).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<CitizenReportModel>> getReportsByType(ReportType type) async {
    final allReports = await _getAllReports();
    return allReports.where((r) => r.type == type).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<CitizenReportModel>> getReportsNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    final allReports = await _getAllReports();
    return allReports.where((report) {
      if (report.latitude == null || report.longitude == null) return false;
      final distance = _calculateDistance(
        latitude,
        longitude,
        report.latitude!,
        report.longitude!,
      );
      return distance <= radiusKm;
    }).toList()
      ..sort((a, b) {
        final distA = _calculateDistance(latitude, longitude, a.latitude!, a.longitude!);
        final distB = _calculateDistance(latitude, longitude, b.latitude!, b.longitude!);
        return distA.compareTo(distB);
      });
  }

  @override
  Future<List<CitizenReportModel>> getTrendingReports({int limit = 10}) async {
    final allReports = await _getAllReports();
    final sorted = allReports.toList()
      ..sort((a, b) => b.upvotes.compareTo(a.upvotes));
    return sorted.take(limit).toList();
  }

  @override
  Future<CitizenReportModel> updateReportStatus(
    String reportId,
    ReportStatus newStatus,
  ) async {
    final report = await getReportById(reportId);
    if (report == null) {
      throw Exception('Report not found');
    }

    final updatedReport = report.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
      resolvedAt: newStatus == ReportStatus.resolved ? DateTime.now() : null,
    );

    await _realtimeService.update(
      'citizen_reports',
      reportId,
      _toJson(updatedReport),
    );

    _reportCache[reportId] = updatedReport;
    _invalidateCache();

    await _localStorage.saveReport(updatedReport);

    return updatedReport;
  }

  @override
  Future<CitizenReportModel> assignReport(
    String reportId,
    String agencyId,
    String officerId,
  ) async {
    final report = await getReportById(reportId);
    if (report == null) {
      throw Exception('Report not found');
    }

    final updatedReport = report.copyWith(
      assignedAgencyId: agencyId,
      assignedOfficerId: officerId,
      status: ReportStatus.assigned,
      assignedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _realtimeService.update(
      'citizen_reports',
      reportId,
      _toJson(updatedReport),
    );

    _reportCache[reportId] = updatedReport;
    _invalidateCache();

    await _localStorage.saveReport(updatedReport);

    return updatedReport;
  }

  @override
  Future<CitizenReportModel> upvoteReport(String reportId, String userId) async {
    final report = await getReportById(reportId);
    if (report == null) {
      throw Exception('Report not found');
    }

    if (report.upvotedBy.contains(userId)) {
      return report; // Already upvoted
    }

    final updatedReport = report.copyWith(
      upvotes: report.upvotes + 1,
      upvotedBy: [...report.upvotedBy, userId],
      updatedAt: DateTime.now(),
    );

    await _realtimeService.update(
      'citizen_reports',
      reportId,
      _toJson(updatedReport),
    );

    _reportCache[reportId] = updatedReport;
    _invalidateCache();

    return updatedReport;
  }

  @override
  Future<CitizenReportModel> removeUpvote(String reportId, String userId) async {
    final report = await getReportById(reportId);
    if (report == null) {
      throw Exception('Report not found');
    }

    if (!report.upvotedBy.contains(userId)) {
      return report; // Not upvoted
    }

    final updatedReport = report.copyWith(
      upvotes: report.upvotes - 1,
      upvotedBy: report.upvotedBy.where((id) => id != userId).toList(),
      updatedAt: DateTime.now(),
    );

    await _realtimeService.update(
      'citizen_reports',
      reportId,
      _toJson(updatedReport),
    );

    _reportCache[reportId] = updatedReport;
    _invalidateCache();

    return updatedReport;
  }

  @override
  Future<CitizenReportModel> addComment(
    String reportId,
    ReportComment comment,
  ) async {
    final report = await getReportById(reportId);
    if (report == null) {
      throw Exception('Report not found');
    }

    final updatedReport = report.copyWith(
      comments: [...report.comments, comment],
      updatedAt: DateTime.now(),
    );

    await _realtimeService.update(
      'citizen_reports',
      reportId,
      _toJson(updatedReport),
    );

    _reportCache[reportId] = updatedReport;
    _invalidateCache();

    return updatedReport;
  }

  @override
  Future<List<CitizenReportModel>> getReportsAssignedToOfficer(
    String officerId,
  ) async {
    final allReports = await _getAllReports();
    return allReports.where((r) => r.assignedOfficerId == officerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<CitizenReportModel>> getReportsAssignedToAgency(
    String agencyId,
  ) async {
    final allReports = await _getAllReports();
    return allReports.where((r) => r.assignedAgencyId == agencyId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<CitizenReportModel>> searchReports(String query) async {
    final allReports = await _getAllReports();
    final lowerQuery = query.toLowerCase();

    return allReports.where((report) {
      return report.title.toLowerCase().contains(lowerQuery) ||
          report.description.toLowerCase().contains(lowerQuery) ||
          (report.address?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Stream<List<CitizenReportModel>> streamReports() {
    return _realtimeService
        .streamCollection<CitizenReportModel>(
          'citizen_reports',
          (data) => _fromJson(data),
        )
        .map((reports) {
      // Update cache
      _allReportsCache.clear();
      _allReportsCache.addAll(reports);
      _lastCacheUpdate = DateTime.now();

      for (final report in reports) {
        _reportCache[report.id] = report;
      }

      return reports;
    });
  }

  @override
  Stream<CitizenReportModel> streamReportById(String id) {
    return _realtimeService
        .stream<CitizenReportModel>(
          'citizen_reports',
          id,
          (data) => _fromJson(data),
        )
        .map((report) {
      _reportCache[id] = report;
      return report;
    });
  }

  @override
  Future<void> deleteReport(String id) async {
    await _realtimeService.delete('citizen_reports', id);
    _reportCache.remove(id);
    _invalidateCache();
    await _localStorage.deleteReport(id);
  }

  @override
  Future<ReportStatistics> getReportStatistics() async {
    final allReports = await _getAllReports();

    final totalReports = allReports.length;
    final pendingReports = allReports.where((r) => r.status == ReportStatus.submitted).length;
    final assignedReports = allReports.where((r) => r.status == ReportStatus.assigned).length;
    final resolvedReports = allReports.where((r) => r.status == ReportStatus.resolved).length;

    // Reports by type
    final reportsByType = <ReportType, int>{};
    for (final type in ReportType.values) {
      reportsByType[type] = allReports.where((r) => r.type == type).length;
    }

    // Reports by priority
    final reportsByPriority = <ReportPriority, int>{};
    for (final priority in ReportPriority.values) {
      reportsByPriority[priority] = allReports.where((r) => r.priority == priority).length;
    }

    // Average resolution time
    final resolvedWithTime = allReports.where(
      (r) => r.status == ReportStatus.resolved && r.resolvedAt != null,
    );
    
    double averageResolutionTimeHours = 0;
    if (resolvedWithTime.isNotEmpty) {
      final totalHours = resolvedWithTime.fold<double>(
        0,
        (sum, r) => sum + r.resolvedAt!.difference(r.createdAt).inHours,
      );
      averageResolutionTimeHours = totalHours / resolvedWithTime.length;
    }

    // Most upvoted reports
    final sorted = allReports.toList()
      ..sort((a, b) => b.upvotes.compareTo(a.upvotes));
    final mostUpvotedReports = sorted.take(5).toList();

    return ReportStatistics(
      totalReports: totalReports,
      pendingReports: pendingReports,
      assignedReports: assignedReports,
      resolvedReports: resolvedReports,
      reportsByType: reportsByType,
      reportsByPriority: reportsByPriority,
      averageResolutionTimeHours: averageResolutionTimeHours,
      mostUpvotedReports: mostUpvotedReports,
    );
  }

  // Helper: Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * pi / 180;

  // JSON serialization helpers
  Map<String, dynamic> _toJson(CitizenReportModel report) {
    return {
      'id': report.id,
      'citizenId': report.citizenId,
      'projectId': report.projectId,
      'type': report.type.toString(),
      'title': report.title,
      'description': report.description,
      'priority': report.priority.toString(),
      'status': report.status.toString(),
      'attachments': report.attachments,
      'latitude': report.latitude,
      'longitude': report.longitude,
      'address': report.address,
      'assignedAgencyId': report.assignedAgencyId,
      'assignedOfficerId': report.assignedOfficerId,
      'isAnonymous': report.isAnonymous,
      'upvotes': report.upvotes,
      'upvotedBy': report.upvotedBy,
      'comments': report.comments.map((c) => {
        'id': c.id,
        'authorId': c.authorId,
        'authorName': c.authorName,
        'content': c.content,
        'createdAt': c.createdAt.toIso8601String(),
        'isOfficial': c.isOfficial,
      }).toList(),
      'createdAt': report.createdAt.toIso8601String(),
      'assignedAt': report.assignedAt?.toIso8601String(),
      'resolvedAt': report.resolvedAt?.toIso8601String(),
      'updatedAt': report.updatedAt.toIso8601String(),
    };
  }

  CitizenReportModel _fromJson(Map<String, dynamic> json) {
    return CitizenReportModel(
      id: json['id'] as String,
      citizenId: json['citizenId'] as String,
      projectId: json['projectId'] as String?,
      type: ReportType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      priority: ReportPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      attachments: List<String>.from(json['attachments'] ?? []),
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      address: json['address'] as String?,
      assignedAgencyId: json['assignedAgencyId'] as String?,
      assignedOfficerId: json['assignedOfficerId'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      upvotes: json['upvotes'] as int? ?? 0,
      upvotedBy: List<String>.from(json['upvotedBy'] ?? []),
      comments: (json['comments'] as List<dynamic>?)
              ?.map((c) => ReportComment(
                    id: c['id'] as String,
                    authorId: c['authorId'] as String,
                    authorName: c['authorName'] as String,
                    content: c['content'] as String,
                    createdAt: DateTime.parse(c['createdAt'] as String),
                    isOfficial: c['isOfficial'] as bool? ?? false,
                  ))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'] as String)
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}