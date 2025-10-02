import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FundsDemoPage extends StatelessWidget {
  const FundsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Funds Management',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Track fund allocation and utilization',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // Fund Statistics
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
                'Total Allocated',
                '₹245 Cr',
                Icons.account_balance,
                Colors.blue,
              ),
              _buildStatCard(
                context,
                'Disbursed',
                '₹186 Cr',
                Icons.payments,
                Colors.green,
              ),
              _buildStatCard(
                context,
                'Pending',
                '₹59 Cr',
                Icons.pending,
                Colors.orange,
              ),
              _buildStatCard(
                context,
                'Utilization',
                '76%',
                Icons.trending_up,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Fund Allocations
          Text(
            'Recent Allocations',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildFundCard(
            context,
            'GIA-2024-089',
            'Adarsh Gram Development',
            'Infrastructure & Amenities',
            '₹45,00,000',
            '₹33,75,000',
            75,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildFundCard(
            context,
            'GIA-2024-092',
            'Educational Infrastructure',
            'School Building & Equipment',
            '₹28,50,000',
            '₹11,97,000',
            42,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildFundCard(
            context,
            'HST-2024-034',
            'Hostel Facilities',
            'Student Accommodation Upgrade',
            '₹65,00,000',
            '₹65,00,000',
            100,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildFundCard(
            context,
            'GIA-2024-076',
            'Healthcare Facilities',
            'Community Health Center',
            '₹52,00,000',
            '₹28,60,000',
            55,
            Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildFundCard(
            context,
            'AG-2024-156',
            'Rural Electrification',
            'Village Power Supply Project',
            '₹38,75,000',
            '₹30,22,500',
            78,
            Colors.green,
          ),
          const SizedBox(height: 24),

          // Fund Categories
          Text(
            'Fund Categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildCategoryCard(
            context,
            'Adarsh Gram',
            '₹125 Cr',
            '₹96 Cr',
            77,
            Icons.location_city,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildCategoryCard(
            context,
            'GIA (Grant-in-Aid)',
            '₹85 Cr',
            '₹62 Cr',
            73,
            Icons.monetization_on,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildCategoryCard(
            context,
            'Hostel',
            '₹35 Cr',
            '₹28 Cr',
            80,
            Icons.home,
            Colors.orange,
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
                'New Allocation',
                Icons.add,
                () => context.push('/funds/new'),
              ),
              _buildActionChip(
                context,
                'View All Funds',
                Icons.list,
                () => context.push('/funds'),
              ),
              _buildActionChip(
                context,
                'Utilization Report',
                Icons.assessment,
                () => context.push('/reports/funds'),
              ),
              _buildActionChip(
                context,
                'Fund Tracker',
                Icons.track_changes,
                () => context.push('/funds/tracker'),
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

  Widget _buildFundCard(
    BuildContext context,
    String fundId,
    String title,
    String category,
    String allocated,
    String disbursed,
    int utilization,
    Color color,
  ) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/funds/$fundId'),
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
                    fundId,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$utilization%',
                      style: TextStyle(
                        color: color,
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
                category,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Allocated',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        allocated,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Disbursed',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        disbursed,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: utilization / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String total,
    String utilized,
    int percentage,
    IconData icon,
    Color color,
  ) {
    return Card(
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
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            total,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Utilized',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            utilized,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ],
              ),
            ),
          ],
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