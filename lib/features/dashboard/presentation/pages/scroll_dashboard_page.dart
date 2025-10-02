import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/vertical_nav_menu.dart';

class ScrollDashboardPage extends StatefulWidget {
  const ScrollDashboardPage({super.key});

  @override
  State<ScrollDashboardPage> createState() => _ScrollDashboardPageState();
}

class _ScrollDashboardPageState extends State<ScrollDashboardPage> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(6, (_) => GlobalKey());
  int _currentSectionIndex = 0;

  final List<String> _sectionTitles = [
    'Overview',
    'Quick Stats',
    'PM-AJAY Features',
    'Collaboration',
    'AI Insights',
    'Activity Feed',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrollPosition = _scrollController.offset;
    int newIndex = 0;

    for (int i = 0; i < _sectionKeys.length; i++) {
      final RenderBox? renderBox = _sectionKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero).dy;
        if (position <= 200) {
          newIndex = i;
        }
      }
    }

    if (newIndex != _currentSectionIndex) {
      setState(() => _currentSectionIndex = newIndex);
    }
  }

  void _scrollToSection(int index) {
    final RenderBox? renderBox = _sectionKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero).dy + _scrollController.offset;
      _scrollController.animateTo(
        position - 100,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

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
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildSection(0, _buildOverviewSection()),
                _buildSection(1, _buildQuickStatsSection()),
                _buildSection(2, _buildPMAJAYFeaturesSection()),
                _buildSection(3, _buildCollaborationSection()),
                _buildSection(4, _buildAIInsightsSection()),
                _buildSection(5, _buildActivityFeedSection()),
              ],
            ),
          ),

          // Fixed vertical navigation menu
          Positioned(
            left: 20,
            top: MediaQuery.of(context).size.height * 0.3,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: VerticalNavMenu(
                menuItems: List.generate(
                  _sectionTitles.length,
                  (index) => MenuItem(
                    label: _sectionTitles[index],
                    onTap: () => _scrollToSection(index),
                  ),
                ),
                activeColor: const Color(0xFFFF6900),
                currentIndex: _currentSectionIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(int index, Widget content) {
    return Container(
      key: _sectionKeys[index],
      padding: const EdgeInsets.symmetric(horizontal: 300, vertical: 60),
      child: content,
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome to PM-AJAY',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Comprehensive governance platform for Prime Minister\'s scheme management',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                'Projects',
                Icons.work,
                Colors.blue,
                () => context.push('/projects'),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildFeatureCard(
                'Funds',
                Icons.account_balance_wallet,
                Colors.green,
                () => context.push('/funds'),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildFeatureCard(
                'Reports',
                Icons.assessment,
                Colors.orange,
                () => context.push('/reports'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(child: _buildStatCard('42', 'Active Projects', Colors.blue)),
            const SizedBox(width: 20),
            Expanded(child: _buildStatCard('₹125 Cr', 'Total Funds', Colors.green)),
            const SizedBox(width: 20),
            Expanded(child: _buildStatCard('89%', 'Completion Rate', Colors.orange)),
          ],
        ),
      ],
    );
  }

  Widget _buildPMAJAYFeaturesSection() {
    final features = [
      {'title': 'VDP Wizard', 'icon': Icons.location_city, 'color': Colors.blue, 'route': '/vdp-wizard'},
      {'title': 'Gap Analysis', 'icon': Icons.analytics, 'color': Colors.orange, 'route': '/gap-analysis'},
      {'title': 'Adarsh Gram', 'icon': Icons.verified, 'color': Colors.green, 'route': '/adarsh-gram'},
      {'title': 'Funding Tracker', 'icon': Icons.account_balance, 'color': Colors.purple, 'route': '/funding-tracker'},
      {'title': 'Milestones', 'icon': Icons.timeline, 'color': Colors.teal, 'route': '/milestone-dashboard'},
      {'title': 'Skill Gap', 'icon': Icons.school, 'color': Colors.indigo, 'route': '/skill-gap'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PM-AJAY Compliance Features',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.5,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return _buildFeatureCard(
              feature['title'] as String,
              feature['icon'] as IconData,
              feature['color'] as Color,
              () => context.push(feature['route'] as String),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCollaborationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Collaboration Hub',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        Card(
          elevation: 4,
          child: InkWell(
            onTap: () => context.push('/collaboration'),
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.groups, size: 48, color: Colors.blue),
                  ),
                  const SizedBox(width: 30),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discord-style Collaboration',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Real-time chat, checklists, and integrated Google Meet',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI-Powered Insights',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        Card(
          elevation: 4,
          child: InkWell(
            onTap: () => context.push('/ai-insights'),
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.psychology, size: 48, color: Colors.deepPurple),
                  ),
                  const SizedBox(width: 30),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Autonomous AI Governance',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Real-time analysis, bottleneck detection & predictive insights',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityFeedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        ...List.generate(
          5,
          (index) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.primaries[index % Colors.primaries.length],
                child: Text('${index + 1}'),
              ),
              title: Text('Activity ${index + 1}'),
              subtitle: Text('Recent update ${index + 1} minutes ago'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}