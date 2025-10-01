import 'package:flutter/material.dart';

class AgencyDetailPage extends StatelessWidget {
  final String agencyId;

  const AgencyDetailPage({
    super.key,
    required this.agencyId,
  });

  @override
  Widget build(BuildContext context) {
    // Mock data - replace with actual data fetching
    final agency = {
      'id': agencyId,
      'name': 'Ministry of Social Justice and Empowerment',
      'type': 'Implementing Agency',
      'state': 'Central',
      'address': 'Shastri Bhawan, New Delhi - 110001',
      'email': 'contact@msje.gov.in',
      'phone': '+91-11-23381304',
      'headName': 'Dr. Rajesh Kumar',
      'headDesignation': 'Secretary',
      'projects': 45,
      'activeProjects': 32,
      'completedProjects': 13,
      'totalFunds': '₹125.5 Crore',
      'fundsUtilized': '₹98.2 Crore',
      'status': 'Active',
      'establishedDate': 'January 1995',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agency Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit agency
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Implement more options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
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
                            Icons.business,
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
                                agency['name'] as String,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                agency['type'] as String,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            agency['status'] as String,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Statistics Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    context,
                    'Total Projects',
                    agency['projects'].toString(),
                    Icons.folder,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    context,
                    'Active Projects',
                    agency['activeProjects'].toString(),
                    Icons.play_circle_outline,
                    Colors.green,
                  ),
                  _buildStatCard(
                    context,
                    'Total Funds',
                    agency['totalFunds'] as String,
                    Icons.account_balance_wallet,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    context,
                    'Utilized',
                    agency['fundsUtilized'] as String,
                    Icons.check_circle_outline,
                    Colors.purple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact Information
            _buildSection(
              context,
              'Contact Information',
              [
                _buildInfoRow(Icons.location_on, 'Address', agency['address'] as String),
                _buildInfoRow(Icons.email, 'Email', agency['email'] as String),
                _buildInfoRow(Icons.phone, 'Phone', agency['phone'] as String),
                _buildInfoRow(Icons.calendar_today, 'Established', agency['establishedDate'] as String),
              ],
            ),

            // Head Information
            _buildSection(
              context,
              'Leadership',
              [
                _buildInfoRow(Icons.person, 'Name', agency['headName'] as String),
                _buildInfoRow(Icons.badge, 'Designation', agency['headDesignation'] as String),
              ],
            ),

            // Recent Projects
            _buildSection(
              context,
              'Recent Projects',
              [
                _buildProjectItem(
                  'Adarsh Gram Development - Phase 1',
                  'In Progress',
                  Colors.blue,
                ),
                _buildProjectItem(
                  'Hostel Construction - Delhi',
                  'Completed',
                  Colors.green,
                ),
                _buildProjectItem(
                  'GIA Distribution - Q4 2024',
                  'Pending Approval',
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: View all projects
                    },
                    icon: const Icon(Icons.folder_open),
                    label: const Text('View All Projects'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: View fund details
                    },
                    icon: const Icon(Icons.account_balance_wallet),
                    label: const Text('View Fund Details'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
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
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: children,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectItem(String name, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
    );
  }
}