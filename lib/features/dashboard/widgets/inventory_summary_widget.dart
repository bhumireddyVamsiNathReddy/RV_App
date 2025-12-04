import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/dashboard_stats_model.dart';

class InventorySummaryWidget extends StatelessWidget {
  final InventorySummary summary;
  
  const InventorySummaryWidget({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B73FF), Color(0xFF000DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B73FF).withOpacity(0.3),
            blurRadius: 12,
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
                Icons.inventory_2,
                color: AppColors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Inventory Summary',
                style: AppTypography.h4.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: UIConstants.paddingL),
          
          // Metrics grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: UIConstants.paddingM,
            mainAxisSpacing: UIConstants.paddingM,
            childAspectRatio: 2.5,
            children: [
              _buildMetricCard(
                'Total Products',
                summary.totalProducts.toString(),
                Icons.shopping_bag_outlined,
              ),
              GestureDetector(
                onTap: () {
                  if (summary.lowStockItems.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Row(
                          children: [
                            const Icon(Icons.warning_amber, color: Colors.orangeAccent),
                            const SizedBox(width: 8),
                            const Text('Low Stock Items'),
                          ],
                        ),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: summary.lowStockItems.length,
                            itemBuilder: (context, index) => ListTile(
                              leading: const Icon(Icons.circle, size: 8, color: Colors.orangeAccent),
                              title: Text(summary.lowStockItems[index]),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: _buildMetricCard(
                  'Low Stock Alert',
                  summary.lowStockCount.toString(),
                  Icons.warning_amber,
                  isAlert: summary.lowStockCount > 0,
                ),
              ),
              _buildMetricCard(
                'Products Sold',
                summary.productsSold.toString(),
                Icons.trending_up,
              ),
              _buildMetricCard(
                'Stock Value',
                currencyFormat.format(summary.stockValue),
                Icons.account_balance_wallet_outlined,
              ),
            ],
          ),
          
          const SizedBox(height: UIConstants.paddingM),
          
          // Revenue highlight
          Container(
            padding: const EdgeInsets.all(UIConstants.paddingM),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(UIConstants.radiusM),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: AppColors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Product Revenue',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  currencyFormat.format(summary.productRevenue),
                  style: AppTypography.h4.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: isAlert
            ? Border.all(color: Colors.orangeAccent, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isAlert ? Colors.orangeAccent : AppColors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.h5.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
