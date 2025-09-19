class Category {
  final int id;
  final String name;
  final String? description;
  final CategoryStatus status;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Constructor
  Category({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  // fromJson factory method
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: _mapStatus(json['status']),
      image: json['image'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Helper function to map status string to CategoryStatus enum
  static CategoryStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return CategoryStatus.active;
      case 'deleted':
        return CategoryStatus.deleted;
      default:
        return CategoryStatus.active;
    }
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.toString().split('.').last,
      'image': image,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}


enum CategoryStatus { active, deleted}
