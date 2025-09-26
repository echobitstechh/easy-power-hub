
import 'package:flutter/material.dart';

import '../../../../core/data/models/cart_item.dart';
import '../../../../core/utils/money_util.dart';

class CheckoutOrderSummary extends StatelessWidget {
  final List<CartItem> cartItems;

  const CheckoutOrderSummary({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ...cartItems.map((item) {
              final product = item.product;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${product?.productName ?? 'Unknown Product'} (x${item.quantity})',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      MoneyUtils().formatAmount(
                        (double.tryParse(product?.salePrice ?? '0') ?? 0)
                            .toInt(),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}