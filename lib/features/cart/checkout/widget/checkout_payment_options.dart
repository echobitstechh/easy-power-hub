
import 'package:flutter/material.dart';

import '../../../../ui/common/ui_helpers.dart';

class CheckoutPaymentOptions extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodChanged;

  const CheckoutPaymentOptions({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment Method",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            verticalSpaceSmall,
            RadioListTile<String>(
              title: const Text('Paystack'),
              value: 'paystack',
              groupValue: selectedMethod,
              onChanged: (value) => onMethodChanged(value!),
            ),
            RadioListTile<String>(
              title: const Text('Pay on Delivery'),
              value: 'delivery',
              groupValue: selectedMethod,
              onChanged: (value) => onMethodChanged(value!),
            ),
          ],
        ),
      ),
    );
  }
}