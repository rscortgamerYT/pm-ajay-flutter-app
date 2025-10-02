import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AIInsightsPage extends StatelessWidget {
  const AIInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Autonomous Governance'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildSectionHeader(
              '📋 PM-AJAY Compliance Features',
              Icons.verified_user,
              Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            ..._buildFeatureCards(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      color: Colors.deepPurple.shade50,
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
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.psychology,
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
                        'PM-AJAY Compliance Hub',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Comprehensive governance tools for Prime Minister\'s scheme compliance',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    '12',
                    'Total Features',
                    Colors.deepPurple,
                    Icons.apps,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox(
                    '100%',
                    'Compliance Ready',
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFeatureCards(BuildContext context) {
    final features = [
      {
        'title': 'Village Development Plan (VDP) Wizard',
        'description': 'Automated wizard to create comprehensive village development plans',
        'icon': Icons.location_city,
        'color': Colors.blue,
        'route': '/vdp-wizard',
      },
      {
        'title': 'Gap-Analysis Engine',
        'description': 'Identify infrastructure gaps and get scheme convergence recommendations',
        'icon': Icons.analytics,
        'color': Colors.orange,
        'route': '/gap-analysis',
      },
      {
        'title': 'Adarsh Gram Declaration Assistant',
        'description': 'Guided workflow to declare model villages under PM-AJAY',
        'icon': Icons.verified,
        'color': Colors.green,
        'route': '/adarsh-gram',
      },
      {
        'title': 'Multi-Round Funding Tracker',
        'description': 'Track funding eligibility across multiple tranches and rounds',
        'icon': Icons.account_balance,
        'color': Colors.purple,
        'route': '/funding-tracker',
      },
      {
        'title': 'Milestone Dashboard',
        'description': 'Monitor milestone-based fund releases with accountability tracking',
        'icon': Icons.timeline,
        'color': Colors.teal,
        'route': '/milestone-dashboard',
      },
      {
        'title': 'Skill Gap System',
        'description': 'Analyze skill gaps and get personalized course recommendations',
        'icon': Icons.school,
        'color': Colors.indigo,
        'route': '/skill-gap',
      },
      {
        'title': 'Training Partner Compliance',
        'description': 'Monitor training partner performance and compliance scores',
        'icon': Icons.business_center,
        'color': Colors.brown,
        'route': '/training-partner-compliance',
      },
      {
        'title': 'Smart Hostel Proposal Workflow',
        'description': '5-step wizard for comprehensive hostel infrastructure proposals',
        'icon': Icons.home_work,
        'color': Colors.deepOrange,
        'route': '/hostel-proposal',
      },
      {
        'title': 'Social Audit & Gram Sabha',
        'description': 'Track social audits, meetings, and citizen feedback engagement',
        'icon': Icons.groups,
        'color': Colors.cyan,
        'route': '/social-audit',
      },
      {
        'title': 'Granular Role Management',
        'description': 'Advanced role definitions with detailed permission controls',
        'icon': Icons.admin_panel_settings,
        'color': Colors.pink,
        'route': '/role-management',
      },
      {
        'title': 'Enhanced Compliance Monitoring',
        'description': 'Real-time compliance tracking with alerts and scoring systems',
        'icon': Icons.shield,
        'color': Colors.red,
        'route': '/enhanced-compliance',
      },
      {
        'title': 'Enriched Reporting & Alerts',
        'description': 'Advanced reporting dashboard with custom report generation',
        'icon': Icons.assessment,
        'color': Colors.amber,
        'route': '/enriched-reporting',
      },
    ];

    return features.map((feature) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => context.push(feature['route'] as String),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (feature['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: feature['color'] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature['description'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

}