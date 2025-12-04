import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/bill_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';

// Billing history provider
final billingHistoryProvider = FutureProvider.autoDispose.family<List<Bill>, bool>((ref, isAdmin) async {
  final api = ref.read(apiServiceProvider);
  
  // Fetch bills from API
  final response = await api.get('/bills');
  final allBills = (response as List).map((json) => Bill.fromJson(json)).toList();
  
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  // Apply receptionist restrictions
  if (!isAdmin) {
    // Show only today's completed bills + all pending bills
    return allBills.where((bill) {
      if (bill.status == 'pending') return true; // All pending bills
      if (bill.status == 'completed') {
        // Only today's completed bills
        return bill.completedAt != null && 
               bill.completedAt!.isAfter(today);
      }
      return false;
    }).toList();
  }
  
  // Admin sees all bills
  return allBills;
});


class BillingHistoryScreen extends ConsumerStatefulWidget {
  const BillingHistoryScreen({super.key});

  @override
  ConsumerState<BillingHistoryScreen> createState() => _BillingHistoryScreenState();
}

class _BillingHistoryScreenState extends ConsumerState<BillingHistoryScreen> {
  String searchQuery = '';
  String statusFilter = 'All'; // All, Completed, Pending
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.isAdmin ?? false;
    final billsAsync = ref.watch(billingHistoryProvider(isAdmin));
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing History'),
        actions: [
          if (isAdmin)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Chip(
                label: Text('Admin View'),
                backgroundColor: AppColors.accentGold,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters
          Container(
            padding: const EdgeInsets.all(UIConstants.paddingM),
            color: AppColors.grey100,
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or mobile...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
                
                const SizedBox(height: UIConstants.paddingM),
                
                // Status filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      _buildFilterChip('Completed'),
                      _buildFilterChip('Pending'),
                    ],
                  ),
                ),
                
                // Info message for receptionist
                if (!isAdmin) ...[
                  const SizedBox(height: UIConstants.paddingS),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppColors.accentGold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Showing today\'s completed bills & all pending bills',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.grey700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Bills list
          Expanded(
            child: billsAsync.when(
              data: (bills) {
                // Apply filters
                var filteredBills = bills.where((bill) {
                  // Search filter
                  if (searchQuery.isNotEmpty) {
                    final matchName = bill.customerName.toLowerCase().contains(searchQuery);
                    final matchMobile = bill.customerMobile.contains(searchQuery);
                    if (!matchName && !matchMobile) return false;
                  }
                  
                  // Status filter
                  if (statusFilter != 'All') {
                    if (statusFilter == 'Completed' && bill.status != 'completed') return false;
                    if (statusFilter == 'Pending' && bill.status != 'pending') return false;
                  }
                  
                  return true;
                }).toList();
                
                if (filteredBills.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.grey400),
                        const SizedBox(height: 16),
                        Text('No bills found', style: AppTypography.h5.copyWith(color: AppColors.grey600)),
                      ],
                    ),
                  ).animate().fade().scale();
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(UIConstants.paddingM),
                  itemCount: filteredBills.length,
                  itemBuilder: (context, index) {
                    final bill = filteredBills[index];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: UIConstants.paddingM),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: bill.isPending 
                              ? AppColors.accentGold.withOpacity(0.2)
                              : AppColors.success.withOpacity(0.2),
                          child: Icon(
                            bill.isPending ? Icons.bookmark : Icons.check_circle,
                            color: bill.isPending ? AppColors.accentGold : AppColors.success,
                          ),
                        ),
                        title: Text(bill.customerName, style: AppTypography.bodyLarge),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bill.customerMobile),
                            Text(
                              DateFormat('dd MMM yyyy, hh:mm a').format(bill.createdAt),
                              style: AppTypography.bodySmall.copyWith(color: AppColors.grey600),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(bill.total),
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.roseGoldPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: bill.isPending 
                                    ? AppColors.accentGold.withOpacity(0.2)
                                    : AppColors.success.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                bill.status.toUpperCase(),
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: bill.isPending ? AppColors.accentGold : AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showBillDetails(context, bill),
                      ),
                    ).animate().fade(duration: 400.ms, delay: (50 * index).ms).slideX(begin: 0.2, end: 0);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Error loading bills')),
            ),
          ),
        ],
      ),
    );
  }

  void _showBillDetails(BuildContext context, Bill bill) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.receipt, color: AppColors.roseGoldPrimary),
            const SizedBox(width: 8),
            Expanded(child: Text('Bill Details', style: AppTypography.h5)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Bill ID', bill.id),
                _buildDetailRow('Date', DateFormat('dd MMM yyyy, hh:mm a').format(bill.createdAt)),
                const Divider(),
                _buildDetailRow('Customer', bill.customerName),
                _buildDetailRow('Mobile', bill.customerMobile),
                const Divider(),
                Text('Items:', style: AppTypography.labelLarge),
                const SizedBox(height: 8),
                ...bill.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}x ${item.name}',
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                      Text(
                        currencyFormat.format(item.total),
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                )),
                const Divider(),
                _buildDetailRow('Subtotal', currencyFormat.format(bill.subtotal)),
                if (bill.discount > 0)
                  _buildDetailRow('Discount', '-${currencyFormat.format(bill.discount)}', color: Colors.green),
                if (bill.tax > 0)
                  _buildDetailRow('Tax', currencyFormat.format(bill.tax)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount', style: AppTypography.h6),
                    Text(
                      currencyFormat.format(bill.total),
                      style: AppTypography.h5.copyWith(color: AppColors.roseGoldPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Payment Method', bill.paymentMethod),
                _buildDetailRow('Status', bill.status.toUpperCase(), 
                  color: bill.status == 'completed' ? AppColors.success : AppColors.accentGold),
              ],
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

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.grey600)),
          Text(
            value, 
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = statusFilter == label;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              statusFilter = label;
            });
          }
        },
        selectedColor: AppColors.roseGoldPrimary,
        labelStyle: AppTypography.labelSmall.copyWith(
          color: isSelected ? AppColors.white : AppColors.grey700,
        ),
      ),
    );
  }
}
