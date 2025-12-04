class Customer {
  final String id;
  final String name;
  final String mobile;
  final String gender; // 'male', 'female', 'other'
  final String? email;
  final DateTime? lastVisit;
  final int totalVisits;
  final double totalSpent; // NEW: Track customer spending
  
  Customer({
    required this.id,
    required this.name,
    required this.mobile,
    required this.gender,
    this.email,
    this.lastVisit,
    this.totalVisits = 0,
    this.totalSpent = 0.0,
  });
  
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      gender: json['gender'] ?? 'other',
      email: json['email'],
      lastVisit: json['lastVisit'] != null 
          ? DateTime.parse(json['lastVisit']) 
          : null,
      totalVisits: json['totalVisits'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'gender': gender,
      'email': email,
      'lastVisit': lastVisit?.toIso8601String(),
      'totalVisits': totalVisits,
      'totalSpent': totalSpent,
    };
  }
  
  Customer copyWith({
    String? id,
    String? name,
    String? mobile,
    String? gender,
    String? email,
    DateTime? lastVisit,
    int? totalVisits,
    double? totalSpent,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      lastVisit: lastVisit ?? this.lastVisit,
      totalVisits: totalVisits ?? this.totalVisits,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
}
