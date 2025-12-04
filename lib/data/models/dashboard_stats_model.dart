class TopCustomer {
  final String customerId;
  final String name;
  final String mobile;
  final int totalVisits;
  final double totalSpent;
  
  TopCustomer({
    required this.customerId,
    required this.name,
    required this.mobile,
    required this.totalVisits,
    required this.totalSpent,
  });
  
  factory TopCustomer.fromJson(Map<String, dynamic> json) {
    return TopCustomer(
      customerId: json['customerId'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      totalVisits: json['totalVisits'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
    );
  }
}

class TopEmployee {
  final String employeeId;
  final String name;
  final int servicesCompleted;
  final double revenueGenerated;
  
  TopEmployee({
    required this.employeeId,
    required this.name,
    required this.servicesCompleted,
    required this.revenueGenerated,
  });
  
  factory TopEmployee.fromJson(Map<String, dynamic> json) {
    return TopEmployee(
      employeeId: json['employeeId'] ?? '',
      name: json['name'] ?? '',
      servicesCompleted: json['servicesCompleted'] ?? 0,
      revenueGenerated: (json['revenueGenerated'] ?? 0).toDouble(),
    );
  }
}

class InventorySummary {
  final int totalProducts;
  final int lowStockCount;
  final double stockValue;
  final double productRevenue;
  final int productsSold;
  final List<String> lowStockItems;
  
  InventorySummary({
    required this.totalProducts,
    required this.lowStockCount,
    required this.stockValue,
    required this.productRevenue,
    required this.productsSold,
    this.lowStockItems = const [],
  });
  
  factory InventorySummary.fromJson(Map<String, dynamic> json) {
    return InventorySummary(
      totalProducts: json['totalProducts'] ?? 0,
      lowStockCount: json['lowStockCount'] ?? 0,
      stockValue: (json['stockValue'] ?? 0).toDouble(),
      productRevenue: (json['productRevenue'] ?? 0).toDouble(),
      productsSold: json['productsSold'] ?? 0,
      lowStockItems: (json['lowStockItems'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}

class DashboardStats {
  final double todayEarnings;
  final double monthEarnings;
  final int totalCustomers;
  final int servicesCompleted;
  final String topStylist;
  final List<TopService> topServices;
  final RevenueBreakdown revenueBreakdown;
  
  // NEW v2.0 fields
  final List<TopCustomer> topCustomers;
  final List<TopEmployee> topEmployees;
  final InventorySummary inventorySummary;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  
  DashboardStats({
    required this.todayEarnings,
    required this.monthEarnings,
    required this.totalCustomers,
    required this.servicesCompleted,
    required this.topStylist,
    required this.topServices,
    required this.revenueBreakdown,
    this.topCustomers = const [],
    this.topEmployees = const [],
    InventorySummary? inventorySummary,
    this.filterStartDate,
    this.filterEndDate,
  }) : inventorySummary = inventorySummary ?? InventorySummary(
    totalProducts: 0,
    lowStockCount: 0,
    stockValue: 0,
    productRevenue: 0,
    productsSold: 0,
  );
  
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      todayEarnings: (json['todayEarnings'] ?? 0).toDouble(),
      monthEarnings: (json['monthEarnings'] ?? 0).toDouble(),
      totalCustomers: json['totalCustomers'] ?? 0,
      servicesCompleted: json['servicesCompleted'] ?? 0,
      topStylist: json['topStylist'] ?? 'N/A',
      topServices: (json['topServices'] as List<dynamic>?)
          ?.map((item) => TopService.fromJson(item))
          .toList() ?? [],
      revenueBreakdown: RevenueBreakdown.fromJson(
        json['revenueBreakdown'] ?? {},
      ),
      topCustomers: (json['topCustomers'] as List<dynamic>?)
          ?.map((item) => TopCustomer.fromJson(item))
          .toList() ?? [],
      topEmployees: (json['topEmployees'] as List<dynamic>?)
          ?.map((item) => TopEmployee.fromJson(item))
          .toList() ?? [],
      inventorySummary: json['inventorySummary'] != null
          ? InventorySummary.fromJson(json['inventorySummary'])
          : null,
      filterStartDate: json['filterStartDate'] != null
          ? DateTime.parse(json['filterStartDate'])
          : null,
      filterEndDate: json['filterEndDate'] != null
          ? DateTime.parse(json['filterEndDate'])
          : null,
    );
  }
}

class TopService {
  final String name;
  final int count;
  final double revenue;
  
  TopService({
    required this.name,
    required this.count,
    required this.revenue,
  });
  
  factory TopService.fromJson(Map<String, dynamic> json) {
    return TopService(
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

class RevenueBreakdown {
  final double servicesRevenue;
  final double productsRevenue;
  
  RevenueBreakdown({
    required this.servicesRevenue,
    required this.productsRevenue,
  });
  
  double get total => servicesRevenue + productsRevenue;
  double get servicesPercentage => 
      total > 0 ? (servicesRevenue / total) * 100 : 0;
  double get productsPercentage => 
      total > 0 ? (productsRevenue / total) * 100 : 0;
  
  factory RevenueBreakdown.fromJson(Map<String, dynamic> json) {
    return RevenueBreakdown(
      servicesRevenue: (json['servicesRevenue'] ?? 0).toDouble(),
      productsRevenue: (json['productsRevenue'] ?? 0).toDouble(),
    );
  }
}
