import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

class ReportsState {
  final Map<String, dynamic>? dailySales;
  final Map<String, dynamic>? monthlyRevenue;
  final List<dynamic>? employeePerformance;
  final List<dynamic>? customerAnalytics;
  final bool isLoading;
  final String? error;

  ReportsState({
    this.dailySales,
    this.monthlyRevenue,
    this.employeePerformance,
    this.customerAnalytics,
    this.isLoading = false,
    this.error,
  });

  ReportsState copyWith({
    Map<String, dynamic>? dailySales,
    Map<String, dynamic>? monthlyRevenue,
    List<dynamic>? employeePerformance,
    List<dynamic>? customerAnalytics,
    bool? isLoading,
    String? error,
  }) {
    return ReportsState(
      dailySales: dailySales ?? this.dailySales,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      employeePerformance: employeePerformance ?? this.employeePerformance,
      customerAnalytics: customerAnalytics ?? this.customerAnalytics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ReportsNotifier extends StateNotifier<ReportsState> {
  final ApiService _api;

  ReportsNotifier(this._api) : super(ReportsState());

  Future<void> fetchDailySales([DateTime? date]) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dateStr = (date ?? DateTime.now()).toIso8601String();
      final data = await _api.get('/reports/daily-sales?date=$dateStr');
      state = state.copyWith(dailySales: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchMonthlyRevenue([int? year]) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final yearStr = (year ?? DateTime.now().year).toString();
      final data = await _api.get('/reports/monthly-revenue?year=$yearStr');
      state = state.copyWith(monthlyRevenue: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchEmployeePerformance({DateTime? startDate, DateTime? endDate}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      String query = '';
      if (startDate != null && endDate != null) {
        query = '?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}';
      }
      
      final data = await _api.get('/reports/employee-performance$query');
      state = state.copyWith(employeePerformance: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchCustomerAnalytics([int months = 6]) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.get('/reports/customer-analytics?months=$months');
      state = state.copyWith(customerAnalytics: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final reportsProvider = StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  final api = ref.read(apiServiceProvider);
  return ReportsNotifier(api);
});
