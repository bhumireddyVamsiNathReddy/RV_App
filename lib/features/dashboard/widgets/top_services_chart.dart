import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/dashboard_stats_model.dart';

class TopServicesChart extends StatefulWidget {
  final List<TopService> services;
  
  const TopServicesChart({
    super.key,
    required this.services,
  });

  @override
  State<TopServicesChart> createState() => _TopServicesChartState();
}

class _TopServicesChartState extends State<TopServicesChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 5 Services',
            style: AppTypography.h4,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: widget.services.isNotEmpty
                    ? widget.services
                        .map((s) => s.count.toDouble())
                        .reduce((a, b) => a > b ? a : b) * 1.2
                    : 100,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${widget.services[groupIndex].name}\n',
                        AppTypography.labelMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '${widget.services[groupIndex].count} services',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                    });
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= widget.services.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _getShortName(widget.services[value.toInt()].name),
                            style: AppTypography.labelSmall,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.grey600,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.grey200,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.services.asMap().entries.map((entry) {
      final index = entry.key;
      final service = entry.value;
      final isTouched = index == touchedIndex;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: service.count.toDouble(),
            gradient: LinearGradient(
              colors: isTouched
                  ? [AppColors.roseGoldPrimary, AppColors.roseGoldDark]
                  : [AppColors.roseGoldLight, AppColors.roseGoldPrimary],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: isTouched ? 30 : 24,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();
  }

  String _getShortName(String name) {
    // Shorten long service names for display
    final words = name.split(' ');
    if (words.length > 2) {
      return '${words[0]}\n${words[1]}';
    }
    return name;
  }
}
