

import 'package:easy_ph/core/data/models/tags.dart';

class Product {
  String? id;
  String? productName;
  String? productDescription;
  String? price;
  String? salePrice;
  double? rating;
  int? availability;
  int? stock;
  bool? ad;
  bool? featured;
  bool? lowStockAlert;
  int? categoryId;
  int? verifiedSales;
  String? brandName;
  int? modelNumber;
  String? createdAt;
  String? updatedAt;
  bool? installment;
  int? installmentFrequency;
  int? installmentDeposit;
  String? status;
  List<String>? reviews;
  List<String>? images;
  List<Tag>? tags;

  Product({
    this.id,
    this.productName,
    this.productDescription,
    this.price,
    this.salePrice,
    this.rating,
    this.availability,
    this.stock,
    this.ad,
    this.featured,
    this.lowStockAlert,
    this.categoryId,
    this.verifiedSales,
    this.brandName,
    this.modelNumber,
    this.createdAt,
    this.updatedAt,
    this.reviews,
    this.images,
    this.installment,
    this.status,
    this.installmentFrequency,
    this.installmentDeposit,
    this.tags,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productName = json['name'];
    productDescription = json['description'];
    price = json['price']?.toString() ?? '0';
    salePrice = json['salePrice']?.toString() ?? '0';
    rating = double.tryParse(json['rating']?.toString() ?? '0.0');
    availability = json['availability'];
    stock = json['stock'];
    ad = json['ad'];
    featured = json['featured'];
    lowStockAlert = json['lowStockAlert'];
    categoryId = json['categoryId'] is int ? json['categoryId'] : int.tryParse(json['categoryId']?.toString() ?? '0');
    verifiedSales = json['verifiedSale']; // Corrected key
    brandName = json['brandName'];
    modelNumber = json['modelNumber'] is int ? json['modelNumber'] : int.tryParse(json['modelNumber']?.toString() ?? '0');
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    reviews = json['reviews'] != null ? List<String>.from(json['reviews']) : null;
    images = json['images'] != null ? List<String>.from(json['images']) : null;
    installment = json['installment'];
    installmentFrequency = json['installmentFrequency'];
    installmentDeposit = json['installmentDeposit'];
    status = json['status'];

    tags = json['tags'] != null
        ? (json['tags'] as List).map((tagJson) => Tag.fromJson(tagJson)).toList()
        : null;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = productName;
    data['description'] = productDescription;
    data['price'] = price;
    data['salePrice'] = salePrice;
    data['rating'] = rating;
    data['availability'] = availability;
    data['stock'] = stock;
    data['ad'] = ad;
    data['featured'] = featured;
    data['lowStockAlert'] = lowStockAlert;
    data['categoryId'] = categoryId;
    data['verifiedSale'] = verifiedSales;
    data['brandName'] = brandName;
    data['modelNumber'] = modelNumber;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['installment'] = installment;
    data['installmentFrequency'] = installmentFrequency;
    data['installmentDeposit'] = installmentDeposit;
    data['status'] = status;
    if (reviews != null) {
      data['reviews'] = reviews;
    }
    if (images != null) {
      data['images'] = images;
    }

    if (tags != null) {
      data['tags'] = tags!.map((tag) => tag.toJson()).toList();
    }

    return data;
  }
}


class Pictures {
  String? id;
  String? token;
  String? location;
  int? type;
  bool? isPopup;
  bool? front;
  String? create;
  String? updated;

  Pictures(
      {this.id,
      this.token,
      this.location,
      this.type,
      this.isPopup,
      this.front,
      this.create,
      this.updated});

  Pictures.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    token = json['token'];
    location = json['location'];
    type = json['type'];
    isPopup = json['isPopup'];
    front = json['front'];
    create = json['create'];
    updated = json['updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['token'] = token;
    data['location'] = location;
    data['type'] = type;
    data['isPopup'] = isPopup;
    data['front'] = front;
    data['create'] = create;
    data['updated'] = updated;
    return data;
  }
}


class Review {
  final String content;
  final String reviewerName;
  final DateTime date;
  final double rating;

  Review({
    required this.content,
    required this.reviewerName,
    required this.date,
    required this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      content: json['reviewText'],
      reviewerName: "${json['User']['firstName']} ${json['User']['lastName']}",
      date: DateTime.parse(json['createdAt']),
      rating: (json['rating'] as num).toDouble(),
    );
  }
}



