class Employee {
  final String id;
  final String name;
  final String? mobile;
  final String? specialty; // e.g., "Hair Stylist", "Makeup Artist"
  final bool isActive;
  
  Employee({
    required this.id,
    required this.name,
    this.mobile,
    this.specialty,
    this.isActive = true,
  });
  
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'],
      specialty: json['specialty'],
      isActive: json['isActive'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'specialty': specialty,
      'isActive': isActive,
    };
  }
  
  Employee copyWith({
    String? id,
    String? name,
    String? mobile,
    String? specialty,
    bool? isActive,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      specialty: specialty ?? this.specialty,
      isActive: isActive ?? this.isActive,
    );
  }
}
