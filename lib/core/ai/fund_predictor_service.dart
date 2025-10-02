import 'dart:math';
import '../../domain/entities/fund.dart';
import '../../domain/entities/project.dart';

/// AI-powered service for predictive fund flow and resource management
class FundPredictorService {
  /// Predicts fund release delays using historical data and pattern recognition
  FundDelayPrediction predictFundDelay(
    Fund fund,
    List<Fund> historicalFunds,
    List<String> approvalChain,
  ) {
    double delayProbability = 0.0;
    int estimatedDelayDays = 0;
    final factors = <String>[];

    // Factor 1: Historical delay rate (40% weight)
    final historicalDelays = historicalFunds.where((f) => f.isDelayed).length;
    final historicalDelayRate = historicalFunds.isEmpty 
        ? 0.0 
        : historicalDelays / historicalFunds.length;
    delayProbability += 0.4 * historicalDelayRate;
    if (historicalDelayRate > 0.3) {
      factors.add('Historical delay rate is ${(historicalDelayRate * 100).toStringAsFixed(0)}%');
    }

    // Factor 2: Approval chain complexity (30% weight)
    final chainComplexity = approvalChain.length / 10.0; // Normalize to 0-1
    delayProbability += 0.3 * min(1.0, chainComplexity);
    if (approvalChain.length > 5) {
      factors.add('Long approval chain (${approvalChain.length} steps)');
    }

    // Factor 3: Fund amount (20% weight)
    final avgAmount = historicalFunds.isEmpty
        ? fund.amount
        : historicalFunds.fold(0.0, (sum, f) => sum + f.amount) / historicalFunds.length;
    if (fund.amount > avgAmount * 1.5) {
      delayProbability += 0.2;
      factors.add('Fund amount is ${((fund.amount / avgAmount - 1) * 100).toStringAsFixed(0)}% above average');
    }

    // Factor 4: Current workload (10% weight)
    final pendingFunds = historicalFunds.where(
      (f) => f.status == FundStatus.pending || f.status == FundStatus.approved
    ).length;
    if (pendingFunds > 5) {
      delayProbability += 0.1;
      factors.add('High pending fund count ($pendingFunds funds)');
    }

    // Calculate estimated delay in days
    if (delayProbability > 0.7) {
      estimatedDelayDays = (15 + Random().nextInt(16)).toInt(); // 15-30 days
    } else if (delayProbability > 0.5) {
      estimatedDelayDays = (7 + Random().nextInt(8)).toInt(); // 7-14 days
    } else if (delayProbability > 0.3) {
      estimatedDelayDays = (3 + Random().nextInt(5)).toInt(); // 3-7 days
    }

    final predictedReleaseDate = fund.releaseDate.add(Duration(days: estimatedDelayDays));

    return FundDelayPrediction(
      fundId: fund.id,
      fundName: fund.name,
      delayProbability: min(1.0, delayProbability),
      estimatedDelayDays: estimatedDelayDays,
      predictedReleaseDate: predictedReleaseDate,
      riskLevel: _calculateRiskLevel(delayProbability),
      factors: factors,
      recommendations: _generateDelayRecommendations(delayProbability, factors),
    );
  }

  /// Suggests alternative fund allocation strategies
  List<AlternativeFundingStrategy> suggestAlternativeFunding(
    Project project,
    List<Fund> availableFunds,
    double requiredAmount,
  ) {
    final strategies = <AlternativeFundingStrategy>[];

    // Strategy 1: Single fund allocation
    final suitableFunds = availableFunds.where(
      (f) => f.remainingAmount >= requiredAmount && f.status == FundStatus.approved
    ).toList()..sort((a, b) => a.remainingAmount.compareTo(b.remainingAmount));

    if (suitableFunds.isNotEmpty) {
      final fund = suitableFunds.first;
      strategies.add(
        AlternativeFundingStrategy(
          name: 'Single Fund Allocation',
          description: 'Allocate from one available fund',
          funds: [fund.id],
          totalAmount: requiredAmount,
          feasibilityScore: 0.9,
          estimatedTimeDays: 5,
          pros: [
            'Simple approval process',
            'Quick disbursement',
            'Single point of tracking',
          ],
          cons: [
            'May exhaust fund quickly',
            'No risk diversification',
          ],
        ),
      );
    }

    // Strategy 2: Multi-fund allocation
    final partialFunds = availableFunds.where(
      (f) => f.remainingAmount > 0 && f.status == FundStatus.approved
    ).toList()..sort((a, b) => b.remainingAmount.compareTo(a.remainingAmount));

    if (partialFunds.length >= 2) {
      double accumulated = 0.0;
      final selectedFunds = <String>[];
      
      for (final fund in partialFunds) {
        if (accumulated >= requiredAmount) break;
        selectedFunds.add(fund.id);
        accumulated += fund.remainingAmount;
      }

      if (accumulated >= requiredAmount) {
        strategies.add(
          AlternativeFundingStrategy(
            name: 'Multi-Fund Allocation',
            description: 'Combine multiple funds to meet requirement',
            funds: selectedFunds,
            totalAmount: requiredAmount,
            feasibilityScore: 0.7,
            estimatedTimeDays: 10,
            pros: [
              'Utilizes available resources',
              'Risk diversification',
              'Better fund utilization',
            ],
            cons: [
              'Complex approval process',
              'Multiple tracking points',
              'Coordination overhead',
            ],
          ),
        );
      }
    }

    // Strategy 3: Phased allocation
    strategies.add(
      AlternativeFundingStrategy(
        name: 'Phased Allocation',
        description: 'Release funds in project milestones',
        funds: availableFunds.take(2).map((f) => f.id).toList(),
        totalAmount: requiredAmount,
        feasibilityScore: 0.8,
        estimatedTimeDays: 7,
        pros: [
          'Better cash flow management',
          'Milestone-based release',
          'Risk mitigation',
          'Performance-based funding',
        ],
        cons: [
          'Requires milestone tracking',
          'May delay some activities',
          'More administrative overhead',
        ],
      ),
    );

    return strategies..sort((a, b) => b.feasibilityScore.compareTo(a.feasibilityScore));
  }

  /// Forecasts future fund requirements using trend analysis
  FundRequirementForecast forecastFundRequirements(
    List<Project> projects,
    List<Fund> historicalFunds,
    int forecastMonths,
  ) {
    final monthlyRequirements = <DateTime, double>{};
    final now = DateTime.now();

    // Analyze historical spending patterns
    final avgMonthlySpending = _calculateAverageMonthlySpending(historicalFunds);

    // Project future requirements based on planned projects
    for (int month = 1; month <= forecastMonths; month++) {
      final targetDate = DateTime(now.year, now.month + month, 1);
      double requirement = 0.0;

      // Add requirements from planned projects
      for (final project in projects) {
        if (project.startDate.isBefore(targetDate) &&
            project.expectedEndDate.isAfter(targetDate)) {
          // Estimate monthly project cost
          final projectDuration = project.expectedEndDate.difference(project.startDate).inDays;
          final monthlyProjectCost = project.allocatedFundId != null
              ? (historicalFunds.firstWhere(
                    (f) => f.id == project.allocatedFundId,
                    orElse: () => historicalFunds.first,
                  ).amount / (projectDuration / 30))
              : avgMonthlySpending;
          
          requirement += monthlyProjectCost;
        }
      }

      monthlyRequirements[targetDate] = requirement;
    }

    // Calculate total forecast
    final totalForecast = monthlyRequirements.values.fold(0.0, (sum, val) => sum + val);
    final peakMonth = monthlyRequirements.entries.reduce(
      (a, b) => a.value > b.value ? a : b
    );

    return FundRequirementForecast(
      forecastPeriodMonths: forecastMonths,
      monthlyRequirements: monthlyRequirements,
      totalForecast: totalForecast,
      peakRequirementMonth: peakMonth.key,
      peakRequirementAmount: peakMonth.value,
      averageMonthlyRequirement: totalForecast / forecastMonths,
      confidence: _calculateForecastConfidence(historicalFunds.length),
      recommendations: _generateForecastRecommendations(
        totalForecast,
        peakMonth.value,
        avgMonthlySpending,
      ),
    );
  }

  /// Tracks fund allocation and identifies bottlenecks
  List<FundBottleneck> trackFundBottlenecks(
    List<Fund> funds,
    List<Project> projects,
  ) {
    final bottlenecks = <FundBottleneck>[];

    // Check for stuck approvals
    for (final fund in funds) {
      if (fund.status == FundStatus.pending) {
        final daysPending = DateTime.now().difference(fund.createdAt).inDays;
        if (daysPending > 30) {
          bottlenecks.add(
            FundBottleneck(
              fundId: fund.id,
              fundName: fund.name,
              type: FundBottleneckType.approvalDelay,
              severity: daysPending > 60 ? BottleneckSeverity.critical : BottleneckSeverity.high,
              description: 'Fund pending approval for $daysPending days',
              affectedProjects: _getAffectedProjects(fund.id, projects),
              recommendations: [
                'Escalate to approval authority',
                'Review approval chain',
                'Consider alternative funding',
              ],
            ),
          );
        }
      }
    }

    // Check for insufficient funds
    final totalAvailable = funds
        .where((f) => f.status == FundStatus.approved)
        .fold(0.0, (sum, f) => sum + f.remainingAmount);
    
    final totalRequired = projects
        .where((p) => p.status == ProjectStatus.approved && p.allocatedFundId == null)
        .fold(0.0, (sum, p) => sum + (p.metadata['estimatedCost'] as double? ?? 0.0));

    if (totalRequired > totalAvailable) {
      bottlenecks.add(
        FundBottleneck(
          fundId: 'GLOBAL',
          fundName: 'System-wide',
          type: FundBottleneckType.insufficientFunds,
          severity: BottleneckSeverity.critical,
          description: 'Insufficient funds: Required ₹${(totalRequired / 10000000).toStringAsFixed(2)}Cr, Available ₹${(totalAvailable / 10000000).toStringAsFixed(2)}Cr',
          affectedProjects: projects.where((p) => p.allocatedFundId == null).map((p) => p.id).toList(),
          recommendations: [
            'Request additional budget',
            'Prioritize critical projects',
            'Review project costs',
          ],
        ),
      );
    }

    return bottlenecks..sort((a, b) => b.severity.index.compareTo(a.severity.index));
  }

  // Private helper methods

  double _calculateAverageMonthlySpending(List<Fund> historicalFunds) {
    if (historicalFunds.isEmpty) return 1000000; // Default 10 Lakh

    final totalSpent = historicalFunds.fold(0.0, (sum, f) => sum + f.allocatedAmount);
    final oldestFund = historicalFunds.reduce(
      (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b
    );
    final monthsSinceStart = DateTime.now().difference(oldestFund.createdAt).inDays / 30;

    return monthsSinceStart > 0 ? totalSpent / monthsSinceStart : totalSpent;
  }

  RiskLevel _calculateRiskLevel(double probability) {
    if (probability > 0.7) return RiskLevel.high;
    if (probability > 0.4) return RiskLevel.medium;
    return RiskLevel.low;
  }

  List<String> _generateDelayRecommendations(double probability, List<String> factors) {
    final recommendations = <String>[];

    if (probability > 0.7) {
      recommendations.add('Consider expedited approval process');
      recommendations.add('Prepare alternative funding sources');
    }
    if (probability > 0.5) {
      recommendations.add('Monitor approval chain closely');
      recommendations.add('Establish contingency timeline');
    }
    if (factors.any((f) => f.contains('approval chain'))) {
      recommendations.add('Streamline approval process where possible');
    }

    return recommendations;
  }

  double _calculateForecastConfidence(int historicalDataPoints) {
    // Confidence increases with more historical data
    if (historicalDataPoints > 100) return 0.9;
    if (historicalDataPoints > 50) return 0.8;
    if (historicalDataPoints > 20) return 0.7;
    if (historicalDataPoints > 10) return 0.6;
    return 0.5;
  }

  List<String> _generateForecastRecommendations(
    double totalForecast,
    double peakRequirement,
    double avgMonthly,
  ) {
    final recommendations = <String>[];

    if (peakRequirement > avgMonthly * 2) {
      recommendations.add('Plan for peak month funding (${(peakRequirement / 10000000).toStringAsFixed(2)}Cr)');
    }
    if (totalForecast > avgMonthly * 12) {
      recommendations.add('Request annual budget increase');
    }
    recommendations.add('Establish reserve fund for contingencies');
    recommendations.add('Review and optimize project timelines');

    return recommendations;
  }

  List<String> _getAffectedProjects(String fundId, List<Project> projects) {
    return projects
        .where((p) => p.allocatedFundId == fundId)
        .map((p) => p.id)
        .toList();
  }
}

// Supporting classes

class FundDelayPrediction {
  final String fundId;
  final String fundName;
  final double delayProbability;
  final int estimatedDelayDays;
  final DateTime predictedReleaseDate;
  final RiskLevel riskLevel;
  final List<String> factors;
  final List<String> recommendations;

  FundDelayPrediction({
    required this.fundId,
    required this.fundName,
    required this.delayProbability,
    required this.estimatedDelayDays,
    required this.predictedReleaseDate,
    required this.riskLevel,
    required this.factors,
    required this.recommendations,
  });
}

class AlternativeFundingStrategy {
  final String name;
  final String description;
  final List<String> funds;
  final double totalAmount;
  final double feasibilityScore;
  final int estimatedTimeDays;
  final List<String> pros;
  final List<String> cons;

  AlternativeFundingStrategy({
    required this.name,
    required this.description,
    required this.funds,
    required this.totalAmount,
    required this.feasibilityScore,
    required this.estimatedTimeDays,
    required this.pros,
    required this.cons,
  });
}

class FundRequirementForecast {
  final int forecastPeriodMonths;
  final Map<DateTime, double> monthlyRequirements;
  final double totalForecast;
  final DateTime peakRequirementMonth;
  final double peakRequirementAmount;
  final double averageMonthlyRequirement;
  final double confidence;
  final List<String> recommendations;

  FundRequirementForecast({
    required this.forecastPeriodMonths,
    required this.monthlyRequirements,
    required this.totalForecast,
    required this.peakRequirementMonth,
    required this.peakRequirementAmount,
    required this.averageMonthlyRequirement,
    required this.confidence,
    required this.recommendations,
  });
}

class FundBottleneck {
  final String fundId;
  final String fundName;
  final FundBottleneckType type;
  final BottleneckSeverity severity;
  final String description;
  final List<String> affectedProjects;
  final List<String> recommendations;

  FundBottleneck({
    required this.fundId,
    required this.fundName,
    required this.type,
    required this.severity,
    required this.description,
    required this.affectedProjects,
    required this.recommendations,
  });
}

enum RiskLevel {
  low,
  medium,
  high,
}

enum FundBottleneckType {
  approvalDelay,
  insufficientFunds,
  allocationMismatch,
}

enum BottleneckSeverity {
  low,
  medium,
  high,
  critical,
}