import 'package:easy_ph/core/data/models/product.dart';

class SavingsPlan {
  final String id;
  final Product product;
  final double goalAmount;
  double totalPaid;
  final bool isCompleted;
  final bool isCancelled;
  final List<SavingsPayment> payments;

  SavingsPlan({
    required this.id,
    required this.product,
    required this.goalAmount,
    required this.totalPaid,
    this.isCompleted = false,
    this.isCancelled = false,
    this.payments = const [],
  });

  factory SavingsPlan.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString() ?? '';
    final List<SavingsPayment> parsedPayments = [];

    // Parse installments/payments if present in detail response
    if (json['installments'] != null) {
      for (final p in (json['installments'] as List)) {
        parsedPayments
            .add(SavingsPayment.fromJson(Map<String, dynamic>.from(p)));
      }
    }

    // Parse product from nested object or construct minimal one
    Product product;
    if (json['product'] != null) {
      product = Product.fromJson(Map<String, dynamic>.from(json['product']));
    } else {
      product = Product(
          productName: 'Product', price: json['amountGoal']?.toString());
    }

    return SavingsPlan(
      id: json['id']?.toString() ?? '',
      product: product,
      goalAmount: (json['amountGoal'] as num?)?.toDouble() ?? 0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0,
      isCompleted: status.toLowerCase() == 'completed',
      isCancelled: status.toLowerCase() == 'cancelled',
      payments: parsedPayments,
    );
  }

  double get balance => goalAmount - totalPaid;
  double get progress => (totalPaid / goalAmount).clamp(0.0, 1.0);
  int get progressPercent => (progress * 100).toInt();

  String get statusLabel {
    if (isCancelled) return 'Cancelled';
    return isCompleted ? 'Completed' : 'In Progress';
  }
}

class SavingsPayment {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isPaid;

  SavingsPayment({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.isPaid = true,
  });

  factory SavingsPayment.fromJson(Map<String, dynamic> json) {
    return SavingsPayment(
      id: json['id']?.toString() ?? '',
      title:
          json['title']?.toString() ?? json['label']?.toString() ?? 'Payment',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
              : DateTime.now(),
      isPaid: json['status']?.toString().toLowerCase() == 'paid' ||
          json['isPaid'] == true,
    );
  }
}
