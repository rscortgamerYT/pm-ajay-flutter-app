import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pm_ajay/features/map/presentation/pages/projects_map_page.dart';
import 'package:pm_ajay/features/compliance/presentation/pages/compliance_hub_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('Projects')),
    const Center(child: Text('Funds')),
    const Center(child: Text('Reports')),
    const ComplianceHubPage(),
    const ProjectsMapPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PM-AJAY Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Funds',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            selectedIcon: Icon(Icons.verified_user),
            label: 'Compliance',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Here\'s an overview of PM-AJAY projects',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // AI Insights Feature Card
          Card(
            elevation: 4,
            color: Colors.purple[50],
            child: InkWell(
              onTap: () => context.push('/ai-insights'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.purple,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🤖 AI Autonomous Governance',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Real-time AI analysis, bottleneck detection & predictive insights',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.purple[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Statistics Cards
          Text(
            'Quick Stats',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
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
                'Active Agencies',
                '45',
                Icons.business,
                Colors.green,
              ),
              _buildStatCard(
                context,
                'Funds Allocated',
                '₹2.5Cr',
                Icons.account_balance_wallet,
                Colors.orange,
              ),
              _buildStatCard(
                context,
                'Pending Approvals',
                '12',
                Icons.pending_actions,
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Component Cards
          Text(
            'PM-AJAY Components',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildComponentCard(
            context,
            'Adarsh Gram',
            'Model village development projects',
            Icons.location_city,
            Colors.blue,
            () => context.push('/projects'),
          ),
          const SizedBox(height: 12),
          _buildComponentCard(
            context,
            'GIA (Grant-in-Aid)',
            'Financial assistance programs',
            Icons.monetization_on,
            Colors.green,
            () => context.push('/funds'),
          ),
          const SizedBox(height: 12),
          _buildComponentCard(
            context,
            'Hostel',
            'Student accommodation facilities',
            Icons.home,
            Colors.orange,
            () => context.push('/projects'),
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
                'View Agencies',
                Icons.business,
                () => context.push('/agencies'),
              ),
              _buildActionChip(
                context,
                'Track Projects',
                Icons.track_changes,
                () => context.push('/projects'),
              ),
              _buildActionChip(
                context,
                'Fund Status',
                Icons.account_balance,
                () => context.push('/funds'),
              ),
              _buildActionChip(
                context,
                'Generate Report',
                Icons.description,
                () => context.push('/reports'),
              ),
              _buildActionChip(
                context,
                'AI Insights',
                Icons.psychology,
                () => context.push('/ai-insights'),
              ),
              _buildActionChip(
                context,
                'Projects Map',
                Icons.map,
                () => context.push('/map'),
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

  Widget _buildComponentCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
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