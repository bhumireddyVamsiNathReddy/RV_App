import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/dashboard_stats_model.dart';

class RevenueBreakdownChart extends StatefulWidget {
  final RevenueBreakdown breakdown;
  
  const RevenueBreakdownChart({
    super.key,
    required this.breakdown,
  });

  @override
  State<RevenueBreakdownChart> createState() => _RevenueBreakdownChartState();
}

class _RevenueBreakdownChartState extends State<RevenueBreakdownChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
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
            'Revenue Breakdown',
            style: AppTypography.h4,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Pie Chart
              Expanded(
                flex: 2,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex =
                                pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: _buildSections(),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 24),
              
              // Legend
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(
                      'Services',
                      AppColors.roseGoldPrimary,
                      currencyFormat.format(widget.breakdown.servicesRevenue),
                      '${widget.breakdown.servicesPercentage.toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 16),
                    _buildLegendItem(
                      'Products',
                      AppColors.accentGold,
                      currencyFormat.format(widget.breakdown.productsRevenue),
                      '${widget.breakdown.productsPercentage.toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      'Total',
                      AppColors.grey700,
                      currencyFormat.format(widget.breakdown.total),
                      '100%',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return [
      PieChartSectionData(
        color: AppColors.roseGoldPrimary,
        value: widget.breakdown.servicesRevenue,
        title: touchedIndex == 0
            ? '${widget.breakdown.servicesPercentage.toStringAsFixed(1)}%'
            : '',
        radius: touchedIndex == 0 ? 70 : 60,
        titleStyle: AppTypography.labelLarge.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: AppColors.accentGold,
        value: widget.breakdown.productsRevenue,
        title: touchedIndex == 1
            ? '${widget.breakdown.productsPercentage.toStringAsFixed(1)}%'
            : '',
        radius: touchedIndex == 1 ? 70 : 60,
        titleStyle: AppTypography.labelLarge.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }

  Widget _buildLegendItem(
    String label,
    Color color,
    String amount,
    String percentage, {
    bool isTotal = false,
  }) {
    return Row(
      children: [
        if (!isTotal)
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        if (!isTotal) const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: isTotal
                    ? AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      )
                    : AppTypography.labelMedium,
              ),
              Text(
                amount,
                style: isTotal
                    ? AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.roseGoldPrimary,
                      )
                    : AppTypography.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
              ),
            ],
          ),
        ),
        Text(
          percentage,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }
}
