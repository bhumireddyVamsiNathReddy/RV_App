import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/constants.dart';

class DashboardFilterBar extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final VoidCallback? onClearFilters;
  final Function(DateTime?, DateTime?)? onDateRangeChanged;
  final Function(double?, double?)? onAmountRangeChanged;
  
  const DashboardFilterBar({
    super.key,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.onClearFilters,
    this.onDateRangeChanged,
    this.onAmountRangeChanged,
  });

  @override
  State<DashboardFilterBar> createState() => _DashboardFilterBarState();
}

class _DashboardFilterBarState extends State<DashboardFilterBar> {
  String selectedPeriod = 'This Month';
  
  @override
  Widget build(BuildContext context) {
    final hasFilters = widget.startDate != null || 
                       widget.endDate != null || 
                       widget.minAmount != null || 
                       widget.maxAmount != null;

    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.filter_list, size: 20),
                  const SizedBox(width: 8),
                  Text('Filters', style: AppTypography.labelLarge),
                ],
              ),
              if (hasFilters)
                TextButton.icon(
                  onPressed: widget.onClearFilters,
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: UIConstants.paddingM),
          
          // Quick period filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPeriodChip('Today', Icons.today),
                _buildPeriodChip('This Week', Icons.calendar_view_week),
                _buildPeriodChip('This Month', Icons.calendar_month),
                _buildPeriodChip('Custom', Icons.date_range),
              ],
            ),
          ),
          
          if (selectedPeriod == 'Custom') ...[
            const SizedBox(height: UIConstants.paddingM),
            
            // Custom date range
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDateRange(context),
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      widget.startDate != null && widget.endDate != null
                          ? '${DateFormat('dd MMM').format(widget.startDate!)} - ${DateFormat('dd MMM').format(widget.endDate!)}'
                          : 'Select Dates',
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, IconData icon) {
    final isSelected = selectedPeriod == label;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.white : AppColors.grey600),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              selectedPeriod = label;
            });
            _applyPeriodFilter(label);
          }
        },
        selectedColor: AppColors.roseGoldPrimary,
        labelStyle: AppTypography.labelSmall.copyWith(
          color: isSelected ? AppColors.white : AppColors.grey700,
        ),
      ),
    );
  }

  void _applyPeriodFilter(String period) {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end = now;
    
    switch (period) {
      case 'Today':
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'This Week':
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case 'This Month':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'Custom':
        // Don't auto-apply, wait for user to select
        return;
    }
    
    if (widget.onDateRangeChanged != null && period != 'Custom') {
      widget.onDateRangeChanged!(start, end);
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: widget.startDate != null && widget.endDate != null
          ? DateTimeRange(start: widget.startDate!, end: widget.endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.roseGoldPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && widget.onDateRangeChanged != null) {
      widget.onDateRangeChanged!(picked.start, picked.end);
    }
  }
}
