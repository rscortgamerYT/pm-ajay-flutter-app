import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget displaying a pie chart of projects by status
class ProjectStatusChart extends StatelessWidget {
  final Map<String, int> projectsByStatus;

  const ProjectStatusChart({
    super.key,
    required this.projectsByStatus,
  });

  @override
  Widget build(BuildContext context) {
    final sections = _buildPieChartSections();
    
    if (sections.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        Expanded(
          child: _buildLegend(context),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = projectsByStatus.values.fold<int>(0, (sum, count) => sum + count);
    if (total == 0) return [];

    return projectsByStatus.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        color: _getStatusColorFromString(entry.key),
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: projectsByStatus.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getStatusColorFromString(entry.key),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColorFromString(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return Colors.blue;
      case 'approved':
        return Colors.lightBlue;
      case 'inprogress':
      case 'in progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'suspended':
        return Colors.grey;
      case 'delayed':
        return Colors.red;
      case 'cancelled':
        return Colors.black;
      default:
        return Colors.blueGrey;
    }
  }
}