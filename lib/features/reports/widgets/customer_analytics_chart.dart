import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class CustomerAnalyticsChart extends StatelessWidget {
  final List<dynamic> analytics;

  const CustomerAnalyticsChart({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (analytics.fold<int>(0, (max, item) {
            final val = (item['newCustomers'] as int) > (item['activeCustomers'] as int) 
                ? item['newCustomers'] 
                : item['activeCustomers'];
            return val > max ? val : max;
          })).toDouble() * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.grey800,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String label = rodIndex == 0 ? 'New' : 'Active';
                return BarTooltipItem(
                  '$label: ${rod.toY.toInt()}',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < analytics.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        analytics[value.toInt()]['month'],
                        style: const TextStyle(
                          color: AppColors.grey600,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: analytics.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (data['newCustomers'] as int).toDouble(),
                  color: AppColors.accentGold,
                  width: 12,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: (data['activeCustomers'] as int).toDouble(),
                  color: AppColors.roseGoldPrimary,
                  width: 12,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }
}
