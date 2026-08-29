
import 'package:flutter/material.dart';

import '../../../../core/utils/money_util.dart';

class BillingSummary extends StatelessWidget {
  final int subtotal;
  final int discount;
  final int deliveryFee;
  final int total;

  const BillingSummary({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
  });

  Color? get kcGreenColor => null;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow(context, "Subtotal", MoneyUtils().formatAmount(subtotal), null),
            _buildSummaryRow(context,"Discount", "- ${MoneyUtils().formatAmount(discount)}", kcGreenColor),
            _buildSummaryRow(context,"Delivery Fee", MoneyUtils().formatAmount(deliveryFee), null),
            const Divider(),
            _buildSummaryRow(context,"Total", MoneyUtils().formatAmount(total), null, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String amount, Color? color, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
              color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}