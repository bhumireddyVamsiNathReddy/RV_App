import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/billing_provider.dart';
import '../widgets/customer_search_bar.dart';
import '../widgets/service_selector.dart';
import '../widgets/product_grid.dart';
import '../widgets/floating_cart_bar.dart';
import '../../../data/models/customer_model.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import 'billing_history_screen.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  @override
  Widget build(BuildContext context) {
    final billingState = ref.watch(billingProvider);
    final authState = ref.watch(authProvider);
    
    final servicesAsync = ref.watch(servicesProvider);
    final productsAsync = ref.watch(productsProvider);
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Billing'),
        actions: [
          if (billingState.customer != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Chip(
                avatar: const Icon(Icons.person, size: 18),
                label: Text(
                  billingState.customer!.name,
                  style: AppTypography.labelSmall,
                ),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  ref.read(billingProvider.notifier).clearCustomer();
                },
              ),
            ),
          // NEW: Billing History button
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Billing History',
            onPressed: () {
              context.push('/billing-history');
            },
          ),
          // NEW: Pending Bills button
          IconButton(
            icon: const Icon(Icons.bookmark),
            tooltip: 'Pending Bills',
            onPressed: () {
              context.push('/pending-bills');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                // Customer Search
                CustomerSearchBar(
                  onCustomerSelected: (customer) {
                    ref.read(billingProvider.notifier).setCustomer(customer);
                  },
                  onAddNew: () {
                    _showAddCustomerDialog(context);
                  },
                ),
                
                const SizedBox(height: UIConstants.paddingM),
                
                // Services
                servicesAsync.when(
                  data: (services) {
                    return employeesAsync.when(
                      data: (employees) => ServiceSelector(
                        services: services,
                        employees: employees,
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Text('Error loading employees'),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(UIConstants.paddingL),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, __) => const Text('Error loading services'),
                ),
                
                const SizedBox(height: UIConstants.paddingL),
                
                // Products
                productsAsync.when(
                  data: (products) => ProductGrid(products: products),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(UIConstants.paddingL),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, __) => const Text('Error loading products'),
                ),
                
                const SizedBox(height: UIConstants.paddingXL),
              ],
            ),
          ),
          
          // Floating Cart Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingCartBar(
              itemCount: billingState.itemCount,
              total: billingState.total,
              onViewCart: () {
                _showCartBottomSheet(context);
              },
              onGenerateBill: () {
                _generateBill(context, authState.user?.id ?? '', isPending: false);
              },
              onSavePending: () {
                _generateBill(context, authState.user?.id ?? '', isPending: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final mobileController = TextEditingController();
    final emailController = TextEditingController();
    String selectedGender = 'other';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Customer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: UIConstants.paddingM),
                TextField(
                  controller: mobileController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile *',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: UIConstants.paddingM),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value ?? 'other';
                    });
                  },
                ),
                const SizedBox(height: UIConstants.paddingM),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    mobileController.text.isNotEmpty) {
                  // Create customer with gender
                  final customer = Customer(
                    id: 'CUST${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    mobile: mobileController.text,
                    gender: selectedGender,
                  );
                  
                  ref.read(billingProvider.notifier).setCustomer(customer);
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Customer ${customer.name} added'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    final billingState = ref.read(billingProvider);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(UIConstants.paddingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cart', style: AppTypography.h4),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(billingProvider.notifier).clearCart();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Cart items
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: billingState.cartItems.length,
                itemBuilder: (context, index) {
                  final item = billingState.cartItems[index];
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.type == 'service'
                          ? AppColors.roseGoldLight
                          : AppColors.accentGold.withOpacity(0.3),
                      child: Icon(
                        item.type == 'service' ? Icons.spa : Icons.shopping_bag,
                        color: item.type == 'service'
                            ? AppColors.roseGoldDark
                            : AppColors.accentGold,
                      ),
                    ),
                    title: Text(item.name),
                    subtitle: item.employee != null
                        ? Text('By ${item.employee!.name}')
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            ref.read(billingProvider.notifier).updateQuantity(
                              item.id,
                              item.type,
                              item.quantity - 1,
                            );
                          },
                        ),
                        Text(
                          item.quantity.toString(),
                          style: AppTypography.labelLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            ref.read(billingProvider.notifier).updateQuantity(
                              item.id,
                              item.type,
                              item.quantity + 1,
                            );
                          },
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            currencyFormat.format(item.total),
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.roseGoldPrimary,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const Divider(),
            
            // Total
            Padding(
              padding: const EdgeInsets.all(UIConstants.paddingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: AppTypography.h4),
                  Text(
                    currencyFormat.format(billingState.total),
                    style: AppTypography.h3.copyWith(
                      color: AppColors.roseGoldPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateBill(BuildContext context, String userId, {bool isPending = false}) async {
    final billingState = ref.read(billingProvider);
    
    if (billingState.customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    String paymentMethod = 'Cash';
    
    // If completing a bill, ask for payment method
    if (!isPending) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text('Select Payment Method'),
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
      
      if (result == null) return; // User cancelled
      paymentMethod = result;
    }
    
    // Generate bill (pending or completed)
    await ref.read(billingProvider.notifier).generateBill(
      userId, 
      isPending: isPending,
      paymentMethod: paymentMethod,
    );
    
    if (!mounted) return;
    
    final newState = ref.read(billingProvider);
    
    if (newState.generatedBill != null) {
      if (isPending) {
        // Show pending confirmation
        _showPendingSuccessDialog(context, newState.generatedBill!);
      } else {
        // Show completed bill dialog with WhatsApp
        _showBillSuccessDialog(context, newState.generatedBill!);
      }
      
      // Refresh Dashboard & History & Products
      ref.read(dashboardProvider.notifier).refresh();
      ref.invalidate(billingHistoryProvider);
      ref.invalidate(productsProvider);
    } else if (newState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newState.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showPendingSuccessDialog(BuildContext context, bill) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bookmark, color: AppColors.accentGold, size: 32),
            SizedBox(width: 8),
            Text('Bill Saved as Pending'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bill ID: ${bill.id}', style: AppTypography.labelMedium),
            Text('Customer: ${bill.customerName}', style: AppTypography.bodyMedium),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount:', style: AppTypography.h5),
                Text(
                  currencyFormat.format(bill.total),
                  style: AppTypography.h4.copyWith(color: AppColors.roseGoldPrimary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'You can complete this bill later from Pending Bills',
              style: AppTypography.bodySmall.copyWith(color: AppColors.grey600),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              ref.read(billingProvider.notifier).clearCart();
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bill saved! Ready for next billing'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showBillSuccessDialog(BuildContext context, bill) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 32),
            const SizedBox(width: 8),
            const Text('Bill Generated!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bill ID: ${bill.id}', style: AppTypography.labelMedium),
            Text('Customer: ${bill.customerName}', style: AppTypography.bodyMedium),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount:', style: AppTypography.h5),
                Text(
                  currencyFormat.format(bill.total),
                  style: AppTypography.h4.copyWith(color: AppColors.roseGoldPrimary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _shareViaWhatsApp(bill);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat, color: Colors.green[700]),
                const SizedBox(width: 4),
                const Text('WhatsApp'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(billingProvider.notifier).clearCart();
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ready for next billing'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareViaWhatsApp(bill) async {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    String message = '''🧾 *RV Salon - Bill*

*Bill ID:* ${bill.id}
*Customer:* ${bill.customerName}
*Date:* ${DateFormat('dd MMM yyyy, hh:mm a').format(bill.createdAt)}

*Items:*
''';
    
    for (var item in bill.items) {
      message += '\n${item.quantity}x ${item.name} - ${currencyFormat.format(item.total)}';
      if (item.employee != null) {
        message += '\n   By: ${item.employee!.name}';
      }
    }
    
    message += '\n\n*Total Amount:* ${currencyFormat.format(bill.total)}';
    message += '\n\nThank you for visiting RV Salon! 💇‍♀️✨';
    
    final url = 'whatsapp://send?phone=${bill.customerMobile}&text=${Uri.encodeComponent(message)}';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp not installed'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

