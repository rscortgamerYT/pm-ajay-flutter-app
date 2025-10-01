import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectsListPage extends StatefulWidget {
  const ProjectsListPage({super.key});

  @override
  State<ProjectsListPage> createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends State<ProjectsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedComponent = 'All';
  String _selectedStatus = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // TODO: Implement sort
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
                hintText: 'Search projects...',
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

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', isComponent: true),
                const SizedBox(width: 8),
                _buildFilterChip('Adarsh Gram', isComponent: true),
                const SizedBox(width: 8),
                _buildFilterChip('GIA', isComponent: true),
                const SizedBox(width: 8),
                _buildFilterChip('Hostel', isComponent: true),
                const SizedBox(width: 16),
                const SizedBox(
                  height: 24,
                  child: VerticalDivider(),
                ),
                const SizedBox(width: 16),
                _buildFilterChip('All', isComponent: false),
                const SizedBox(width: 8),
                _buildFilterChip('In Progress', isComponent: false),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', isComponent: false),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', isComponent: false),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Projects List
          Expanded(
            child: _buildProjectsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement add project
        },
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isComponent}) {
    final isSelected = isComponent
        ? _selectedComponent == label
        : _selectedStatus == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (isComponent) {
            _selectedComponent = label;
          } else {
            _selectedStatus = label;
          }
        });
      },
    );
  }

  Widget _buildProjectsList() {
    // Mock data
    final projects = [
      {
        'id': '1',
        'name': 'Adarsh Gram Development - Phase 1',
        'component': 'Adarsh Gram',
        'agency': 'Gujarat Rural Development Agency',
        'state': 'Gujarat',
        'status': 'In Progress',
        'progress': 65,
        'budget': '₹15.5 Cr',
        'startDate': '01 Jan 2024',
        'endDate': '31 Dec 2024',
      },
      {
        'id': '2',
        'name': 'Student Hostel Construction - Delhi',
        'component': 'Hostel',
        'agency': 'Delhi Social Welfare Board',
        'state': 'Delhi',
        'status': 'Completed',
        'progress': 100,
        'budget': '₹8.2 Cr',
        'startDate': '15 Jun 2023',
        'endDate': '30 Nov 2023',
      },
      {
        'id': '3',
        'name': 'GIA Distribution - Q4 2024',
        'component': 'GIA',
        'agency': 'Maharashtra Social Welfare Dept',
        'state': 'Maharashtra',
        'status': 'Pending',
        'progress': 25,
        'budget': '₹25.0 Cr',
        'startDate': '01 Oct 2024',
        'endDate': '31 Mar 2025',
      },
      {
        'id': '4',
        'name': 'Adarsh Gram Infrastructure - Tamil Nadu',
        'component': 'Adarsh Gram',
        'agency': 'TN Backward Classes Corporation',
        'state': 'Tamil Nadu',
        'status': 'In Progress',
        'progress': 45,
        'budget': '₹20.3 Cr',
        'startDate': '15 Feb 2024',
        'endDate': '15 Aug 2025',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              context.push('/projects/${project['id']}');
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
                          project['name'] as String,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      _buildStatusChip(project['status'] as String),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.category,
                        project['component'] as String,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.location_on,
                        project['state'] as String,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.account_balance_wallet,
                        project['budget'] as String,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (project['progress'] as int) / 100,
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${project['progress']}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${project['startDate']} - ${project['endDate']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Completed':
        color = Colors.green;
        break;
      case 'In Progress':
        color = Colors.blue;
        break;
      case 'Pending':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
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