class Address {
  final String id;
  final String address;
  final String city;
  final String state;
  final String phoneNumber;
  final String type;
  final String userId;

  Address({
    required this.id,
    required this.address,
    required this.city,
    required this.state,
    required this.phoneNumber,
    required this.type,
    required this.userId,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      type: json['type'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  String get displayAddress {
    return '$address, $city, $state ($type)';
  }
}