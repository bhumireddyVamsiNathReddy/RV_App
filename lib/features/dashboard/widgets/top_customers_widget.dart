import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/dashboard_stats_model.dart';

class TopCustomersWidget extends StatefulWidget {
  final List<TopCustomer> customers;
  
  const TopCustomersWidget({
    super.key,
    required this.customers,
  });

  @override
  State<TopCustomersWidget> createState() => _TopCustomersWidgetState();
}

class _TopCustomersWidgetState extends State<TopCustomersWidget> {
  bool sortBySpend = true; // true = by spend, false = by visits

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    // Sort customers based on toggle
    final sortedCustomers = List<TopCustomer>.from(widget.customers);
    sortedCustomers.sort((a, b) {
      if (sortBySpend) {
        return b.totalSpent.compareTo(a.totalSpent);
      } else {
        return b.totalVisits.compareTo(a.totalVisits);
      }
    });

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
          // Header with sort toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Customers',
                style: AppTypography.h4,
              ),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('By Spend'),
                    icon: Icon(Icons.currency_rupee, size: 16),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('By Visits'),
                    icon: Icon(Icons.trending_up, size: 16),
                  ),
                ],
                selected: {sortBySpend},
                onSelectionChanged: (Set<bool> selection) {
                  setState(() {
                    sortBySpend = selection.first;
                  });
                },
                style: ButtonStyle(
                  textStyle: WidgetStateProperty.all(AppTypography.labelSmall),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: UIConstants.paddingL),
          
          // Customer list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedCustomers.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final customer = sortedCustomers[index];
              final rank = index + 1;
              
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: _getRankColor(rank),
                  child: Text(
                    customer.name.substring(0, 1).toUpperCase(),
                    style: AppTypography.h5.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      customer.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (rank <= 3) ...[
                      const SizedBox(width: 8),
                      Icon(
                        rank == 1 ? Icons.emoji_events : Icons.workspace_premium,
                        size: 18,
                        color: _getRankColor(rank),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  customer.mobile,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(customer.totalSpent),
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.roseGoldPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${customer.totalVisits} visits',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
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

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.roseGoldPrimary;
    }
  }
}
