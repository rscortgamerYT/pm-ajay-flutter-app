import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectsDemoPage extends StatelessWidget {
  const ProjectsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Projects Overview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Active PM-AJAY Projects',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // Statistics Cards
          GridView.count(
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
                '156',
                Icons.folder,
                Colors.blue,
              ),
              _buildStatCard(
                context,
                'In Progress',
                '89',
                Icons.pending_actions,
                Colors.orange,
              ),
              _buildStatCard(
                context,
                'Completed',
                '52',
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatCard(
                context,
                'Delayed',
                '15',
                Icons.warning,
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Projects
          Text(
            'Recent Projects',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildProjectCard(
            context,
            'AG-2024-156',
            'Adarsh Gram - Sitapur District',
            'Infrastructure development for model village',
            '₹45,00,000',
            'In Progress',
            Colors.orange,
            65,
          ),
          const SizedBox(height: 12),
          _buildProjectCard(
            context,
            'GIA-2024-089',
            'GIA Fund - Lucknow Region',
            'Grant-in-Aid for educational initiatives',
            '₹28,50,000',
            'In Progress',
            Colors.orange,
            42,
          ),
          const SizedBox(height: 12),
          _buildProjectCard(
            context,
            'HST-2024-034',
            'Hostel Infrastructure - Varanasi',
            'Student accommodation facility upgrade',
            '₹65,00,000',
            'Completed',
            Colors.green,
            100,
          ),
          const SizedBox(height: 12),
          _buildProjectCard(
            context,
            'AG-2024-142',
            'Adarsh Gram - Amethi District',
            'Rural electrification and water supply',
            '₹38,75,000',
            'In Progress',
            Colors.orange,
            78,
          ),
          const SizedBox(height: 12),
          _buildProjectCard(
            context,
            'GIA-2024-076',
            'GIA Fund - Prayagraj Zone',
            'Community health center establishment',
            '₹52,00,000',
            'In Progress',
            Colors.orange,
            55,
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionChip(
                context,
                'New Project',
                Icons.add,
                () => context.push('/projects/new'),
              ),
              _buildActionChip(
                context,
                'View All',
                Icons.list,
                () => context.push('/projects'),
              ),
              _buildActionChip(
                context,
                'Generate Report',
                Icons.description,
                () => context.push('/reports'),
              ),
              _buildActionChip(
                context,
                'Map View',
                Icons.map,
                () {},
              ),
            ],
          ),
        ],
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
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    String projectId,
    String title,
    String description,
    String budget,
    String status,
    Color statusColor,
    int progress,
  ) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/projects/$projectId'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    projectId,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.account_balance_wallet, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    budget,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '$progress%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ActionChip(
      label: Text(label),
      avatar: Icon(icon, size: 18),
      onPressed: onPressed,
    );
  }
}