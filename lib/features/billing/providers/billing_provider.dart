import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/models/bill_model.dart';
import '../../../core/services/api_service.dart';

/// Cart Item - Represents an item in the cart
class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String type; // 'service' or 'product'
  final Employee? employee; // For services only
  
  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.type,
    this.employee,
  });
  
  double get total => price * quantity;
  
  CartItem copyWith({
    int? quantity,
    Employee? employee,
  }) {
    return CartItem(
      id: id,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
      type: type,
      employee: employee ?? this.employee,
    );
  }
}

/// Billing State
class BillingState {
  final Customer? customer;
  final List<CartItem> cartItems;
  final bool isLoading;
  final String? error;
  final Bill? generatedBill;
  
  BillingState({
    this.customer,
    this.cartItems = const [],
    this.isLoading = false,
    this.error,
    this.generatedBill,
  });
  
  double get subtotal => cartItems.fold(0, (sum, item) => sum + item.total);
  double get discount => 0; // Can be added later
  double get tax => 0; // Can be added later
  double get total => subtotal - discount + tax;
  
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  BillingState copyWith({
    Customer? customer,
    List<CartItem>? cartItems,
    bool? isLoading,
    String? error,
    Bill? generatedBill,
    bool clearCustomer = false,
    bool clearError = false,
    bool clearBill = false,
  }) {
    return BillingState(
      customer: clearCustomer ? null : (customer ?? this.customer),
      cartItems: cartItems ?? this.cartItems,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      generatedBill: clearBill ? null : (generatedBill ?? this.generatedBill),
    );
  }
}

/// Billing Provider
class BillingNotifier extends StateNotifier<BillingState> {
  final ApiService _api;
  
  BillingNotifier(this._api) : super(BillingState());
  
  /// Set customer
  void setCustomer(Customer customer) {
    state = state.copyWith(customer: customer);
  }
  
  /// Clear customer
  void clearCustomer() {
    state = state.copyWith(clearCustomer: true);
  }
  
  /// Add service to cart
  void addService(Service service, Employee? employee) {
    final cartItems = List<CartItem>.from(state.cartItems);
    
    // Check if service already exists
    final index = cartItems.indexWhere(
      (item) => item.id == service.id && item.type == 'service',
    );
    
    if (index != -1) {
      // Update quantity
      cartItems[index] = cartItems[index].copyWith(
        quantity: cartItems[index].quantity + 1,
      );
    } else {
      // Add new item
      cartItems.add(CartItem(
        id: service.id,
        name: service.name,
        price: service.price,
        quantity: 1,
        type: 'service',
        employee: employee,
      ));
    }
    
    state = state.copyWith(cartItems: cartItems);
  }
  
  /// Add product to cart
  void addProduct(Product product) {
    final cartItems = List<CartItem>.from(state.cartItems);
    
    // Check if product already exists
    final index = cartItems.indexWhere(
      (item) => item.id == product.id && item.type == 'product',
    );
    
    if (index != -1) {
      // Update quantity
      cartItems[index] = cartItems[index].copyWith(
        quantity: cartItems[index].quantity + 1,
      );
    } else {
      // Add new item
      cartItems.add(CartItem(
        id: product.id,
        name: product.name,
        price: product.price,
        quantity: 1,
        type: 'product',
      ));
    }
    
    state = state.copyWith(cartItems: cartItems);
  }
  
  /// Remove item from cart
  void removeItem(String id, String type) {
    final cartItems = List<CartItem>.from(state.cartItems);
    cartItems.removeWhere((item) => item.id == id && item.type == type);
    state = state.copyWith(cartItems: cartItems);
  }
  
  /// Update item quantity
  void updateQuantity(String id, String type, int quantity) {
    if (quantity <= 0) {
      removeItem(id, type);
      return;
    }
    
    final cartItems = List<CartItem>.from(state.cartItems);
    final index = cartItems.indexWhere(
      (item) => item.id == id && item.type == type,
    );
    
    if (index != -1) {
      cartItems[index] = cartItems[index].copyWith(quantity: quantity);
      state = state.copyWith(cartItems: cartItems);
    }
  }
  
  /// Assign employee to service
  void assignEmployee(String serviceId, Employee employee) {
    final cartItems = List<CartItem>.from(state.cartItems);
    final index = cartItems.indexWhere(
      (item) => item.id == serviceId && item.type == 'service',
    );
    
    if (index != -1) {
      cartItems[index] = cartItems[index].copyWith(employee: employee);
      state = state.copyWith(cartItems: cartItems);
    }
  }
  
  /// Generate bill
  Future<void> generateBill(String userId, {bool isPending = false, String paymentMethod = 'Cash'}) async {
    if (state.customer == null) {
      state = state.copyWith(error: 'Please select a customer');
      return;
    }
    
    if (state.cartItems.isEmpty) {
      state = state.copyWith(error: 'Cart is empty');
      return;
    }
    
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      // Create bill items payload
      final billItems = state.cartItems.map((item) {
        return {
          'type': item.type,
          'id': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'employeeId': item.employee?.id,
          'employeeName': item.employee?.name,
        };
      }).toList();
      
      // Create bill payload
      final billData = {
        'customerId': state.customer!.id,
        'customerName': state.customer!.name,
        'customerMobile': state.customer!.mobile,
        'items': billItems,
        'subtotal': state.subtotal,
        'discount': state.discount,
        'tax': state.tax,
        'totalAmount': state.total,
        'status': isPending ? 'pending' : 'completed',
        'createdBy': userId,
        'paymentMethod': paymentMethod,
      };
      
      // Call API
      final response = await _api.post('/bills', billData);
      final bill = Bill.fromJson(response);
      
      state = state.copyWith(
        generatedBill: bill,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to generate bill: $e',
      );
    }
  }
  
  /// Save bill as pending
  Future<void> savePending(String userId) async {
    await generateBill(userId, isPending: true);
  }
  
  /// Complete a pending bill
  Future<void> completeBill(Bill pendingBill, {String paymentMethod = 'Cash'}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final response = await _api.put('/bills/${pendingBill.id}/complete', {
        'paymentMethod': paymentMethod,
      });
      final completedBill = Bill.fromJson(response);
      
      state = state.copyWith(
        generatedBill: completedBill,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to complete bill: $e',
      );
    }
  }

  /// Delete a bill
  Future<void> deleteBill(String billId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      await _api.delete('/bills/$billId');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete bill: $e',
      );
    }
  }
  
  /// Clear cart and reset
  void clearCart() {
    state = BillingState();
  }
}

/// Global Billing Provider
final billingProvider = StateNotifierProvider<BillingNotifier, BillingState>((ref) {
  final api = ref.read(apiServiceProvider);
  return BillingNotifier(api);
});

/// Services Provider
final servicesProvider = FutureProvider<List<Service>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final data = await api.get('/services');
  return (data as List).map((json) => Service.fromJson(json)).toList();
});

/// Products Provider
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final data = await api.get('/products');
  return (data as List).map((json) => Product.fromJson(json)).toList();
});

/// Employees Provider
final employeesProvider = FutureProvider<List<Employee>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final data = await api.get('/employees');
  return (data as List).map((json) => Employee.fromJson(json)).toList();
});
