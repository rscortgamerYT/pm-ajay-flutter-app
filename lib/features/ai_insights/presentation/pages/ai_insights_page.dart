import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/demo_data_provider.dart';
import '../../../../core/ai/agency_mapper_service.dart' as agency;
import '../../../../core/ai/fund_predictor_service.dart' as fund;
import '../../../../domain/entities/fund.dart';

class AIInsightsPage extends StatefulWidget {
  const AIInsightsPage({super.key});

  @override
  State<AIInsightsPage> createState() => _AIInsightsPageState();
}

class _AIInsightsPageState extends State<AIInsightsPage> {
  final _agencyMapper = agency.AgencyMapperService();
  final _fundPredictor = fund.FundPredictorService();
  
  late List<dynamic> _agencyOverlaps;
  late List<dynamic> _fundPredictions;
  late List<dynamic> _bottlenecks;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAIInsights();
  }

  Future<void> _loadAIInsights() async {
    setState(() => _isLoading = true);
    
    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 1));
    
    final agencies = DemoDataProvider.getDemoAgencies();
    final projects = DemoDataProvider.getDemoProjects();
    final funds = DemoDataProvider.getDemoFunds();
    
    // Get real AI insights from our services
    final overlaps = _agencyMapper.detectOverlappingResponsibilities(agencies);
    final graph = _agencyMapper.buildAgencyGraph(agencies, projects);
    final bottlenecks = _agencyMapper.identifyBottlenecks(agencies, projects, graph);
    final fundBottlenecks = _fundPredictor.trackFundBottlenecks(funds, projects);
    
    setState(() {
      _agencyOverlaps = overlaps;
      _fundPredictions = funds.map((fund) {
        final prediction = _fundPredictor.predictFundDelay(
          fund,
          funds.where((f) => f.id != fund.id).toList(),
          fund.approvalChain,
        );
        return {
          'fund': fund,
          'prediction': prediction,
        };
      }).toList();
      _bottlenecks = [...bottlenecks, ...fundBottlenecks];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI-Powered Insights'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAIInsights,
            tooltip: 'Refresh Insights',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing data with AI...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAIInsights,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCard(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      '⚠️ Critical Bottlenecks',
                      Icons.warning_amber,
                      Colors.red,
                    ),
                    const SizedBox(height: 12),
                    ..._buildBottleneckCards(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      '🔄 Agency Coordination Analysis',
                      Icons.people_outline,
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    ..._buildAgencyOverlapCards(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      '💰 Fund Flow Predictions',
                      Icons.account_balance_wallet,
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    ..._buildFundPredictionCards(),
                    const SizedBox(height: 24),
                    _buildActionRecommendations(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewCard() {
    final criticalIssues = _bottlenecks.where((b) {
      if (b is agency.CoordinationBottleneck) {
        return b.severity == agency.BottleneckSeverity.critical ||
               b.severity == agency.BottleneckSeverity.high;
      }
      if (b is fund.FundBottleneck) {
        return b.severity == fund.BottleneckSeverity.critical ||
               b.severity == fund.BottleneckSeverity.high;
      }
      return false;
    }).length;

    final highRiskFunds = _fundPredictions.where((fp) {
      final pred = fp['prediction'] as fund.FundDelayPrediction;
      return pred.riskLevel == fund.RiskLevel.high;
    }).length;

    return Card(
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Autonomous AI Analysis',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Real-time insights powered by ML',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    '$criticalIssues',
                    'Critical Issues',
                    Colors.red,
                    Icons.error_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox(
                    '${_agencyOverlaps.length}',
                    'Agency Overlaps',
                    Colors.orange,
                    Icons.merge_type,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox(
                    '$highRiskFunds',
                    'High Risk Funds',
                    Colors.deepOrange,
                    Icons.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBottleneckCards() {
    if (_bottlenecks.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 40),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'No critical bottlenecks detected! All systems operating smoothly.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return _bottlenecks.map((bottleneck) {
      Color severityColor = Colors.grey;
      IconData severityIcon = Icons.info;
      String severityName = 'unknown';
      String description = '';
      List<String> recommendations = [];

      if (bottleneck is agency.CoordinationBottleneck) {
        severityName = bottleneck.severity.name;
        description = bottleneck.description;
        recommendations = bottleneck.recommendations;
        
        switch (bottleneck.severity) {
          case agency.BottleneckSeverity.critical:
            severityColor = Colors.red;
            severityIcon = Icons.error;
            break;
          case agency.BottleneckSeverity.high:
            severityColor = Colors.orange;
            severityIcon = Icons.warning;
            break;
          case agency.BottleneckSeverity.medium:
            severityColor = Colors.amber;
            severityIcon = Icons.info;
            break;
          case agency.BottleneckSeverity.low:
            severityColor = Colors.blue;
            severityIcon = Icons.info_outline;
            break;
        }
      } else if (bottleneck is fund.FundBottleneck) {
        severityName = bottleneck.severity.name;
        description = bottleneck.description;
        recommendations = bottleneck.recommendations;
        
        switch (bottleneck.severity) {
          case fund.BottleneckSeverity.critical:
            severityColor = Colors.red;
            severityIcon = Icons.error;
            break;
          case fund.BottleneckSeverity.high:
            severityColor = Colors.orange;
            severityIcon = Icons.warning;
            break;
          case fund.BottleneckSeverity.medium:
            severityColor = Colors.amber;
            severityIcon = Icons.info;
            break;
          case fund.BottleneckSeverity.low:
            severityColor = Colors.blue;
            severityIcon = Icons.info_outline;
            break;
        }
      } else {
        return const SizedBox.shrink();
      }

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(severityIcon, color: severityColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      severityName.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: severityColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(fontSize: 15),
              ),
              if (recommendations.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'AI Recommendations:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...recommendations.map((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(child: Text(rec, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildAgencyOverlapCards() {
    if (_agencyOverlaps.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.verified, color: Colors.green, size: 40),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'No significant overlaps detected. Agency responsibilities are well-defined.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return _agencyOverlaps.map((overlap) {
      final overlapScore = overlap.overlapScore;
      final color = overlapScore > 0.6
          ? Colors.red
          : overlapScore > 0.4
              ? Colors.orange
              : Colors.amber;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${overlap.agency1Name} ↔ ${overlap.agency2Name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      '${(overlapScore * 100).toStringAsFixed(0)}% Overlap',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Overlapping Responsibilities:',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...overlap.overlappingResponsibilities.map<Widget>((resp) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text(resp, style: const TextStyle(fontSize: 13))),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildFundPredictionCards() {
    return _fundPredictions.map((fp) {
      final fundEntity = fp['fund'] as Fund;
      final prediction = fp['prediction'] as fund.FundDelayPrediction;

      Color riskColor;
      switch (prediction.riskLevel) {
        case fund.RiskLevel.high:
          riskColor = Colors.red;
          break;
        case fund.RiskLevel.medium:
          riskColor = Colors.orange;
          break;
        case fund.RiskLevel.low:
          riskColor = Colors.green;
          break;
      }

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fundEntity.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₹${(fundEntity.amount / 10000000).toStringAsFixed(2)} Cr',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: riskColor),
                    ),
                    child: Text(
                      '${(prediction.delayProbability * 100).toStringAsFixed(0)}% Risk',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (prediction.estimatedDelayDays > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Predicted delay: ${prediction.estimatedDelayDays} days',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
              if (prediction.factors.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Risk Factors:',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                const SizedBox(height: 8),
                ...prediction.factors.map((factor) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber, size: 14, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(child: Text(factor, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildActionRecommendations() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lightbulb, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Top Priority Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActionItem(
              '1. Address coordination gap in Varanasi District',
              'Schedule coordination meeting within 48 hours',
              Icons.people,
            ),
            _buildActionItem(
              '2. Expedite Emergency Relief Fund approval',
              'Follow up with Finance Secretary for faster approval',
              Icons.account_balance_wallet,
            ),
            _buildActionItem(
              '3. Review budget overrun in Sarnath project',
              'Request supplementary allocation to prevent further delays',
              Icons.warning,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/reports'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                icon: const Icon(Icons.assessment),
                label: const Text('Generate Full Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Icon(icon, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}