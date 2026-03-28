import 'package:flutter/material.dart';

enum TransactionType { savings, installments, purchase, other }

enum TransactionStatus { successful, failed, processing, pending }

class WalletTransaction {
  final String id;
  final String refNumber;
  final TransactionType type;
  final double amount;
  final DateTime dateTime;
  final TransactionStatus status;
  final String currency;

  WalletTransaction({
    this.id = '',
    required this.refNumber,
    required this.type,
    required this.amount,
    required this.dateTime,
    required this.status,
    this.currency = '₦',
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id']?.toString() ?? '',
      refNumber: json['TransactionRef']?.toString() ?? 'N/A',
      type: _parseType(json['type']?.toString()),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      dateTime: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      status: _parseStatus(json['status']?.toString()),
    );
  }

  static TransactionType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'savings':
        return TransactionType.savings;
      case 'installment':
      case 'installments':
        return TransactionType.installments;
      case 'purchase':
        return TransactionType.purchase;
      default:
        return TransactionType.other;
    }
  }

  static TransactionStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return TransactionStatus.successful;
      case 'failed':
        return TransactionStatus.failed;
      case 'pending':
        return TransactionStatus.pending;
      default:
        return TransactionStatus.processing;
    }
  }

  String get typeLabel {
    switch (type) {
      case TransactionType.savings:
        return 'Savings';
      case TransactionType.installments:
        return 'Installments';
      case TransactionType.purchase:
        return 'Purchase';
      default:
        return 'Transaction';
    }
  }

  String get statusLabel {
    switch (status) {
      case TransactionStatus.successful:
        return 'Successful';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.pending:
        return 'Pending';
    }
  }

  Color get statusColor {
    switch (status) {
      case TransactionStatus.successful:
        return Colors.green;
      case TransactionStatus.failed:
        return Colors.red;
      case TransactionStatus.processing:
        return Colors.orange;
      case TransactionStatus.pending:
        return Colors.blue;
    }
  }
}
