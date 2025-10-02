import 'package:flutter/material.dart';
import '../../models/report_model.dart';

/// Widget displaying a list of recent project trends
class RecentTrendsList extends StatelessWidget {
  final List<ProjectTrend> trends;

  const RecentTrendsList({
    super.key,
    required this.trends,
  });

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'No trends available',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: trends.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final trend = trends[index];
          final trendType = _determineTrendType(trend);
          final trendDirection = _determineTrendDirection(trend);
          
          return ListTile(
            leading: _getTrendIcon(trendType),
            title: Text(
              trend.projectName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(_getTrendDescription(trend)),
            trailing: _getTrendIndicator(trendDirection),
          );
        },
      ),
    );
  }

  String _determineTrendType(ProjectTrend trend) {
    if (trend.budgetChange.abs() > trend.completionChange.abs()) {
      return 'budget';
    } else if (trend.completionChange != 0) {
      return 'completion';
    }
    return 'general';
  }

  String _determineTrendDirection(ProjectTrend trend) {
    final totalChange = trend.completionChange + trend.budgetChange;
    if (totalChange > 5) return 'up';
    if (totalChange < -5) return 'down';
    return 'stable';
  }

  String _getTrendDescription(ProjectTrend trend) {
    final parts = <String>[];
    
    if (trend.completionChange != 0) {
      parts.add('Completion ${trend.completionChange > 0 ? "increased" : "decreased"} by ${trend.completionChange.abs().toStringAsFixed(1)}%');
    }
    
    if (trend.budgetChange != 0) {
      parts.add('Budget ${trend.budgetChange > 0 ? "increased" : "decreased"} by ${trend.budgetChange.abs().toStringAsFixed(1)}%');
    }
    
    if (parts.isEmpty) {
      return 'No significant changes';
    }
    
    return parts.join(' • ');
  }

  Widget _getTrendIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case 'budget':
        icon = Icons.attach_money;
        color = Colors.green;
        break;
      case 'completion':
        icon = Icons.check_circle_outline;
        color = Colors.blue;
        break;
      case 'delay':
        icon = Icons.warning_amber_outlined;
        color = Colors.orange;
        break;
      case 'agency':
        icon = Icons.business_outlined;
        color = Colors.purple;
        break;
      case 'citizen':
        icon = Icons.people_outline;
        color = Colors.teal;
        break;
      default:
        icon = Icons.trending_up;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _getTrendIndicator(String trend) {
    IconData icon;
    Color color;
    String label;

    switch (trend.toLowerCase()) {
      case 'up':
      case 'increasing':
      case 'positive':
        icon = Icons.trending_up;
        color = Colors.green;
        label = 'Up';
        break;
      case 'down':
      case 'decreasing':
      case 'negative':
        icon = Icons.trending_down;
        color = Colors.red;
        label = 'Down';
        break;
      case 'stable':
      case 'neutral':
        icon = Icons.trending_flat;
        color = Colors.grey;
        label = 'Stable';
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
        label = 'Unknown';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}