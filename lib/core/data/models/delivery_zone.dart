class DeliveryZone {
  final String? id;
  final String? name;
  final double? baseFee;

  DeliveryZone({
    this.id,
    this.name,
    this.baseFee,
  });

  factory DeliveryZone.fromJson(Map<String, dynamic> json) {
    return DeliveryZone(
      id: json['id'],
      name: json['name'],
      baseFee: (json['baseFee'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'baseFee': baseFee,
    };
  }

  @override
  String toString() => name ?? '';
}
