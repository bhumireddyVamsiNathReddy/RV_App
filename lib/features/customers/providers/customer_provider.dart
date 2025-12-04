import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/customer_model.dart';
import '../../../core/services/api_service.dart';

class CustomerState {
  final List<Customer> searchResults;
  final bool isLoading;
  final String? error;

  CustomerState({
    this.searchResults = const [],
    this.isLoading = false,
    this.error,
  });

  CustomerState copyWith({
    List<Customer>? searchResults,
    bool? isLoading,
    String? error,
  }) {
    return CustomerState(
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CustomerNotifier extends StateNotifier<CustomerState> {
  final ApiService _api;

  CustomerNotifier(this._api) : super(CustomerState());

  Future<void> searchCustomers(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.get('/customers?search=$query');
      final List<Customer> customers = (response as List)
          .map((json) => Customer.fromJson(json))
          .toList();
      
      state = state.copyWith(
        searchResults: customers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to search customers: $e',
      );
    }
  }

  Future<Customer?> addCustomer(Map<String, dynamic> customerData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.post('/customers', customerData);
      final newCustomer = Customer.fromJson(response);
      
      state = state.copyWith(isLoading: false);
      return newCustomer;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add customer: $e',
      );
      return null;
    }
  }
  
  void clearSearch() {
    state = state.copyWith(searchResults: []);
  }
}

final customerProvider = StateNotifierProvider<CustomerNotifier, CustomerState>((ref) {
  final api = ref.read(apiServiceProvider);
  return CustomerNotifier(api);
});
