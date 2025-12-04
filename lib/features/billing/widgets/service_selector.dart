import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/employee_model.dart';
import '../providers/billing_provider.dart';

class ServiceSelector extends ConsumerStatefulWidget {
  final List<Service> services;
  final List<Employee> employees;
  
  const ServiceSelector({
    super.key,
    required this.services,
    required this.employees,
  });

  @override
  ConsumerState<ServiceSelector> createState() => _ServiceSelectorState();
}

class _ServiceSelectorState extends ConsumerState<ServiceSelector> {
  String? selectedServiceId;
  Employee? selectedEmployee;
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(UIConstants.paddingM),
          child: Text(
            'Services',
            style: AppTypography.h5,
          ),
        ),
        
        // Horizontal service chips (NO PRICE SHOWN)
        SizedBox(
          height: 80, // Reduced from 100
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: UIConstants.paddingM),
            scrollDirection: Axis.horizontal,
            itemCount: widget.services.length,
            itemBuilder: (context, index) {
              final service = widget.services[index];
              final isSelected = selectedServiceId == service.id;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedServiceId = isSelected ? null : service.id;
                    selectedEmployee = null;
                    _priceController.clear();
                  });
                },
                child: Container(
                  width: 130, // Reduced from 160
                  margin: const EdgeInsets.only(right: UIConstants.paddingM),
                  padding: const EdgeInsets.all(UIConstants.paddingS), // Reduced padding
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? AppColors.roseGoldGradient
                        : null,
                    color: isSelected ? null : AppColors.grey100,
                    borderRadius: BorderRadius.circular(UIConstants.radiusM),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.roseGoldPrimary
                          : AppColors.grey300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        service.name,
                        style: AppTypography.labelLarge.copyWith(
                          color: isSelected ? AppColors.white : AppColors.grey900,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // REMOVED PRICE - Only show duration
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Employee selector and MANUAL PRICE INPUT (shows when service is selected)
        if (selectedServiceId != null) ...[
          const SizedBox(height: UIConstants.paddingM),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: UIConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Manual Price Input  
                Text(
                  'Enter Price',
                  style: AppTypography.labelMedium,
                ),
                const SizedBox(height: UIConstants.paddingS),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter amount (₹)',
                    prefixIcon: const Icon(Icons.currency_rupee),
                    filled: true,
                    fillColor: AppColors.grey100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  autofocus: true,
                ),
                
                const SizedBox(height: UIConstants.paddingM),
                
                // Employee Selector
                Text(
                  'Assign Employee',
                  style: AppTypography.labelMedium,
                ),
                const SizedBox(height: UIConstants.paddingS),
                DropdownButtonFormField<Employee>(
                  value: selectedEmployee,
                  decoration: InputDecoration(
                    hintText: 'Select employee',
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: AppColors.grey100,
                  ),
                  items: widget.employees.map((employee) {
                    return DropdownMenuItem(
                      value: employee,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            employee.name,
                            style: AppTypography.bodyMedium,
                          ),
                          if (employee.specialty != null)
                            Text(
                              employee.specialty!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.grey600,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (employee) {
                    setState(() {
                      selectedEmployee = employee;
                    });
                  },
                ),
                const SizedBox(height: UIConstants.paddingM),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: selectedEmployee != null && _priceController.text.isNotEmpty
                        ? () {
                            final service = widget.services.firstWhere(
                              (s) => s.id == selectedServiceId,
                            );
                            
                            // Use manual price instead of service.price
                            final manualPrice = double.tryParse(_priceController.text) ?? 0;
                            
                            if (manualPrice <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid price'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }
                            
                            // Create service with manual price
                            final serviceWithManualPrice = Service(
                              id: service.id,
                              name: service.name,
                              description: service.description,
                              price: manualPrice, // MANUAL PRICE HERE
                              duration: service.duration,
                            );
                            
                            ref.read(billingProvider.notifier).addService(
                              serviceWithManualPrice,
                              selectedEmployee,
                            );
                            
                            // Reset selection
                            setState(() {
                              selectedServiceId = null;
                              selectedEmployee = null;
                              _priceController.clear();
                            });
                            
                            // Show snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added ${service.name} (₹$manualPrice) to cart'),
                                duration: const Duration(seconds: 1),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
