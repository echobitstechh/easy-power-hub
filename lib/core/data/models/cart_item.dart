import 'package:easyph/core/data/models/product.dart';


class CartItem {
  int? id;
  int? quantity;
  DateTime? createdAt;
  DateTime? updatedAt;
  Product? product;

  CartItem({
    this.id,
    this.quantity,
    this.createdAt,
    this.updatedAt,
    this.product,
  });

  // Factory method to create a CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int?,
      quantity: json['quantity'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  // Method to convert CartItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'product': product?.toJson(),
    };
  }
}

