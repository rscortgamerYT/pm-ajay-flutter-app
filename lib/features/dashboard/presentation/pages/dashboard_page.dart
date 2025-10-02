import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pm_ajay/features/projects/presentation/pages/projects_list_page.dart';
import 'package:pm_ajay/features/funds/presentation/pages/funds_list_page.dart';
import 'package:pm_ajay/features/reports/presentation/pages/reports_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(4, (_) => GlobalKey());
  int _currentSectionIndex = 0;

  final List<String> _sectionTitles = ['Home', 'Projects', 'Funds', 'Reports'];

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
        if (position <= 100) {
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
        position - 80,
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
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildSection(0, const DashboardHome()),
                _buildSection(1, const ProjectsListPage()),
                _buildSection(2, const FundsListPage()),
                _buildSection(3, const ReportsPage()),
              ],
            ),
          ),
          // Navigation indicator
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.4,
            child: _buildNavIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(int index, Widget content) {
    return Container(
      key: _sectionKeys[index],
      height: MediaQuery.of(context).size.height - kToolbarHeight,
      child: content,
    );
  }

  Widget _buildNavIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_sectionTitles.length, (index) {
          final isActive = index == _currentSectionIndex;
          return GestureDetector(
            onTap: () => _scrollToSection(index),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isActive ? 4 : 2,
                      height: isActive ? 28 : 16,
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFFFF6900) : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isActive ? 75 : 0,
                      child: isActive
                          ? Text(
                              _sectionTitles[index],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF6900),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple Welcome Card (Government Branded)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF000080), // Navy blue
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF9933), // Saffron border
                width: 3,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.waving_hand,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'नमस्ते, Admin!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Welcome to PM-AJAY',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Main Action Cards (4 Large Cards)
          Text(
            'मुख्य कार्य / Quick Actions',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          // Projects Card
          _buildLargeActionCard(
            context,
            icon: Icons.folder,
            title: 'मेरी परियोजनाएं',
            subtitle: 'My Projects',
            value: '156 Active',
            color: const Color(0xFF1976D2),
            onTap: () => context.push('/projects'),
          ),
          const SizedBox(height: 16),
          
          // Funds Card
          _buildLargeActionCard(
            context,
            icon: Icons.account_balance_wallet,
            title: 'फंड',
            subtitle: 'Funds',
            value: '₹2.5 करोड़',
            color: const Color(0xFF138808),
            onTap: () => context.push('/funds'),
          ),
          const SizedBox(height: 16),
          
          // Reports Card
          _buildLargeActionCard(
            context,
            icon: Icons.assessment,
            title: 'रिपोर्ट',
            subtitle: 'Reports',
            value: 'View All',
            color: const Color(0xFFFF9933),
            onTap: () => context.push('/reports'),
          ),
          const SizedBox(height: 16),
          
          // Agencies Card
          _buildLargeActionCard(
            context,
            icon: Icons.business,
            title: 'एजेंसी',
            subtitle: 'Agencies',
            value: '45 Active',
            color: const Color(0xFF9C27B0),
            onTap: () => context.push('/agencies'),
          ),
          const SizedBox(height: 32),

          // Help Card (Always Visible)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF138808).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF138808),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.help_outline,
                  size: 40,
                  color: Color(0xFF138808),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'मदद चाहिए? / Need Help?',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF138808),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'टोल फ्री: 1800-XXX-XXXX',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone),
                  label: const Text('कॉल करें'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF138808),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // PM-AJAY Compliance Hub Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.verified_user,
                          color: Colors.deepPurple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '📋 PM-AJAY Compliance Hub',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => context.push('/ai-insights'),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildComplianceCard(
                        context,
                        'VDP Wizard',
                        Icons.location_city,
                        Colors.blue,
                        '/vdp-wizard',
                      ),
                      _buildComplianceCard(
                        context,
                        'Gap Analysis',
                        Icons.analytics,
                        Colors.orange,
                        '/gap-analysis',
                      ),
                      _buildComplianceCard(
                        context,
                        'Adarsh Gram',
                        Icons.verified,
                        Colors.green,
                        '/adarsh-gram',
                      ),
                      _buildComplianceCard(
                        context,
                        'Funding Tracker',
                        Icons.account_balance,
                        Colors.purple,
                        '/funding-tracker',
                      ),
                      _buildComplianceCard(
                        context,
                        'Milestones',
                        Icons.timeline,
                        Colors.teal,
                        '/milestone-dashboard',
                      ),
                      _buildComplianceCard(
                        context,
                        'Skill Gap',
                        Icons.school,
                        Colors.indigo,
                        '/skill-gap',
                      ),
                      _buildComplianceCard(
                        context,
                        'Training Partners',
                        Icons.business_center,
                        Colors.brown,
                        '/training-partner-compliance',
                      ),
                      _buildComplianceCard(
                        context,
                        'Hostel Proposals',
                        Icons.home_work,
                        Colors.deepOrange,
                        '/hostel-proposal',
                      ),
                      _buildComplianceCard(
                        context,
                        'Social Audit',
                        Icons.groups,
                        Colors.cyan,
                        '/social-audit',
                      ),
                      _buildComplianceCard(
                        context,
                        'Role Management',
                        Icons.admin_panel_settings,
                        Colors.pink,
                        '/role-management',
                      ),
                      _buildComplianceCard(
                        context,
                        'Compliance Monitor',
                        Icons.shield,
                        Colors.red,
                        '/enhanced-compliance',
                      ),
                      _buildComplianceCard(
                        context,
                        'Reports & Alerts',
                        Icons.assessment,
                        Colors.amber,
                        '/enriched-reporting',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Additional Features (Simplified - No Expansion)
          Text(
            'अधिक सुविधाएं / More Features',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildComplianceCard(
                context,
                'VDP Wizard',
                Icons.location_city,
                Colors.blue,
                '/vdp-wizard',
              ),
              _buildComplianceCard(
                context,
                'Gap Analysis',
                Icons.analytics,
                Colors.orange,
                '/gap-analysis',
              ),
              _buildComplianceCard(
                context,
                'Adarsh Gram',
                Icons.verified,
                Colors.green,
                '/adarsh-gram',
              ),
              _buildComplianceCard(
                context,
                'Skill Gap',
                Icons.school,
                Colors.indigo,
                '/skill-gap',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recent Activity (Simplified)
          Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Recent Activity',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Live',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...[
                    _buildActivityItem(
                      context,
                      'Project Approved',
                      'Adarsh Gram Phase 2 received approval',
                      Icons.check_circle,
                      Colors.green,
                      '2 mins ago',
                    ),
                    _buildActivityItem(
                      context,
                      'Funds Transferred',
                      '₹50L transferred to Rural Development',
                      Icons.attach_money,
                      Colors.blue,
                      '15 mins ago',
                    ),
                    _buildActivityItem(
                      context,
                      'Document Uploaded',
                      'Compliance report added by Agency-12',
                      Icons.upload_file,
                      Colors.orange,
                      '1 hour ago',
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 20),

          // Statistics Grid (Simplified - No Animation)
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Stats',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // First Row: Total Projects with Progress Ring
                _buildInteractiveStatCard(
                  context,
                  title: 'Total Projects',
                  value: '156',
                  subtitle: '+15% from last month',
                  icon: Icons.folder,
                  color: const Color(0xFF3B82F6),
                  progress: 0.75,
                ),
                const SizedBox(height: 16),
                
                // Second Row: Two cards side by side
                Row(
                  children: [
                    Expanded(
                      child: _buildInteractiveStatCard(
                        context,
                        title: 'Active Agencies',
                        value: '45',
                        subtitle: 'Currently operational',
                        icon: Icons.business,
                        color: const Color(0xFF10B981),
                        progress: 0.85,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInteractiveStatCard(
                        context,
                        title: 'Funds Allocated',
                        value: '₹2.5Cr',
                        subtitle: '+₹0.5Cr this week',
                        icon: Icons.account_balance_wallet,
                        color: const Color(0xFFF59E0B),
                        progress: 0.62,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Third Row: Pending with Alert Badge
                _buildInteractiveStatCard(
                  context,
                  title: 'Pending Approvals',
                  value: '12',
                  subtitle: '8 urgent reviews required',
                  icon: Icons.pending_actions,
                  color: const Color(0xFFEF4444),
                  progress: 0.33,
                  showAlert: true,
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
        ],
      ),
    );
  }

  Widget _buildLargeActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          height: 140,
          child: Row(
            children: [
              // Large Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 24,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInteractiveStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double progress,
    bool showAlert = false,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      if (showAlert)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'URGENT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  Widget _buildComplianceCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String route,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}