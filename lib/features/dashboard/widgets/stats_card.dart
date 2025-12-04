import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/constants.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final String? subtitle;
  
  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingL),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.roseGoldPrimary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Hero(
            tag: 'stats_icon_$title',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: UIConstants.iconL,
              ),
            ),
          ),
          
          const SizedBox(height: UIConstants.paddingM),
          
          // Title
          Text(
            title,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          
          const SizedBox(height: UIConstants.paddingXS),
          
          // Value
          Text(
            value,
            style: AppTypography.h2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Subtitle (optional)
          if (subtitle != null) ...[
            const SizedBox(height: UIConstants.paddingXS),
            Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AppConstants.mediumAnimation)
        .slideY(begin: 0.1, end: 0, duration: AppConstants.mediumAnimation);
  }
}
