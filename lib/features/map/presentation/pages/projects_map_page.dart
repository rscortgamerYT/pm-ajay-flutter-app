import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/data/demo_data_provider.dart';
import '../../../../domain/entities/project.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;

class ProjectsMapPage extends StatefulWidget {
  const ProjectsMapPage({super.key});

  @override
  State<ProjectsMapPage> createState() => _ProjectsMapPageState();
}

class _ProjectsMapPageState extends State<ProjectsMapPage> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  Project? _selectedProject;
  bool _showHeatmap = false;
  bool _showGeofencing = true;
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final projects = DemoDataProvider.getDemoProjects();
    final filteredProjects = _filterProjects(projects);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects Map - Digital Twin'),
        actions: [
          IconButton(
            icon: Icon(_showHeatmap ? Icons.layers : Icons.layers_outlined),
            onPressed: () => setState(() => _showHeatmap = !_showHeatmap),
            tooltip: 'Toggle Heatmap',
          ),
          IconButton(
            icon: Icon(_showGeofencing ? Icons.location_on : Icons.location_off),
            onPressed: () => setState(() => _showGeofencing = !_showGeofencing),
            tooltip: 'Toggle Geofencing',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filterStatus = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Projects')),
              const PopupMenuItem(value: 'inProgress', child: Text('In Progress')),
              const PopupMenuItem(value: 'approved', child: Text('Approved')),
              const PopupMenuItem(value: 'delayed', child: Text('Delayed')),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: _selectedProject != null ? 7 : 10,
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(20.5937, 78.9629),
                initialZoom: 5.0,
                minZoom: 4.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.pmajay.app',
                ),

                // Geofencing circles
                if (_showGeofencing)
                  CircleLayer(
                    circles: filteredProjects.map((project) {
                      return CircleMarker(
                        point: LatLng(
                          project.location.latitude,
                          project.location.longitude,
                        ),
                        radius: 50000,
                        useRadiusInMeter: true,
                        color: _getProjectColor(project).withOpacity(0.1),
                        borderColor: _getProjectColor(project),
                        borderStrokeWidth: 2,
                      );
                    }).toList(),
                  ),

                // Heatmap effect
                if (_showHeatmap)
                  CircleLayer(
                    circles: filteredProjects.map((project) {
                      return CircleMarker(
                        point: LatLng(
                          project.location.latitude,
                          project.location.longitude,
                        ),
                        radius: 30000,
                        useRadiusInMeter: true,
                        color: _getHeatmapColor(project.completionPercentage),
                        borderStrokeWidth: 0,
                      );
                    }).toList(),
                  ),

                // Project markers
                MarkerLayer(
                  markers: filteredProjects.map((project) {
                    return Marker(
                      point: LatLng(
                        project.location.latitude,
                        project.location.longitude,
                      ),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedProject = project);
                          _animateMapToProject(project);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getProjectColor(project),
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _getProjectIcon(project),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          // Right sidebar for selected project
          if (_selectedProject != null)
            Expanded(
              flex: 3,
              child: _buildProjectSidebar(_selectedProject!),
            ),
        ],
      ),
    );
  }

  List<Project> _filterProjects(List<Project> projects) {
    if (_filterStatus == 'all') return projects;
    return projects.where((p) => p.status.name == _filterStatus).toList();
  }

  Color _getProjectColor(Project project) {
    switch (project.status) {
      case ProjectStatus.inProgress:
        return Colors.blue;
      case ProjectStatus.approved:
        return Colors.green;
      case ProjectStatus.delayed:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getProjectIcon(Project project) {
    switch (project.type) {
      case ProjectType.adarshGram:
        return Icons.location_city;
      case ProjectType.hostel:
        return Icons.home;
      case ProjectType.gia:
        return Icons.monetization_on;
      default:
        return Icons.folder;
    }
  }

  Color _getHeatmapColor(double percentage) {
    if (percentage >= 75) return Colors.green.withOpacity(0.3);
    if (percentage >= 50) return Colors.orange.withOpacity(0.3);
    return Colors.red.withOpacity(0.3);
  }

  String _getProjectScheme(Project project) {
    switch (project.type) {
      case ProjectType.adarshGram:
        return 'PM-AJAY Adarsh Gram Component';
      case ProjectType.hostel:
        return 'PM-AJAY Hostel Component';
      case ProjectType.gia:
        return 'PM-AJAY Grant-in-Aid (GIA) Component';
      default:
        return 'PM-AJAY General Component';
    }
  }

  Widget _buildProjectSidebar(Project project) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Project Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedProject = null),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Project header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getProjectColor(project).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getProjectIcon(project),
                    color: _getProjectColor(project),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.id,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // PM-AJAY Scheme
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance, size: 16, color: Colors.purple[700]),
                      const SizedBox(width: 8),
                      Text(
                        'PM-AJAY Scheme',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getProjectScheme(project),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[900],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Budget Information
            _buildSidebarSection(
              'Budget Information',
              Icons.account_balance_wallet,
              [
                if (project.metadata.containsKey('estimatedCost'))
                  _buildSidebarItem(
                    'Total Budget',
                    '₹${(project.metadata['estimatedCost'] / 10000000).toStringAsFixed(2)} Cr',
                    Icons.currency_rupee,
                  ),
                if (project.metadata.containsKey('allocatedAmount'))
                  _buildSidebarItem(
                    'Allocated',
                    '₹${(project.metadata['allocatedAmount'] / 10000000).toStringAsFixed(2)} Cr',
                    Icons.done,
                  ),
                if (project.metadata.containsKey('spentAmount'))
                  _buildSidebarItem(
                    'Spent',
                    '₹${(project.metadata['spentAmount'] / 10000000).toStringAsFixed(2)} Cr',
                    Icons.trending_down,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Department/Agency
            _buildSidebarSection(
              'Department',
              Icons.business,
              [
                _buildSidebarItem(
                  'Executing Agency',
                  project.executingAgencyId,
                  Icons.business_center,
                ),
                if (project.metadata.containsKey('department'))
                  _buildSidebarItem(
                    'Department',
                    project.metadata['department'].toString(),
                    Icons.account_balance,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Location Details
            _buildSidebarSection(
              'Location',
              Icons.location_on,
              [
                _buildSidebarItem(
                  'Address',
                  project.location.address ?? 'N/A',
                  Icons.place,
                ),
                _buildSidebarItem(
                  'District',
                  project.location.district ?? 'N/A',
                  Icons.map,
                ),
                _buildSidebarItem(
                  'State',
                  project.location.state ?? 'N/A',
                  Icons.public,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Project Status
            _buildSidebarSection(
              'Project Status',
              Icons.info,
              [
                _buildSidebarItem(
                  'Current Status',
                  project.status.name.toUpperCase(),
                  Icons.flag,
                  valueColor: _getProjectColor(project),
                ),
                _buildSidebarItem(
                  'Completion',
                  '${project.completionPercentage.toStringAsFixed(1)}%',
                  Icons.percent,
                ),
                if (project.metadata.containsKey('beneficiaries'))
                  _buildSidebarItem(
                    'Beneficiaries',
                    project.metadata['beneficiaries'].toString(),
                    Icons.people,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Timeline
            _buildSidebarSection(
              'Timeline',
              Icons.schedule,
              [
                _buildSidebarItem(
                  'Start Date',
                  _formatDate(project.startDate),
                  Icons.play_arrow,
                ),
                _buildSidebarItem(
                  'Expected End Date',
                  _formatDate(project.expectedEndDate),
                  Icons.stop,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _animateMapToProject(Project project) {
    final targetCenter = LatLng(
      project.location.latitude,
      project.location.longitude,
    );
    const targetZoom = 13.0;
    
    // Get current map state
    final currentCenter = _mapController.camera.center;
    final currentZoom = _mapController.camera.zoom;
    
    // Create animation controller
    final animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Create curved animation for smooth easing
    final curvedAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOutCubic,
    );
    
    // Animate center position
    final latTween = Tween<double>(
      begin: currentCenter.latitude,
      end: targetCenter.latitude,
    );
    final lngTween = Tween<double>(
      begin: currentCenter.longitude,
      end: targetCenter.longitude,
    );
    
    // Animate zoom level
    final zoomTween = Tween<double>(
      begin: currentZoom,
      end: targetZoom,
    );
    
    animationController.addListener(() {
      final lat = latTween.evaluate(curvedAnimation);
      final lng = lngTween.evaluate(curvedAnimation);
      final zoom = zoomTween.evaluate(curvedAnimation);
      
      _mapController.move(
        LatLng(lat, lng),
        zoom,
      );
    });
    
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.dispose();
      }
    });
    
    animationController.forward();
  }
}