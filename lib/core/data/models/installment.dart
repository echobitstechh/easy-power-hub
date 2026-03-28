import 'package:easy_ph/core/data/models/product.dart';

class InstallmentPlan {
  final String id;
  final String? orderId;
  final Product product;
  final double goalAmount;
  double totalPaid;
  final bool isCompleted;
  final List<InstallmentPayment> payments;

  InstallmentPlan({
    required this.id,
    this.orderId,
    required this.product,
    required this.goalAmount,
    required this.totalPaid,
    this.isCompleted = false,
    this.payments = const [],
  });

  factory InstallmentPlan.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString() ?? '';
    final List<InstallmentPayment> parsedPayments = [];

    if (json['installmentPayments'] != null) {
      for (final p in (json['installmentPayments'] as List)) {
        parsedPayments
            .add(InstallmentPayment.fromJson(Map<String, dynamic>.from(p)));
      }
    } else if (json['payments'] != null) {
      for (final p in (json['payments'] as List)) {
        parsedPayments
            .add(InstallmentPayment.fromJson(Map<String, dynamic>.from(p)));
      }
    }

    Product product;
    String? orderId;
    if (json['product'] != null) {
      product = Product.fromJson(Map<String, dynamic>.from(json['product']));
    } else if (json['order'] != null) {
      orderId = json['order']['id']?.toString();
      if (json['order']['product'] != null) {
        product = Product.fromJson(
            Map<String, dynamic>.from(json['order']['product']));
      } else {
        product = Product(productName: 'Product');
      }
    } else {
      product = Product(productName: 'Product');
    }

    final goalAmount =
        (json['amountGoal'] ?? json['totalAmount'] ?? json['amount'] as num?)
                ?.toDouble() ??
            0;
    final totalPaid =
        (json['totalPaid'] ?? json['amountPaid'] as num?)?.toDouble() ?? 0;

    return InstallmentPlan(
      id: json['id']?.toString() ?? '',
      orderId: orderId,
      product: product,
      goalAmount: goalAmount,
      totalPaid: totalPaid,
      isCompleted: status.toLowerCase() == 'completed',
      payments: parsedPayments,
    );
  }

  double get balance => goalAmount - totalPaid;
  double get progress =>
      goalAmount > 0 ? (totalPaid / goalAmount).clamp(0.0, 1.0) : 0;
  int get progressPercent => (progress * 100).toInt();

  String get statusLabel {
    return isCompleted ? 'Completed' : 'In Progress';
  }
}

class InstallmentPayment {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isPaid;
  final bool isDue;

  InstallmentPayment({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.isPaid = true,
    this.isDue = false,
  });

  factory InstallmentPayment.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString().toLowerCase() ?? '';
    return InstallmentPayment(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ??
          json['label']?.toString() ??
          'Installment',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate']) ?? DateTime.now()
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
              : DateTime.now(),
      isPaid: status == 'paid',
      isDue: status == 'due' || status == 'overdue',
    );
  }
}
