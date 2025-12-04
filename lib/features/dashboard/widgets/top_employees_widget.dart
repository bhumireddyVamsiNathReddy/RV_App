import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/dashboard_stats_model.dart';

class TopEmployeesWidget extends StatelessWidget {
  final List<TopEmployee> employees;
  
  const TopEmployeesWidget({
    super.key,
    required this.employees,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
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
          // Header
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppColors.accentGold,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Top Performing Employees',
                style: AppTypography.h4,
              ),
            ],
          ),
          
          const SizedBox(height: UIConstants.paddingL),
          
          // Employee cards
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: employees.length,
            separatorBuilder: (context, index) => const SizedBox(height: UIConstants.paddingM),
            itemBuilder: (context, index) {
              final employee = employees[index];
              final rank = index + 1;
              
              return Container(
                padding: const EdgeInsets.all(UIConstants.paddingM),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getGradientColors(rank),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(UIConstants.radiusM),
                ),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: AppTypography.h4.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: UIConstants.paddingM),
                    
                    // Employee info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                employee.name,
                                style: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (rank == 1) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.emoji_events,
                                  color: AppColors.white,
                                  size: 18,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.spa,
                                size: 14,
                                color: AppColors.white.withOpacity(0.9),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${employee.servicesCompleted} services',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Revenue
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(employee.revenueGenerated),
                          style: AppTypography.h5.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Revenue',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors(int rank) {
    switch (rank) {
      case 1:
        return [const Color(0xFFFFD700), const Color(0xFFFFB300)]; // Gold
      case 2:
        return [const Color(0xFFC0C0C0), const Color(0xFF9E9E9E)]; // Silver
      case 3:
        return [const Color(0xFFCD7F32), const Color(0xFFB87333)]; // Bronze
      default:
        return [AppColors.roseGoldLight, AppColors.roseGoldPrimary];
    }
  }
}
