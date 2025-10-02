import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/meeting_scheduler_dialog.dart';

class ComplianceHubPage extends StatefulWidget {
  const ComplianceHubPage({super.key});

  @override
  State<ComplianceHubPage> createState() => _ComplianceHubPageState();
}

class _ComplianceHubPageState extends State<ComplianceHubPage> {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compliance Overview Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user, size: 32, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PM-AJAY Compliance Hub',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Monitor regulatory compliance and audit trails',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Compliance Status Metrics
          Text(
            'Compliance Status',
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
              _buildComplianceCard(
                context,
                'Compliant',
                '142',
                Icons.check_circle,
                Colors.green,
              ),
              _buildComplianceCard(
                context,
                'Pending Review',
                '8',
                Icons.pending,
                Colors.orange,
              ),
              _buildComplianceCard(
                context,
                'Non-Compliant',
                '6',
                Icons.error,
                Colors.red,
              ),
              _buildComplianceCard(
                context,
                'Documents Due',
                '14',
                Icons.assignment_late,
                Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pending Reviews Section
          Text(
            'Pending Reviews',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            context,
            'Adarsh Gram - Sitapur District',
            'Quarterly compliance review',
            'Due: Oct 5, 2025',
            Icons.location_city,
            Colors.blue,
            true,
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            context,
            'GIA Fund Utilization - Q3',
            'Financial audit verification',
            'Due: Oct 8, 2025',
            Icons.account_balance,
            Colors.green,
            true,
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            context,
            'Hostel Infrastructure Report',
            'Safety and standards inspection',
            'Due: Oct 12, 2025',
            Icons.home,
            Colors.orange,
            false,
          ),
          const SizedBox(height: 24),

          // Regulatory Checklist
          Text(
            'Regulatory Checklist',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildChecklistCard(
            context,
            'Annual Financial Statements',
            'Submit audited statements for FY 2024-25',
            true,
          ),
          const SizedBox(height: 12),
          _buildChecklistCard(
            context,
            'Project Progress Reports',
            'Monthly progress reports for all active projects',
            true,
          ),
          const SizedBox(height: 12),
          _buildChecklistCard(
            context,
            'Beneficiary Impact Assessment',
            'Quarterly impact assessment documentation',
            false,
          ),
          const SizedBox(height: 12),
          _buildChecklistCard(
            context,
            'Vendor Compliance Certificates',
            'Updated vendor compliance certificates',
            false,
          ),
          const SizedBox(height: 24),

          // Audit Trail
          Text(
            'Recent Audit Trail',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildAuditTrailCard(
            context,
            'Fund Allocation Approved',
            'Project ID: AG-2024-156 - ₹45L approved',
            '2 hours ago',
            Icons.check_circle,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildAuditTrailCard(
            context,
            'Document Submitted',
            'Compliance report for Q3 uploaded',
            '5 hours ago',
            Icons.upload_file,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildAuditTrailCard(
            context,
            'Inspection Completed',
            'Site inspection - Adarsh Gram Sitapur',
            '1 day ago',
            Icons.assignment_turned_in,
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
                'Submit Document',
                Icons.upload_file,
                () => context.push('/compliance/submit'),
              ),
              _buildActionChip(
                context,
                'View Audit Log',
                Icons.history,
                () => context.push('/compliance/audit'),
              ),
              _buildActionChip(
                context,
                'Generate Report',
                Icons.description,
                () => context.push('/reports'),
              ),
              _buildActionChip(
                context,
                'Schedule Review',
                Icons.schedule,
                () async {
                  final result = await showDialog(
                    context: context,
                    builder: (context) => const MeetingSchedulerDialog(),
                  );
                  if (result != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Meeting scheduled: ${result['date']} at ${result['time']}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceCard(
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

  Widget _buildReviewCard(
    BuildContext context,
    String title,
    String description,
    String dueDate,
    IconData icon,
    Color color,
    bool isUrgent,
  ) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/compliance/review'),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (isUrgent)
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
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dueDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isUrgent ? Colors.red : Colors.grey[600],
                            fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildChecklistCard(
    BuildContext context,
    String title,
    String description,
    bool isCompleted,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? Colors.green : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? Colors.grey : null,
                        ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAuditTrailCard(
    BuildContext context,
    String title,
    String description,
    String timestamp,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
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