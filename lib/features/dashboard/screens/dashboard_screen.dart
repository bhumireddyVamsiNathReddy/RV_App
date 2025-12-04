import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/top_services_chart.dart';
import '../widgets/revenue_breakdown_chart.dart';
import '../widgets/top_customers_widget.dart';
import '../widgets/top_employees_widget.dart';
import '../widgets/inventory_summary_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final authState = ref.watch(authProvider);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        color: AppColors.roseGoldPrimary,
        child: CustomScrollView(
          slivers: [
            // Collapsing Header
            SliverAppBar(
              expandedHeight: 150,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.roseGoldPrimary,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Dashboard',
                  style: AppTypography.h4.copyWith(color: AppColors.white),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.roseGoldLight,
                        AppColors.roseGoldPrimary,
                        AppColors.roseGoldDark,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(UIConstants.paddingL),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.white.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              authState.user?.name ?? 'Admin',
                              style: AppTypography.h3.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: AppColors.white),
                  tooltip: 'Filter Date',
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.roseGoldPrimary,
                              onPrimary: Colors.white,
                              onSurface: AppColors.grey900,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    
                    if (picked != null) {
                      ref.read(dashboardProvider.notifier).updateDateFilter(
                        picked.start,
                        picked.end,
                      );
                    }
                  },
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.settings, color: AppColors.white),
                  tooltip: 'Manage',
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'services',
                      child: Row(
                        children: [
                          Icon(Icons.spa, size: 20),
                          SizedBox(width: 12),
                          Text('Manage Services'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'products',
                      child: Row(
                        children: [
                          Icon(Icons.shopping_bag, size: 20),
                          SizedBox(width: 12),
                          Text('Manage Products'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'employees',
                      child: Row(
                        children: [
                          Icon(Icons.people, size: 20),
                          SizedBox(width: 12),
                          Text('Manage Employees'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'services') {
                      context.push('/manage-services');
                    } else if (value == 'products') {
                      context.push('/manage-products');
                    } else if (value == 'employees') {
                      context.push('/manage-employees');
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.white),
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ],
            ),

            // Content
            if (dashboardState.isLoading)
              SliverFillRemaining(
                child: _buildLoadingSkeleton(),
              )
            else if (dashboardState.error != null)
              SliverFillRemaining(
                child: _buildErrorState(dashboardState.error!, ref),
              )
            else if (dashboardState.stats != null)
              SliverPadding(
                padding: const EdgeInsets.all(UIConstants.paddingM),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stats Cards Grid
                    AnimationLimiter(
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: UIConstants.paddingM,
                        mainAxisSpacing: UIConstants.paddingM,
                        childAspectRatio: 1.2,
                        children: AnimationConfiguration.toStaggeredList(
                          duration: AppConstants.mediumAnimation,
                          childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(child: widget),
                          ),
                          children: [
                            StatsCard(
                              title: 'Today\'s Earnings',
                              value: currencyFormat.format(
                                dashboardState.stats!.todayEarnings,
                              ),
                              icon: Icons.currency_rupee,
                              gradient: AppColors.roseGoldGradient,
                            ),
                            StatsCard(
                              title: 'Month Earnings',
                              value: currencyFormat.format(
                                dashboardState.stats!.monthEarnings,
                              ),
                              icon: Icons.trending_up,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            StatsCard(
                              title: 'Total Customers',
                              value: dashboardState.stats!.totalCustomers.toString(),
                              icon: Icons.people,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF64B5F6), Color(0xFF2196F3)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            StatsCard(
                              title: 'Services Today',
                              value: dashboardState.stats!.servicesCompleted.toString(),
                              icon: Icons.spa,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              subtitle: 'Top: ${dashboardState.stats!.topStylist}',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: UIConstants.paddingL),

                    // Top Services Chart
                    TopServicesChart(
                      services: dashboardState.stats!.topServices,
                    ),

                    const SizedBox(height: UIConstants.paddingL),

                    // Revenue Breakdown Chart
                    RevenueBreakdownChart(
                      breakdown: dashboardState.stats!.revenueBreakdown,
                    ),

                    const SizedBox(height: UIConstants.paddingL),

                    // Top Customers Widget (NEW v2.0)
                    TopCustomersWidget(
                      customers: dashboardState.stats!.topCustomers,
                    ),

                    const SizedBox(height: UIConstants.paddingL),

                    // Top Employees Widget (NEW v2.0)
                    TopEmployeesWidget(
                      employees: dashboardState.stats!.topEmployees,
                    ),

                    const SizedBox(height: UIConstants.paddingL),

                    // Inventory Summary Widget (NEW v2.0)
                    InventorySummaryWidget(
                      summary: dashboardState.stats!.inventorySummary,
                    ),

                    const SizedBox(height: UIConstants.paddingXL),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingM),
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: UIConstants.paddingM,
              mainAxisSpacing: UIConstants.paddingM,
              childAspectRatio: 1.2,
              children: List.generate(
                4,
                (index) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(UIConstants.radiusL),
                  ),
                ),
              ),
            ),
            const SizedBox(height: UIConstants.paddingL),
            Container(
              height: 350,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(UIConstants.radiusL),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: UIConstants.paddingM),
            Text(
              'Oops! Something went wrong',
              style: AppTypography.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.paddingS),
            Text(
              error,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.paddingL),
            ElevatedButton.icon(
              onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

