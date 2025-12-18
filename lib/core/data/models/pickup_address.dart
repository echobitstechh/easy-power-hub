class PickupAddress {
  final String? id;
  final String? address;
  final String? city;
  final String? state;
  final String? phoneNumber;
  final String? type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PickupAddress({
    this.id,
    this.address,
    this.city,
    this.state,
    this.phoneNumber,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory PickupAddress.fromJson(Map<String, dynamic> json) {
    return PickupAddress(
      id: json['id'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      phoneNumber: json['phoneNumber'],
      type: json['type'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'city': city,
      'state': state,
      'phoneNumber': phoneNumber,
      'type': type,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '$address, $city, $state';
  }
}
