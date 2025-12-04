import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class MonthlyRevenueChart extends StatelessWidget {
  final List<dynamic> monthlyRevenue;

  const MonthlyRevenueChart({super.key, required this.monthlyRevenue});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 10000,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.grey300,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    color: AppColors.grey600,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  );
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = 'JAN';
                      break;
                    case 3:
                      text = 'APR';
                      break;
                    case 6:
                      text = 'JUL';
                      break;
                    case 9:
                      text = 'OCT';
                      break;
                    default:
                      return Container();
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(text, style: style),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10000,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value ~/ 1000}k',
                    style: const TextStyle(
                      color: AppColors.grey600,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d)),
          ),
          minX: 0,
          maxX: 11,
          minY: 0,
          maxY: (monthlyRevenue.reduce((curr, next) => curr > next ? curr : next) as num).toDouble() * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: monthlyRevenue.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), (entry.value as num).toDouble());
              }).toList(),
              isCurved: true,
              gradient: const LinearGradient(
                colors: [
                  AppColors.roseGoldPrimary,
                  AppColors.accentGold,
                ],
              ),
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.roseGoldPrimary.withOpacity(0.3),
                    AppColors.accentGold.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
