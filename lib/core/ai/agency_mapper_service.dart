import 'dart:math';
import '../../domain/entities/agency.dart';
import '../../domain/entities/project.dart';

/// AI-powered service for agency mapping, overlap detection, and role optimization
class AgencyMapperService {
  /// Builds a graph of agency relationships based on project assignments
  Map<String, Set<String>> buildAgencyGraph(
    List<Agency> agencies,
    List<Project> projects,
  ) {
    final graph = <String, Set<String>>{};

    // Initialize graph nodes
    for (final agency in agencies) {
      graph[agency.id] = {};
    }

    // Build connections based on project collaborations
    for (final project in projects) {
      final impId = project.implementingAgencyId;
      final execId = project.executingAgencyId;

      if (graph.containsKey(impId) && graph.containsKey(execId)) {
        graph[impId]!.add(execId);
        graph[execId]!.add(impId);
      }
    }

    return graph;
  }

  /// Detects overlapping responsibilities between agencies using NLP similarity
  List<AgencyOverlap> detectOverlappingResponsibilities(List<Agency> agencies) {
    final overlaps = <AgencyOverlap>[];

    for (int i = 0; i < agencies.length; i++) {
      for (int j = i + 1; j < agencies.length; j++) {
        final agency1 = agencies[i];
        final agency2 = agencies[j];

        final overlapScore = _calculateResponsibilityOverlap(
          agency1.responsibilities,
          agency2.responsibilities,
        );

        if (overlapScore > 0.4) {
          // 40% similarity threshold
          overlaps.add(
            AgencyOverlap(
              agency1Id: agency1.id,
              agency1Name: agency1.name,
              agency2Id: agency2.id,
              agency2Name: agency2.name,
              overlapScore: overlapScore,
              overlappingResponsibilities: _findOverlappingResponsibilities(
                agency1.responsibilities,
                agency2.responsibilities,
              ),
            ),
          );
        }
      }
    }

    return overlaps..sort((a, b) => b.overlapScore.compareTo(a.overlapScore));
  }

  /// Calculates coordination effectiveness score for an agency
  double calculateCoordinationScore(
    Agency agency,
    List<Project> projects,
    List<Agency> connectedAgencies,
  ) {
    if (projects.isEmpty) return 1.0;

    double score = 1.0;

    // Factor 1: Project completion rate (40% weight)
    final agencyProjects = projects.where((p) =>
        p.implementingAgencyId == agency.id ||
        p.executingAgencyId == agency.id);
    final completedProjects = agencyProjects
        .where((p) => p.status == ProjectStatus.completed)
        .length;
    final completionRate = agencyProjects.isEmpty
        ? 1.0
        : completedProjects / agencyProjects.length;
    score *= (0.4 * completionRate + 0.6);

    // Factor 2: Delay rate (30% weight)
    final delayedProjects =
        agencyProjects.where((p) => p.status == ProjectStatus.delayed).length;
    final delayRate =
        agencyProjects.isEmpty ? 0.0 : delayedProjects / agencyProjects.length;
    score *= (1.0 - 0.3 * delayRate);

    // Factor 3: Alert rate (20% weight)
    final totalAlerts =
        agencyProjects.fold(0, (sum, p) => sum + p.alerts.length);
    final avgAlertsPerProject =
        agencyProjects.isEmpty ? 0.0 : totalAlerts / agencyProjects.length;
    final alertPenalty = min(0.2, avgAlertsPerProject * 0.05);
    score *= (1.0 - alertPenalty);

    // Factor 4: Inter-agency coordination (10% weight)
    final expectedConnections = connectedAgencies.length;
    final actualConnections = agency.connectedAgencyIds.length;
    final coordinationRatio = expectedConnections == 0
        ? 1.0
        : actualConnections / expectedConnections;
    score *= (0.9 + 0.1 * coordinationRatio);

    return max(0.0, min(1.0, score));
  }

  /// Suggests optimal agency allocation for a new project using ML-based scoring
  AgencyAllocationSuggestion suggestOptimalAllocation(
    Project project,
    List<Agency> agencies,
    List<Project> existingProjects,
  ) {
    final scores = <String, double>{};

    for (final agency in agencies) {
      double score = 0.0;

      // Factor 1: Coordination score (40% weight)
      score += 0.4 * agency.coordinationScore;

      // Factor 2: Relevant experience (30% weight)
      final relevantProjects = existingProjects.where((p) =>
          (p.implementingAgencyId == agency.id ||
              p.executingAgencyId == agency.id) &&
          p.type == project.type);
      final experienceScore =
          min(1.0, relevantProjects.length / 5.0); // Saturates at 5 projects
      score += 0.3 * experienceScore;

      // Factor 3: Current workload (20% weight)
      final currentProjects = existingProjects.where((p) =>
          (p.implementingAgencyId == agency.id ||
              p.executingAgencyId == agency.id) &&
          p.status == ProjectStatus.inProgress);
      final workloadPenalty =
          min(0.2, currentProjects.length * 0.04); // Penalty increases with load
      score -= workloadPenalty;

      // Factor 4: Geographic proximity (10% weight)
      // Simplified: agencies with matching district/state get bonus
      final proximityBonus = _calculateProximityBonus(agency, project);
      score += 0.1 * proximityBonus;

      scores[agency.id] = max(0.0, min(1.0, score));
    }

    // Find top 3 suggestions
    final sortedAgencies = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topSuggestions = sortedAgencies.take(3).map((entry) {
      final agency = agencies.firstWhere((a) => a.id == entry.key);
      return AgencySuggestion(
        agencyId: agency.id,
        agencyName: agency.name,
        score: entry.value,
        reasons: _generateReasons(agency, project, existingProjects),
      );
    }).toList();

    return AgencyAllocationSuggestion(
      projectId: project.id,
      projectName: project.name,
      suggestions: topSuggestions,
      timestamp: DateTime.now(),
    );
  }

  /// Identifies coordination bottlenecks in the agency network
  List<CoordinationBottleneck> identifyBottlenecks(
    List<Agency> agencies,
    List<Project> projects,
    Map<String, Set<String>> agencyGraph,
  ) {
    final bottlenecks = <CoordinationBottleneck>[];

    // Detect agencies with poor coordination scores
    for (final agency in agencies) {
      if (agency.coordinationScore < 0.5) {
        final agencyProjects = projects.where((p) =>
            p.implementingAgencyId == agency.id ||
            p.executingAgencyId == agency.id);

        bottlenecks.add(
          CoordinationBottleneck(
            agencyId: agency.id,
            agencyName: agency.name,
            severity: BottleneckSeverity.fromScore(agency.coordinationScore),
            type: BottleneckType.lowCoordination,
            affectedProjectCount: agencyProjects.length,
            description:
                'Agency has low coordination score (${(agency.coordinationScore * 100).toStringAsFixed(1)}%)',
            recommendations: [
              'Review project allocation strategy',
              'Increase inter-agency communication',
              'Provide additional resources or training',
            ],
          ),
        );
      }
    }

    // Detect projects with multiple delays
    for (final project in projects) {
      if (project.status == ProjectStatus.delayed &&
          project.alerts.where((a) => !a.isResolved).length > 2) {
        bottlenecks.add(
          CoordinationBottleneck(
            agencyId: project.implementingAgencyId,
            agencyName: 'Project: ${project.name}',
            severity: BottleneckSeverity.high,
            type: BottleneckType.projectDelay,
            affectedProjectCount: 1,
            description: 'Project has multiple unresolved alerts and delays',
            recommendations: [
              'Escalate to senior management',
              'Reallocate resources',
              'Consider agency reassignment',
            ],
          ),
        );
      }
    }

    return bottlenecks..sort((a, b) => b.severity.index.compareTo(a.severity.index));
  }

  // Private helper methods

  double _calculateResponsibilityOverlap(
    List<String> resp1,
    List<String> resp2,
  ) {
    if (resp1.isEmpty || resp2.isEmpty) return 0.0;

    double totalSimilarity = 0.0;
    int comparisons = 0;

    for (final r1 in resp1) {
      for (final r2 in resp2) {
        totalSimilarity += _stringSimilarity(r1, r2);
        comparisons++;
      }
    }

    return comparisons > 0 ? totalSimilarity / comparisons : 0.0;
  }

  List<String> _findOverlappingResponsibilities(
    List<String> resp1,
    List<String> resp2,
  ) {
    final overlapping = <String>[];

    for (final r1 in resp1) {
      for (final r2 in resp2) {
        if (_stringSimilarity(r1, r2) > 0.6) {
          overlapping.add('$r1 ≈ $r2');
        }
      }
    }

    return overlapping;
  }

  /// Calculates string similarity using Jaro-Winkler algorithm
  double _stringSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final s1Lower = s1.toLowerCase();
    final s2Lower = s2.toLowerCase();

    // Calculate Levenshtein distance
    final len1 = s1Lower.length;
    final len2 = s2Lower.length;
    final matrix = List.generate(
      len1 + 1,
      (i) => List.filled(len2 + 1, 0),
    );

    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1Lower[i - 1] == s2Lower[j - 1] ? 0 : 1;
        matrix[i][j] = min(
          min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1),
          matrix[i - 1][j - 1] + cost,
        );
      }
    }

    final distance = matrix[len1][len2];
    final maxLen = max(len1, len2);
    return 1.0 - (distance / maxLen);
  }

  double _calculateProximityBonus(Agency agency, Project project) {
    // Simplified proximity calculation
    // In production, use actual geographic distance
    if (agency.contactInfo.address?.contains(project.location.district ?? '') ??
        false) {
      return 1.0;
    }
    if (agency.contactInfo.address?.contains(project.location.state ?? '') ??
        false) {
      return 0.5;
    }
    return 0.0;
  }

  List<String> _generateReasons(
    Agency agency,
    Project project,
    List<Project> existingProjects,
  ) {
    final reasons = <String>[];

    if (agency.coordinationScore > 0.8) {
      reasons.add(
          'Excellent coordination score (${(agency.coordinationScore * 100).toStringAsFixed(0)}%)');
    }

    final relevantExp = existingProjects.where((p) =>
        (p.implementingAgencyId == agency.id ||
            p.executingAgencyId == agency.id) &&
        p.type == project.type);
    if (relevantExp.isNotEmpty) {
      reasons.add(
          'Experience with ${relevantExp.length} similar ${project.type.name} projects');
    }

    final currentLoad = existingProjects.where((p) =>
        (p.implementingAgencyId == agency.id ||
            p.executingAgencyId == agency.id) &&
        p.status == ProjectStatus.inProgress);
    if (currentLoad.length < 5) {
      reasons.add('Manageable current workload (${currentLoad.length} active projects)');
    }

    return reasons;
  }
}

// Supporting classes

class AgencyOverlap {
  final String agency1Id;
  final String agency1Name;
  final String agency2Id;
  final String agency2Name;
  final double overlapScore;
  final List<String> overlappingResponsibilities;

  AgencyOverlap({
    required this.agency1Id,
    required this.agency1Name,
    required this.agency2Id,
    required this.agency2Name,
    required this.overlapScore,
    required this.overlappingResponsibilities,
  });
}

class AgencyAllocationSuggestion {
  final String projectId;
  final String projectName;
  final List<AgencySuggestion> suggestions;
  final DateTime timestamp;

  AgencyAllocationSuggestion({
    required this.projectId,
    required this.projectName,
    required this.suggestions,
    required this.timestamp,
  });
}

class AgencySuggestion {
  final String agencyId;
  final String agencyName;
  final double score;
  final List<String> reasons;

  AgencySuggestion({
    required this.agencyId,
    required this.agencyName,
    required this.score,
    required this.reasons,
  });
}

class CoordinationBottleneck {
  final String agencyId;
  final String agencyName;
  final BottleneckSeverity severity;
  final BottleneckType type;
  final int affectedProjectCount;
  final String description;
  final List<String> recommendations;

  CoordinationBottleneck({
    required this.agencyId,
    required this.agencyName,
    required this.severity,
    required this.type,
    required this.affectedProjectCount,
    required this.description,
    required this.recommendations,
  });
}

enum BottleneckSeverity {
  low,
  medium,
  high,
  critical;

  static BottleneckSeverity fromScore(double score) {
    if (score > 0.7) return BottleneckSeverity.low;
    if (score > 0.5) return BottleneckSeverity.medium;
    if (score > 0.3) return BottleneckSeverity.high;
    return BottleneckSeverity.critical;
  }
}

enum BottleneckType {
  lowCoordination,
  projectDelay,
  resourceShortage,
  communicationGap,
}