import '../repositories/project_repository.dart';
import '../repositories/agency_repository.dart';
import '../repositories/fund_repository.dart';
import '../repositories/citizen_report_repository.dart';
import '../../features/reports/models/report_model.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/fund.dart';

/// Service for generating analytical reports and metrics
class ReportingService {
  final ProjectRepository _projectRepo;
  final AgencyRepository _agencyRepo;
  final FundRepository _fundRepo;
  final CitizenReportRepository _citizenReportRepo;

  ReportingService({
    required ProjectRepository projectRepo,
    required AgencyRepository agencyRepo,
    required FundRepository fundRepo,
    required CitizenReportRepository citizenReportRepo,
  })  : _projectRepo = projectRepo,
        _agencyRepo = agencyRepo,
        _fundRepo = fundRepo,
        _citizenReportRepo = citizenReportRepo;

  /// Generate comprehensive dashboard metrics
  Future<DashboardMetrics> generateDashboardMetrics() async {
    // Fetch all required data
    final projects = await _projectRepo.getProjects();
    final agencies = await _agencyRepo.getAgencies();
    final funds = await _fundRepo.getFunds();
    final reportStats = await _citizenReportRepo.getReportStatistics();

    // Calculate project statistics
    final totalProjects = projects.length;
    final activeProjects = projects.where((p) => 
        p.status == ProjectStatus.inProgress ||
        p.status == ProjectStatus.planning).length;
    final completedProjects = projects.where((p) => 
        p.status == ProjectStatus.completed).length;
    
    // Calculate delayed projects (past expected end date with < 100% completion)
    final now = DateTime.now();
    final delayedProjects = projects.where((p) =>
        p.expectedEndDate.isBefore(now) &&
        p.completionPercentage < 100 &&
        p.status != ProjectStatus.completed).length;

    // Calculate budget statistics from funds
    final totalBudget = funds.fold<double>(
        0, (sum, f) => sum + f.amount);
    final utilizedBudget = funds.fold<double>(
        0, (sum, f) => sum + f.allocatedAmount);
    final budgetUtilizationPercentage = totalBudget > 0
        ? (utilizedBudget / totalBudget) * 100
        : 0;

    // Calculate average project completion
    final averageProjectCompletion = projects.isEmpty
        ? 0.0
        : projects.fold<double>(0, (sum, p) => sum + p.completionPercentage) /
            projects.length;

    // Group projects by status
    final projectsByStatus = <String, int>{};
    for (final status in ProjectStatus.values) {
      projectsByStatus[status.name] =
          projects.where((p) => p.status == status).length;
    }

    // Calculate budget by agency from allocated funds
    final budgetByAgency = <String, double>{};
    for (final agency in agencies) {
      final agencyProjects = projects.where((p) =>
          p.implementingAgencyId == agency.id ||
          p.executingAgencyId == agency.id);
      
      double totalAgencyBudget = 0;
      for (final project in agencyProjects) {
        if (project.allocatedFundId != null) {
          try {
            final fund = await _fundRepo.getFundById(project.allocatedFundId!);
            final allocation = fund.allocations.firstWhere(
              (a) => a.projectId == project.id,
              orElse: () => FundAllocation(
                id: '',
                projectId: '',
                amount: 0,
                allocationDate: DateTime.now(),
                status: FundAllocationStatus.pending,
              ),
            );
            if (allocation.id.isNotEmpty) {
            totalAgencyBudget += allocation.amount;
          }
        } catch (e) {
            // Skip if fund not found
          }
        }
      }
      budgetByAgency[agency.name] = totalAgencyBudget;
    }

    // Generate recent trends (placeholder - would need historical data)
    final recentTrends = <ProjectTrend>[];

    return DashboardMetrics(
      totalProjects: totalProjects,
      activeProjects: activeProjects,
      completedProjects: completedProjects,
      delayedProjects: delayedProjects,
      totalBudget: totalBudget,
      utilizedBudget: utilizedBudget,
      budgetUtilizationPercentage: budgetUtilizationPercentage.toDouble(),
      totalAgencies: agencies.length,
      totalCitizens: 0, // Would need citizen repository
      totalReports: reportStats.totalReports,
      averageProjectCompletion: averageProjectCompletion,
      projectsByStatus: projectsByStatus,
      budgetByAgency: budgetByAgency,
      recentTrends: recentTrends,
    );
  }

  /// Generate project performance report
  Future<Map<String, dynamic>> generateProjectPerformanceReport({
    String? projectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final projects = projectId != null
        ? [await _projectRepo.getProjectById(projectId)].whereType<Project>().toList()
        : await _projectRepo.getProjects();

    // Filter by date range if provided
    final filteredProjects = projects.where((p) {
      if (startDate != null && p.startDate.isBefore(startDate)) return false;
      if (endDate != null && p.startDate.isAfter(endDate)) return false;
      return true;
    }).toList();

    // Calculate performance metrics
    final onTimeProjects = filteredProjects.where((p) {
      if (p.status != ProjectStatus.completed) return false;
      return p.actualEndDate?.isBefore(p.expectedEndDate) ?? false;
    }).length;

    final delayedProjects = filteredProjects.where((p) {
      final now = DateTime.now();
      return p.expectedEndDate.isBefore(now) &&
          p.completionPercentage < 100 &&
          p.status != ProjectStatus.completed;
    }).length;

    final averageCompletion = filteredProjects.isEmpty
        ? 0.0
        : filteredProjects.fold<double>(0, (sum, p) => sum + p.completionPercentage) /
            filteredProjects.length;

    // Calculate budget overruns from fund allocations
    int budgetOverruns = 0;
    final projectDetails = <Map<String, dynamic>>[];
    
    for (final p in filteredProjects) {
      double budgetUtilization = 0;
      
      if (p.allocatedFundId != null) {
        try {
          final fund = await _fundRepo.getFundById(p.allocatedFundId!);
          final allocation = fund.allocations.firstWhere(
            (a) => a.projectId == p.id,
            orElse: () => FundAllocation(
              id: '',
              projectId: '',
              amount: 0,
              allocationDate: DateTime.now(),
              status: FundAllocationStatus.pending,
            ),
          );
          if (allocation.id.isNotEmpty) {
            final actualSpent = p.metadata['actualSpent'] as double? ?? 0;
            if (allocation.amount > 0) {
              budgetUtilization = (actualSpent / allocation.amount) * 100;
              if (actualSpent > allocation.amount) {
                budgetOverruns++;
              }
            }
          }
        } catch (e) {
          // Skip if fund not found
        }
      }
      
      projectDetails.add({
        'id': p.id,
        'name': p.name,
        'status': p.status.name,
        'completion': p.completionPercentage,
        'budgetUtilization': budgetUtilization,
        'daysOverdue': p.expectedEndDate.isBefore(DateTime.now())
            ? DateTime.now().difference(p.expectedEndDate).inDays
            : 0,
      });
    }

    return {
      'totalProjects': filteredProjects.length,
      'onTimeProjects': onTimeProjects,
      'delayedProjects': delayedProjects,
      'averageCompletion': averageCompletion,
      'budgetOverruns': budgetOverruns,
      'projectDetails': projectDetails,
    };
  }

  /// Generate fund utilization report
  Future<Map<String, dynamic>> generateFundUtilizationReport({
    String? fundId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final funds = fundId != null
        ? [await _fundRepo.getFundById(fundId)].whereType().toList()
        : await _fundRepo.getFunds();

    final totalAllocated = funds.fold<double>(
        0, (sum, f) => sum + f.allocatedAmount);
    final totalUtilized = funds.fold<double>(
        0, (sum, f) => sum + f.utilizedAmount);
    final totalAvailable = funds.fold<double>(
        0, (sum, f) => sum + f.availableAmount);

    final utilizationRate = totalAllocated > 0
        ? (totalUtilized / totalAllocated) * 100
        : 0;

    return {
      'totalAllocated': totalAllocated,
      'totalUtilized': totalUtilized,
      'totalAvailable': totalAvailable,
      'utilizationRate': utilizationRate,
      'fundDetails': funds.map((f) => {
        'id': f.id,
        'name': f.name,
        'allocated': f.allocatedAmount,
        'utilized': f.utilizedAmount,
        'available': f.availableAmount,
        'utilizationRate': f.allocatedAmount > 0
            ? (f.utilizedAmount / f.allocatedAmount) * 100
            : 0,
      }).toList(),
    };
  }

  /// Generate agency coordination report
  Future<Map<String, dynamic>> generateAgencyCoordinationReport() async {
    final agencies = await _agencyRepo.getAgencies();
    final projects = await _projectRepo.getProjects();

    final agencyReports = agencies.map((agency) {
      final implementingProjects = projects.where((p) =>
          p.implementingAgencyId == agency.id).length;
      final executingProjects = projects.where((p) =>
          p.executingAgencyId == agency.id).length;

      return {
        'id': agency.id,
        'name': agency.name,
        'type': agency.type.name,
        'coordinationScore': agency.coordinationScore,
        'implementingProjects': implementingProjects,
        'executingProjects': executingProjects,
        'totalProjects': implementingProjects + executingProjects,
      };
    }).toList();

    // Sort by coordination score
    agencyReports.sort((a, b) => 
        (b['coordinationScore'] as double).compareTo(a['coordinationScore'] as double));

    final averageCoordinationScore = agencies.isEmpty
        ? 0.0
        : agencies.fold<double>(0, (sum, a) => sum + a.coordinationScore) /
            agencies.length;

    return {
      'totalAgencies': agencies.length,
      'averageCoordinationScore': averageCoordinationScore,
      'topPerformers': agencyReports.take(5).toList(),
      'needsImprovement': agencyReports.reversed.take(5).toList(),
      'agencyDetails': agencyReports,
    };
  }

  /// Generate citizen engagement report
  Future<Map<String, dynamic>> generateCitizenEngagementReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final stats = await _citizenReportRepo.getReportStatistics();

    return {
      'totalReports': stats.totalReports,
      'pendingReports': stats.pendingReports,
      'resolvedReports': stats.resolvedReports,
      'averageResolutionTime': stats.averageResolutionTimeHours,
      'reportsByType': stats.reportsByType.map((k, v) => MapEntry(k.name, v)),
      'reportsByPriority': stats.reportsByPriority.map((k, v) => MapEntry(k.name, v)),
      'mostUpvotedReports': stats.mostUpvotedReports.map((r) => {
        'id': r.id,
        'title': r.title,
        'upvotes': r.upvotes,
        'status': r.status.toString(),
      }).toList(),
    };
  }

  /// Generate chart data for project completion over time
  Future<List<ChartData>> generateProjectCompletionChartData() async {
    final projects = await _projectRepo.getProjects();

    // Group by month
    final monthlyData = <String, List<double>>{};
    
    for (final project in projects) {
      final monthKey = '${project.startDate.year}-${project.startDate.month.toString().padLeft(2, '0')}';
      monthlyData.putIfAbsent(monthKey, () => []);
      monthlyData[monthKey]!.add(project.completionPercentage);
    }

    // Convert to chart data
    return monthlyData.entries.map((entry) {
      final average = entry.value.isEmpty
          ? 0.0
          : entry.value.reduce((a, b) => a + b) / entry.value.length;
      
      return ChartData(
        label: entry.key,
        value: average,
        category: 'Average Completion',
      );
    }).toList()..sort((a, b) => a.label.compareTo(b.label));
  }

  /// Generate chart data for budget utilization
  Future<List<ChartData>> generateBudgetUtilizationChartData() async {
    final agencies = await _agencyRepo.getAgencies();
    final projects = await _projectRepo.getProjects();

    final List<ChartData> chartData = [];
    
    for (final agency in agencies) {
      final agencyProjects = projects.where((p) =>
          p.implementingAgencyId == agency.id ||
          p.executingAgencyId == agency.id);
      
      double totalAllocated = 0;
      double totalUtilized = 0;
      
      for (final project in agencyProjects) {
        if (project.allocatedFundId != null) {
          try {
            final fund = await _fundRepo.getFundById(project.allocatedFundId!);
            final allocation = fund.allocations.firstWhere(
              (a) => a.projectId == project.id,
              orElse: () => FundAllocation(
                id: '',
                projectId: project.id,
                amount: 0,
                allocationDate: DateTime.now(),
                status: FundAllocationStatus.pending,
              ),
            );
            totalAllocated += allocation.amount;
            final actualSpent = project.metadata['actualSpent'] as double? ?? 0;
            totalUtilized += actualSpent;
                    } catch (e) {
            // Skip if fund not found
          }
        }
      }

      chartData.add(ChartData(
        label: agency.name,
        value: totalUtilized,
        category: 'Budget Utilization',
      ));
    }
    
    return chartData..sort((a, b) => b.value.compareTo(a.value));
  }
}