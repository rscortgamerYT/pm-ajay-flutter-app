import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/village_model.dart';
import '../../providers/village_providers.dart';

class VillageDetailPage extends ConsumerWidget {
  final String villageId;

  const VillageDetailPage({
    super.key,
    required this.villageId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final villageAsync = ref.watch(villageProvider(villageId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Village Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit village page
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showMoreOptions(context, ref);
            },
          ),
        ],
      ),
      body: villageAsync.when(
        data: (village) {
          if (village == null) {
            return const Center(
              child: Text('Village not found'),
            );
          }
          return _buildVillageDetails(context, ref, village);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(villageProvider(villageId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVillageDetails(BuildContext context, WidgetRef ref, VillageModel village) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildHeaderCard(context, village),

          // Eligibility Status Card
          _buildEligibilityCard(context, village),

          // Demographics Section
          _buildSectionTitle(context, 'Demographics'),
          _buildDemographicsCards(context, village),

          // Priority Scoring Section (if available)
          if (village.priorityScore != null && village.priorityScore! > 0) ...[
            _buildSectionTitle(context, 'Priority Scoring'),
            _buildPriorityScoreCard(context, village),
          ],

          // Infrastructure Gaps Section
          if (village.infrastructureGaps != null && village.infrastructureGaps!.isNotEmpty) ...[
            _buildSectionTitle(context, 'Infrastructure Gaps'),
            _buildInfrastructureGapsCard(context, village),
          ],

          // Convergent Schemes Section
          if (village.convergentSchemes != null && village.convergentSchemes!.isNotEmpty) ...[
            _buildSectionTitle(context, 'Convergent Schemes'),
            _buildConvergentSchemesCard(context, village),
          ],

          // Socio-Economic Indicators Section
          if (village.socioEconomicIndicators != null && village.socioEconomicIndicators!.isNotEmpty) ...[
            _buildSectionTitle(context, 'Socio-Economic Indicators'),
            _buildSocioEconomicCard(context, village),
          ],

          // Additional Information
          _buildSectionTitle(context, 'Additional Information'),
          _buildAdditionalInfoCard(context, village),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, VillageModel village) {
    final statusColor = _getStatusColor(village.eligibilityStatus);
    final statusIcon = _getStatusIcon(village.eligibilityStatus);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_city,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        village.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${village.district}, ${village.state}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PIN: ${village.pincode}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusLabel(village.eligibilityStatus),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEligibilityCard(BuildContext context, VillageModel village) {
    final isEligible = village.scPopulationPercentage >= 50.0;
    final eligibilityColor = isEligible ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isEligible ? Icons.check_circle : Icons.cancel,
                  color: eligibilityColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'PM-AJAY Eligibility',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: eligibilityColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: eligibilityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: eligibilityColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SC Population: ${village.scPopulationPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: eligibilityColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEligible
                        ? 'Meets the ≥50% SC population requirement for Adarsh Gram'
                        : 'Does not meet the ≥50% SC population requirement',
                    style: TextStyle(
                      fontSize: 12,
                      color: eligibilityColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemographicsCards(BuildContext context, VillageModel village) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.3,
        children: [
          _buildStatCard(
            context,
            'Total Population',
            village.totalPopulation.toString(),
            Icons.groups,
            Colors.blue,
          ),
          _buildStatCard(
            context,
            'SC Population',
            village.scPopulation.toString(),
            Icons.people,
            Colors.green,
          ),
          _buildStatCard(
            context,
            'Total Households',
            village.totalHouseholds.toString(),
            Icons.home,
            Colors.orange,
          ),
          _buildStatCard(
            context,
            'SC Households',
            village.scHouseholds.toString(),
            Icons.house,
            Colors.purple,
          ),
          _buildStatCard(
            context,
            'BPL Households',
            village.bplHouseholds.toString(),
            Icons.home_work,
            Colors.red,
          ),
          _buildStatCard(
            context,
            'Literacy Rate',
            '${village.literacyRate.toStringAsFixed(1)}%',
            Icons.school,
            Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityScoreCard(BuildContext context, VillageModel village) {
    final score = village.priorityScore!;
    final scoreColor = _getPriorityScoreColor(score);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Overall Priority Score',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scoreColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    score.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildScoreBar(score, scoreColor),
            const SizedBox(height: 8),
            Text(
              _getPriorityScoreDescription(score),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(double score, Color color) {
    final percentage = (score / 5.0).clamp(0.0, 1.0);
    
    return Column(
      children: [
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[300],
          color: color,
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text('5', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _buildInfrastructureGapsCard(BuildContext context, VillageModel village) {
    final gaps = village.infrastructureGaps!.entries.toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Infrastructure Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...gaps.map((gap) => _buildInfrastructureItem(
                  _getInfrastructureLabel(gap.key),
                  gap.value,
                  _getInfrastructureIcon(gap.key),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfrastructureItem(String label, bool hasGap, IconData icon) {
    final color = hasGap ? Colors.red : Colors.green;
    final statusText = hasGap ? 'Needs Development' : 'Available';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConvergentSchemesCard(BuildContext context, VillageModel village) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Eligible Schemes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...village.convergentSchemes!.map((scheme) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          scheme,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSocioEconomicCard(BuildContext context, VillageModel village) {
    final indicators = village.socioEconomicIndicators!.entries.toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Indicators',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...indicators.map((indicator) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getSocioEconomicLabel(indicator.key),
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        indicator.value.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard(BuildContext context, VillageModel village) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Village ID', village.id),
            if (village.censusCode != null) _buildInfoRow('Census Code', village.censusCode!),
            if (village.seccCode != null) _buildInfoRow('SECC Code', village.seccCode!),
            _buildInfoRow('Last Updated', _formatDate(village.lastUpdated)),
            if (village.selectedDate != null) _buildInfoRow('Selected On', _formatDate(village.selectedDate!)),
            if (village.selectedBy != null) _buildInfoRow('Selected By', village.selectedBy!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Update Priority Score'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to priority scoring page
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Mark as Selected'),
              onTap: () {
                Navigator.pop(context);
                ref.read(villagesProvider.notifier).selectVillage(villageId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('View Analytics'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to analytics page
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Village'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Village'),
        content: const Text('Are you sure you want to delete this village? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(villagesProvider.notifier).deleteVillage(villageId);
              Navigator.pop(context);
              context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(VillageEligibilityStatus status) {
    switch (status) {
      case VillageEligibilityStatus.eligible:
        return Colors.green;
      case VillageEligibilityStatus.selected:
        return Colors.orange;
      case VillageEligibilityStatus.completed:
        return Colors.blue;
      case VillageEligibilityStatus.pending:
        return Colors.grey;
      case VillageEligibilityStatus.ineligible:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(VillageEligibilityStatus status) {
    switch (status) {
      case VillageEligibilityStatus.eligible:
        return Icons.check_circle;
      case VillageEligibilityStatus.selected:
        return Icons.star;
      case VillageEligibilityStatus.completed:
        return Icons.done_all;
      case VillageEligibilityStatus.pending:
        return Icons.pending;
      case VillageEligibilityStatus.ineligible:
        return Icons.cancel;
    }
  }

  String _getStatusLabel(VillageEligibilityStatus status) {
    switch (status) {
      case VillageEligibilityStatus.eligible:
        return 'Eligible';
      case VillageEligibilityStatus.selected:
        return 'Selected';
      case VillageEligibilityStatus.completed:
        return 'Completed';
      case VillageEligibilityStatus.pending:
        return 'Pending';
      case VillageEligibilityStatus.ineligible:
        return 'Ineligible';
    }
  }

  Color _getPriorityScoreColor(double score) {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.orange;
    return Colors.red;
  }

  String _getPriorityScoreDescription(double score) {
    if (score >= 4.0) return 'High priority - Strong candidate for Adarsh Gram selection';
    if (score >= 3.0) return 'Medium priority - Consider for selection with additional review';
    return 'Low priority - May not be ideal for immediate selection';
  }

  String _getInfrastructureLabel(String key) {
    final labels = {
      'pucca_road': 'Pucca Road',
      'piped_water': 'Piped Water Supply',
      'primary_school': 'Primary School',
      'health_center': 'Health Center',
      'anganwadi': 'Anganwadi Center',
      'community_hall': 'Community Hall',
    };
    return labels[key] ?? key;
  }

  IconData _getInfrastructureIcon(String key) {
    final icons = {
      'pucca_road': Icons.route,
      'piped_water': Icons.water_drop,
      'primary_school': Icons.school,
      'health_center': Icons.local_hospital,
      'anganwadi': Icons.child_care,
      'community_hall': Icons.business,
    };
    return icons[key] ?? Icons.help_outline;
  }

  String _getSocioEconomicLabel(String key) {
    final labels = {
      'unemployment_rate': 'Unemployment Rate (%)',
      'poverty_index': 'Poverty Index',
      'health_access_index': 'Health Access Index',
      'education_index': 'Education Index',
    };
    return labels[key] ?? key;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}