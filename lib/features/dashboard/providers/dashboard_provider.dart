import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/dashboard_stats_model.dart';
import '../../../core/services/api_service.dart';

/// Dashboard State
class DashboardState {
  final DashboardStats? stats;
  final bool isLoading;
  final String? error;
  
  DashboardState({
    this.stats,
    this.isLoading = false,
    this.error,
  });
  
  DashboardState copyWith({
    DashboardStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Dashboard Provider - Manages dashboard data
class DashboardNotifier extends StateNotifier<DashboardState> {
  final ApiService _api;

  DashboardNotifier(this._api) : super(DashboardState()) {
    loadStats();
  }
  
  /// Load dashboard statistics
  Future<void> loadStats({DateTime? startDate, DateTime? endDate}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      String endpoint = '/dashboard/stats';
      if (startDate != null && endDate != null) {
        endpoint += '?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}';
      }
      
      final data = await _api.get(endpoint);
      final stats = DashboardStats.fromJson(data);
      
      state = DashboardState(stats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard stats: $e',
      );
    }
  }
  
  /// Update date filter
  Future<void> updateDateFilter(DateTime? startDate, DateTime? endDate) async {
    await loadStats(startDate: startDate, endDate: endDate);
  }
  
  /// Refresh stats
  Future<void> refresh() async {
    // If we have existing stats with filters, preserve them
    final currentStats = state.stats;
    await loadStats(
      startDate: currentStats?.filterStartDate,
      endDate: currentStats?.filterEndDate,
    );
  }
}

/// Global Dashboard Provider
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final api = ref.read(apiServiceProvider);
  return DashboardNotifier(api);
});
