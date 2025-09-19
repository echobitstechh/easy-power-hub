


import 'package:easy_ph/core/data/models/product.dart';
import 'package:easy_ph/core/data/models/profile.dart';

class Order {
  final String id;
  final int quantity;
  final String orderType;
  final double shippingFee;
  final bool installmentPayment;
  final String userId;
  final String? transactionId;
  final String status;
  final String trackingNumber;
  final String orderNumber;
  final int totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Product> products;
  final bool isReviewed;
  final bool isPaid;

  Order({
    required this.id,
    required this.quantity,
    required this.orderType,
    required this.shippingFee,
    required this.installmentPayment,
    required this.userId,
    this.transactionId,
    required this.status,
    required this.trackingNumber,
    required this.orderNumber,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.products,
    this.isReviewed = false,
    this.isPaid = false,
  });

  // Factory method to create an Order from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      quantity: json['quantity'],
      orderType: json['orderType'],
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      installmentPayment: json['installmentPayment'],
      userId: json['userId'],
      transactionId: json['transactionId'],
      status: json['status'],
      trackingNumber: json['trackingNumber'],
      orderNumber: json['orderNumber'],
      totalPrice: (json['totalPrice'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      products: (json['Products'] as List)
          .map((product) => Product.fromJson(product))
          .toList() ?? [],
      isReviewed: json["reviewStatus"] ?? false,
      isPaid: json["isPaid"] ?? false,
    );
  }

  // Convert an Order object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'orderType': orderType,
      'shippingFee': shippingFee,
      'installmentPayment': installmentPayment,
      'userId': userId,
      'transactionId': transactionId,
      'status': status,
      'trackingNumber': trackingNumber,
      'orderNumber': orderNumber,
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isReviewed': isReviewed,
      'isPaid': isPaid,
      'Products': products.map((product) => product.toJson()).toList(),
    };
  }
}

class Tracking {
  String? id;
  int? status;
  String? location;
  String? trackingNumber;
  String? comment;
  String? created;
  String? updated;

  Tracking(
      {this.id,
      this.status,
      this.location,
      this.trackingNumber,
      this.comment,
      this.created,
      this.updated});

  Tracking.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    location = json['location'];
    trackingNumber = json['tracking_number'];
    comment = json['comment'];
    created = json['created'];
    updated = json['updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['location'] = location;
    data['tracking_number'] = trackingNumber;
    data['comment'] = comment;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}

class Transaction {
  String? id;
  int? status;
  int? amount;
  String? reference;
  dynamic meta;
  int? type;
  String? created;
  String? updated;
  Shipping? shipping;
  // OrderItem? order;

  Transaction(
      {this.id,
      this.status,
      this.amount,
      this.reference,
      this.meta,
      this.type,
      this.created,
      this.updated,
      this.shipping,
      // this.order,
     });

  Transaction.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        status = json['status'],
        amount = json['amount'],
        reference = json['reference'],
        meta = json['meta'],
        type = json['type'],
        created = json['created'],
        updated = json['updated'],
        shipping = json['shipping'];
        // order = (json['order']);

  // Transaction.fromJson(Map<String, dynamic> json) {
  //   id = json['id'];
  //   status = json['status'];
  //   amount = json['amount'];
  //   reference = json['reference'];
  //   meta = json['meta'];
  //   type = json['type'];
  //   created = json['created'];
  //   updated = json['updated'];
  // }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['amount'] = amount;
    data['reference'] = reference;
    data['meta'] = meta;
    data['type'] = type;
    data['created'] = created;
    data['updated'] = updated;
    data['shipping'] = shipping;
    return data;
  }
}

