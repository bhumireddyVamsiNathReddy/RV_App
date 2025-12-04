class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final int duration; // in minutes
  final String? imageUrl;
  final bool isActive;
  final String? category;
  
  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    this.imageUrl,
    this.isActive = true,
    this.category,
  });
  
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? 30,
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      category: json['category'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'category': category,
    };
  }
  
  Service copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? duration,
    String? imageUrl,
    bool? isActive,
    String? category,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
    );
  }
}
