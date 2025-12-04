import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/bill_model.dart';
import '../../../core/services/api_service.dart';
import '../providers/billing_provider.dart';

// Pending Bills Provider
final pendingBillsProvider = FutureProvider<List<Bill>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final data = await api.get('/bills?status=pending');
  return (data as List).map((json) => Bill.fromJson(json)).toList();
});

class PendingBillsScreen extends ConsumerWidget {
  const PendingBillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingBillsAsync = ref.watch(pendingBillsProvider);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Bills'),
        backgroundColor: AppColors.accentGold,
      ),
      body: pendingBillsAsync.when(
        data: (bills) {
          if (bills.isEmpty) {
            return _buildEmptyState();
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(pendingBillsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(UIConstants.paddingM),
              itemCount: bills.length,
              itemBuilder: (context, index) {
                final bill = bills[index];
                final daysAgo = DateTime.now().difference(bill.createdAt).inDays;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: UIConstants.paddingM),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UIConstants.radiusM),
                    side: BorderSide(
                      color: AppColors.accentGold.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _showBillDetailsDialog(context, bill),
                    borderRadius: BorderRadius.circular(UIConstants.radiusM),
                    child: Padding(
                      padding: const EdgeInsets.all(UIConstants.paddingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Bill ID badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.bookmark,
                                      size: 14,
                                      color: AppColors.accentGold,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      bill.id.substring(0, 8), // Shorten ID for display
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.accentGold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Days ago indicator
                              if (daysAgo > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: daysAgo > 2 
                                        ? AppColors.error.withOpacity(0.1)
                                        : AppColors.grey200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$daysAgo day${daysAgo > 1 ? 's' : ''} ago',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: daysAgo > 2 
                                          ? AppColors.error 
                                          : AppColors.grey600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          
                          const SizedBox(height: UIConstants.paddingM),
                          
                          // Customer info
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.roseGoldLight,
                                child: Text(
                                  bill.customerName.isNotEmpty ? bill.customerName.substring(0, 1).toUpperCase() : '?',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.roseGoldDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bill.customerName,
                                      style: AppTypography.bodyLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      bill.customerMobile,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.grey600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: UIConstants.paddingM),
                          
                          // Amount and date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Amount',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(bill.total),
                                    style: AppTypography.h5.copyWith(
                                      color: AppColors.roseGoldPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Created',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd MMM, hh:mm a').format(bill.createdAt),
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: UIConstants.paddingM),
                          const Divider(height: 1),
                          const SizedBox(height: UIConstants.paddingS),
                          
                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _completeBill(context, ref, bill),
                                  icon: const Icon(Icons.check_circle, size: 18),
                                  label: const Text('Complete'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.success,
                                    side: const BorderSide(color: AppColors.success),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => _deleteBill(context, ref, bill),
                                icon: const Icon(Icons.delete_outline),
                                color: AppColors.error,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error loading pending bills', style: AppTypography.bodyLarge),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(pendingBillsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist,
            size: 80,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Pending Bills',
            style: AppTypography.h4.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All bills are completed!',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  void _showBillDetailsDialog(BuildContext context, Bill bill) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: AppColors.roseGoldPrimary),
            const SizedBox(width: 8),
            Text('Bill Details', style: AppTypography.h5),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Bill ID:', bill.id),
            _buildDetailRow('Customer:', bill.customerName),
            _buildDetailRow('Mobile:', bill.customerMobile),
            _buildDetailRow('Amount:', currencyFormat.format(bill.total)),
            _buildDetailRow('Created:', DateFormat('dd MMM yyyy, hh:mm a').format(bill.createdAt)),
            _buildDetailRow('Status:', 'Pending', statusColor: AppColors.accentGold),
          ],
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

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.grey600,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  void _completeBill(BuildContext context, WidgetRef ref, Bill bill) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Complete Bill - Payment Method'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Cash'),
            child: const Row(
              children: [
                Icon(Icons.money, color: Colors.green),
                SizedBox(width: 12),
                Text('Cash'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Card'),
            child: const Row(
              children: [
                Icon(Icons.credit_card, color: Colors.blue),
                SizedBox(width: 12),
                Text('Card'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'UPI'),
            child: const Row(
              children: [
                Icon(Icons.qr_code, color: Colors.purple),
                SizedBox(width: 12),
                Text('UPI'),
              ],
            ),
          ),
        ],
      ),
    );

    if (result == null) return;

    try {
      await ref.read(billingProvider.notifier).completeBill(bill, paymentMethod: result);
      ref.invalidate(pendingBillsProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bill ${bill.id.substring(0, 8)} completed with $result!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _deleteBill(BuildContext context, WidgetRef ref, Bill bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pending Bill?'),
        content: Text('Delete bill for ${bill.customerName}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await ref.read(billingProvider.notifier).deleteBill(bill.id);
                ref.invalidate(pendingBillsProvider);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bill ${bill.id.substring(0, 8)} deleted'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
