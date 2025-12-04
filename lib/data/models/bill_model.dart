import 'service_model.dart';
import 'product_model.dart';
import 'employee_model.dart';

class BillItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String type; // 'service' or 'product'
  final Employee? employee; // For services
  
  BillItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.type,
    this.employee,
  });
  
  double get total => price * quantity;
  
  factory BillItem.fromService(Service service, int quantity, Employee? employee) {
    return BillItem(
      id: service.id,
      name: service.name,
      price: service.price,
      quantity: quantity,
      type: 'service',
      employee: employee,
    );
  }
  
  factory BillItem.fromProduct(Product product, int quantity) {
    return BillItem(
      id: product.id,
      name: product.name,
      price: product.price,
      quantity: quantity,
      type: 'product',
    );
  }
  
  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      type: json['type'] ?? 'service',
      employee: json['employee'] != null 
          ? Employee.fromJson(json['employee']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'type': type,
      'employee': employee?.toJson(),
    };
  }
}

class Bill {
  final String id;
  final String customerId;
  final String customerName;
  final String customerMobile;
  final List<BillItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final DateTime createdAt;
  final String createdBy; // User ID who created the bill
  final String status; // 'pending' or 'completed'
  final DateTime? completedAt; // When bill was completed
  final String paymentMethod; // 'Cash', 'Card', 'UPI'
  
  Bill({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerMobile,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.total,
    required this.createdAt,
    required this.createdBy,
    this.status = 'completed',
    this.completedAt,
    this.paymentMethod = 'Cash',
  });
  
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  
  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] ?? json['_id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerMobile: json['customerMobile'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => BillItem.fromJson(item))
          .toList() ?? [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      total: (json['total'] ?? json['totalAmount'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      createdBy: json['createdBy'] ?? '',
      status: json['status'] ?? 'completed',
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      paymentMethod: json['paymentMethod'] ?? 'Cash',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerMobile': customerMobile,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'status': status,
      'completedAt': completedAt?.toIso8601String(),
      'paymentMethod': paymentMethod,
    };
  }
  
  Bill copyWith({
    String? status,
    DateTime? completedAt,
    String? paymentMethod,
  }) {
    return Bill(
      id: id,
      customerId: customerId,
      customerName: customerName,
      customerMobile: customerMobile,
      items: items,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      createdAt: createdAt,
      createdBy: createdBy,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
