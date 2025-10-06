import 'package:easy_ph/core/data/models/product.dart';

class FavoriteItem {
  final String id;
  final String userId;
  final Product product;
  final String createdAt;
  final String updatedAt;

  FavoriteItem({
    required this.id,
    required this.product,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      product: Product.fromJson(json['Product']),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
