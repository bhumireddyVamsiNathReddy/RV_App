import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/constants.dart';

class FloatingCartBar extends StatelessWidget {
  final int itemCount;
  final double total;
  final VoidCallback onViewCart;
  final VoidCallback onGenerateBill;
  final VoidCallback onSavePending; // NEW for pending bills
  
  const FloatingCartBar({
    super.key,
    required this.itemCount,
    required this.total,
    required this.onViewCart,
    required this.onGenerateBill,
    required this.onSavePending,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    if (itemCount == 0) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.all(UIConstants.paddingM),
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        gradient: AppColors.roseGoldGradient,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.roseGoldPrimary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Item count badge
          GestureDetector(
            onTap: onViewCart,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    color: AppColors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    itemCount.toString(),
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: UIConstants.paddingM),
          
          // Total amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Amount',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  currencyFormat.format(total),
                  style: AppTypography.h4.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // NEW: Save Pending button
          OutlinedButton(
            onPressed: onSavePending,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.white,
              side: const BorderSide(color: AppColors.white, width: 1.5),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bookmark_border, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Pending',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Generate Bill button
          ElevatedButton(
            onPressed: onGenerateBill,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.roseGoldPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Complete',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 1, end: 0, duration: AppConstants.mediumAnimation)
        .fadeIn();
  }
}
