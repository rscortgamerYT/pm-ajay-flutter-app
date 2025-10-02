import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pm_ajay/core/data/demo_data_provider.dart';
import 'package:pm_ajay/domain/entities/project.dart';

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
    // Get all projects from DemoDataProvider
    final allProjects = DemoDataProvider.getDemoProjects();
    
    // Filter projects based on selected component type
    List<Project> filteredProjects = allProjects;
    
    if (_selectedComponent != 'All') {
      filteredProjects = filteredProjects.where((project) {
        switch (_selectedComponent) {
          case 'Adarsh Gram':
            return project.type == ProjectType.adarshGram;
          case 'GIA':
            return project.type == ProjectType.gia;
          case 'Hostel':
            return project.type == ProjectType.hostel;
          default:
            return true;
        }
      }).toList();
    }
    
    // Filter projects based on selected status
    if (_selectedStatus != 'All') {
      filteredProjects = filteredProjects.where((project) {
        switch (_selectedStatus) {
          case 'In Progress':
            return project.status == ProjectStatus.inProgress;
          case 'Completed':
            return project.status == ProjectStatus.completed;
          case 'Pending':
            return project.status == ProjectStatus.approved;
          default:
            return true;
        }
      }).toList();
    }
    
    // Filter projects based on search query
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filteredProjects = filteredProjects.where((project) {
        return project.name.toLowerCase().contains(searchQuery) ||
               (project.location.state?.toLowerCase().contains(searchQuery) ?? false) ||
               (project.location.district?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProjects.length,
      itemBuilder: (context, index) {
        final project = filteredProjects[index];
        
        // Map project type to component label
        String componentLabel;
        switch (project.type) {
          case ProjectType.adarshGram:
            componentLabel = 'Adarsh Gram';
            break;
          case ProjectType.gia:
            componentLabel = 'GIA';
            break;
          case ProjectType.hostel:
            componentLabel = 'Hostel';
            break;
          case ProjectType.other:
            componentLabel = 'Other';
            break;
        }
        
        // Map project status to status label
        String statusLabel;
        switch (project.status) {
          case ProjectStatus.inProgress:
            statusLabel = 'In Progress';
            break;
          case ProjectStatus.completed:
            statusLabel = 'Completed';
            break;
          case ProjectStatus.approved:
            statusLabel = 'Pending';
            break;
          case ProjectStatus.delayed:
            statusLabel = 'Delayed';
            break;
          case ProjectStatus.planning:
            statusLabel = 'Planning';
            break;
          case ProjectStatus.suspended:
            statusLabel = 'Suspended';
            break;
          case ProjectStatus.cancelled:
            statusLabel = 'Cancelled';
            break;
        }
        
        // Format budget
        final budgetInCr = (project.metadata['estimatedCost'] as int) / 10000000;
        final budgetLabel = '₹${budgetInCr.toStringAsFixed(1)} Cr';
        
        // Format dates
        final startDate = '${project.startDate.day.toString().padLeft(2, '0')} ${_getMonthName(project.startDate.month)} ${project.startDate.year}';
        final endDate = '${project.expectedEndDate.day.toString().padLeft(2, '0')} ${_getMonthName(project.expectedEndDate.month)} ${project.expectedEndDate.year}';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              context.push('/projects/${project.id}');
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
                          project.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      _buildStatusChip(statusLabel),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.category,
                        componentLabel,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.location_on,
                        project.location.state ?? 'N/A',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.account_balance_wallet,
                        budgetLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: project.completionPercentage / 100,
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${project.completionPercentage.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$startDate - $endDate',
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
  
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
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
      case 'Delayed':
        color = Colors.red;
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