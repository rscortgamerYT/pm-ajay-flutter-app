import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AgenciesListPage extends StatefulWidget {
  const AgenciesListPage({super.key});

  @override
  State<AgenciesListPage> createState() => _AgenciesListPageState();
}

class _AgenciesListPageState extends State<AgenciesListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agencies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search agencies...',
                prefixIcon: const Icon(Icons.search),
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

          // Type Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Implementing'),
                const SizedBox(width: 8),
                _buildFilterChip('Executing'),
                const SizedBox(width: 8),
                _buildFilterChip('State'),
                const SizedBox(width: 8),
                _buildFilterChip('UT'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Agencies List
          Expanded(
            child: _buildAgenciesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement add agency
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Agency'),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedType == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = label;
        });
      },
    );
  }

  Widget _buildAgenciesList() {
    // Mock data
    final agencies = [
      {
        'id': '1',
        'name': 'Ministry of Social Justice and Empowerment',
        'type': 'Implementing',
        'state': 'Central',
        'projects': 45,
        'status': 'Active',
      },
      {
        'id': '2',
        'name': 'Department of Social Welfare, Maharashtra',
        'type': 'State',
        'state': 'Maharashtra',
        'projects': 23,
        'status': 'Active',
      },
      {
        'id': '3',
        'name': 'Gujarat Rural Development Agency',
        'type': 'Executing',
        'state': 'Gujarat',
        'projects': 18,
        'status': 'Active',
      },
      {
        'id': '4',
        'name': 'Delhi Social Welfare Board',
        'type': 'UT',
        'state': 'Delhi',
        'projects': 12,
        'status': 'Active',
      },
      {
        'id': '5',
        'name': 'Tamil Nadu Backward Classes Corporation',
        'type': 'Executing',
        'state': 'Tamil Nadu',
        'projects': 31,
        'status': 'Active',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agencies.length,
      itemBuilder: (context, index) {
        final agency = agencies[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              context.push('/agencies/${agency['id']}');
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          agency['name'] as String,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          agency['status'] as String,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.business,
                        agency['type'] as String,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.location_on,
                        agency['state'] as String,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.folder,
                        '${agency['projects']} Projects',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}