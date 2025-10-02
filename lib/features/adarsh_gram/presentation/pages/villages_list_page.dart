import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/village_model.dart';
import '../../providers/village_providers.dart';

class VillagesListPage extends ConsumerStatefulWidget {
  const VillagesListPage({super.key});

  @override
  ConsumerState<VillagesListPage> createState() => _VillagesListPageState();
}

class _VillagesListPageState extends ConsumerState<VillagesListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final villagesAsync = ref.watch(villagesProvider);
    final stats = ref.watch(villageStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adarsh Gram Villages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(villagesProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Cards
          _buildStatisticsSection(stats),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search villages by name, district, or state...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', stats.totalVillages),
                const SizedBox(width: 8),
                _buildFilterChip('Eligible', stats.eligibleVillages),
                const SizedBox(width: 8),
                _buildFilterChip('Selected', stats.selectedVillages),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', stats.completedVillages),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', stats.pendingVillages),
                const SizedBox(width: 8),
                _buildFilterChip('Ineligible', stats.ineligibleVillages),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Villages List
          Expanded(
            child: villagesAsync.when(
              data: (villages) => _buildVillagesList(villages),
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
                        ref.read(villagesProvider.notifier).refresh();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add village page
        },
        icon: const Icon(Icons.add_location),
        label: const Text('Add Village'),
      ),
    );
  }

  Widget _buildStatisticsSection(VillageStatistics stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatCard(
                  'Total Villages',
                  stats.totalVillages.toString(),
                  Icons.location_city,
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Eligible',
                  '${stats.eligibleVillages} (${stats.eligibilityRate.toStringAsFixed(1)}%)',
                  Icons.check_circle,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Selected',
                  stats.selectedVillages.toString(),
                  Icons.star,
                  Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Avg SC Pop',
                  '${stats.averageSCPercentage.toStringAsFixed(1)}%',
                  Icons.people,
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
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
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? label : 'All';
        });
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildVillagesList(List<VillageModel> villages) {
    // Apply filters
    var filteredVillages = villages;

    // Apply status filter
    if (_selectedFilter != 'All') {
      filteredVillages = filteredVillages.where((village) {
        switch (_selectedFilter) {
          case 'Eligible':
            return village.eligibilityStatus == VillageEligibilityStatus.eligible;
          case 'Selected':
            return village.eligibilityStatus == VillageEligibilityStatus.selected;
          case 'Completed':
            return village.eligibilityStatus == VillageEligibilityStatus.completed;
          case 'Pending':
            return village.eligibilityStatus == VillageEligibilityStatus.pending;
          case 'Ineligible':
            return village.eligibilityStatus == VillageEligibilityStatus.ineligible;
          default:
            return true;
        }
      }).toList();
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filteredVillages = filteredVillages.where((village) {
        return village.name.toLowerCase().contains(query) ||
            village.district.toLowerCase().contains(query) ||
            village.state.toLowerCase().contains(query);
      }).toList();
    }

    if (filteredVillages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No villages found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            if (_searchController.text.isNotEmpty || _selectedFilter != 'All')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _selectedFilter = 'All';
                    });
                  },
                  child: const Text('Clear filters'),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredVillages.length,
      itemBuilder: (context, index) {
        final village = filteredVillages[index];
        return _buildVillageCard(village);
      },
    );
  }

  Widget _buildVillageCard(VillageModel village) {
    final statusColor = _getStatusColor(village.eligibilityStatus);
    final statusIcon = _getStatusIcon(village.eligibilityStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.push('/adarsh-gram/villages/${village.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          village.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${village.district}, ${village.state}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
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
              const SizedBox(height: 12),

              // Key Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      'SC Population',
                      '${village.scPopulationPercentage.toStringAsFixed(1)}%',
                      Icons.people,
                      village.scPopulationPercentage >= 50 ? Colors.green : Colors.red,
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      'Total Population',
                      village.totalPopulation.toString(),
                      Icons.groups,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      'Literacy Rate',
                      '${village.literacyRate.toStringAsFixed(1)}%',
                      Icons.school,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Priority Score (if available)
              if (village.priorityScore != null && village.priorityScore! > 0)
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber[700]),
                    const SizedBox(width: 4),
                    Text(
                      'Priority Score: ${village.priorityScore!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
}