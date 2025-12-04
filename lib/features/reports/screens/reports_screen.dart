import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/constants.dart';
import '../providers/reports_provider.dart';
import '../widgets/daily_sales_chart.dart';
import '../widgets/monthly_revenue_chart.dart';
import '../widgets/employee_performance_table.dart';
import '../widgets/customer_analytics_chart.dart';
import '../services/pdf_service.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final PdfService _pdfService = PdfService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final notifier = ref.read(reportsProvider.notifier);
    await Future.wait([
      notifier.fetchDailySales(),
      notifier.fetchMonthlyRevenue(),
      notifier.fetchEmployeePerformance(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      ),
      notifier.fetchCustomerAnalytics(),
    ]);
  }

  Future<void> _exportPdf() async {
    final state = ref.read(reportsProvider);
    if (state.dailySales == null || 
        state.monthlyRevenue == null || 
        state.employeePerformance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wait for data to load before exporting')),
      );
      return;
    }

    try {
      await _pdfService.generateAndPrintReport(
        dailySales: state.dailySales!,
        monthlyRevenue: state.monthlyRevenue!,
        employeePerformance: state.employeePerformance!,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: AppColors.roseGoldPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: _exportPdf,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('Error: ${state.error}'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(UIConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Daily Sales Section
                      Text('Daily Sales (Today)', style: AppTypography.h6),
                      const SizedBox(height: 16),
                      if (state.dailySales != null)
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total Sales', style: AppTypography.bodyLarge),
                                    Text(
                                      '₹${state.dailySales!['totalSales']}',
                                      style: AppTypography.h5.copyWith(color: AppColors.roseGoldPrimary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                DailySalesChart(
                                  hourlySales: state.dailySales!['hourlySales'],
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Monthly Revenue Section
                      Text('Monthly Revenue Trend', style: AppTypography.h6),
                      const SizedBox(height: 16),
                      if (state.monthlyRevenue != null)
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total Revenue (Year)', style: AppTypography.bodyLarge),
                                    Text(
                                      '₹${state.monthlyRevenue!['totalRevenue']}',
                                      style: AppTypography.h5.copyWith(color: AppColors.roseGoldPrimary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                MonthlyRevenueChart(
                                  monthlyRevenue: state.monthlyRevenue!['monthlyRevenue'],
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Customer Analytics Section
                      Text('Customer Growth', style: AppTypography.h6),
                      const SizedBox(height: 16),
                      if (state.customerAnalytics != null)
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(width: 12, height: 12, color: AppColors.accentGold),
                                    const SizedBox(width: 8),
                                    const Text('New'),
                                    const SizedBox(width: 16),
                                    Container(width: 12, height: 12, color: AppColors.roseGoldPrimary),
                                    const SizedBox(width: 8),
                                    const Text('Active'),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                CustomerAnalyticsChart(
                                  analytics: state.customerAnalytics!,
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Employee Performance Section
                      if (state.employeePerformance != null)
                        EmployeePerformanceTable(
                          employeePerformance: state.employeePerformance!,
                        ),
                        
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}
