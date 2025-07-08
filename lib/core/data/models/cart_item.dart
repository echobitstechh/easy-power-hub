import 'package:easyph/core/data/models/product.dart';

class CartItem {
  String? id;
  int? quantity;
  double? price;
  double? installmentTotalPrice;
  bool? isInstallment;
  int? installmentFrequency;
  DateTime? createdAt;
  DateTime? updatedAt;
  Product? product;

  CartItem({
    this.id,
    this.quantity,
    this.price,
    this.installmentTotalPrice,
    this.isInstallment,
    this.installmentFrequency,
    this.createdAt,
    this.updatedAt,
    this.product,
  });


  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString(),
      quantity: json['quantity'] as int?,
      price: (json['price'] as num?)?.toDouble(),
      installmentTotalPrice: json['installmentTotalPrice'] != null
          ? double.tryParse(json['installmentTotalPrice'].toString())
          : null,
      isInstallment: json['isInstallment'] as bool?,
      installmentFrequency: json['installmentFrequency'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'price': price,
      'installmentTotalPrice': installmentTotalPrice,
      'isInstallment': isInstallment,
      'installmentFrequency': installmentFrequency,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'product': product?.toJson(),
    };
  }
}
