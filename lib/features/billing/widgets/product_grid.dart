import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/product_model.dart';
import '../providers/billing_provider.dart';

class ProductGrid extends ConsumerWidget {
  final List<Product> products;
  
  const ProductGrid({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(UIConstants.paddingM),
          child: Text(
            'Products',
            style: AppTypography.h5,
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: UIConstants.paddingM),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Increased from 2 to 3
            childAspectRatio: 0.8,
            crossAxisSpacing: UIConstants.paddingM,
            mainAxisSpacing: UIConstants.paddingM,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            
            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(UIConstants.radiusM),
                border: Border.all(
                  color: AppColors.grey300,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image placeholder
                  
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(UIConstants.paddingS),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: AppTypography.labelLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${product.price.toInt()}',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.roseGoldPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // Stock indicator
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 12,
                                color: product.inStock
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.inStock
                                    ? 'Stock: ${product.stock}'
                                    : 'Out of stock',
                                style: AppTypography.bodySmall.copyWith(
                                  color: product.inStock
                                      ? AppColors.grey600
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Add button
                  Padding(
                    padding: const EdgeInsets.all(UIConstants.paddingS),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: product.inStock
                            ? () {
                                ref.read(billingProvider.notifier).addProduct(product);
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added ${product.name} to cart'),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
