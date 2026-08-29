
import 'package:easy_ph/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CheckoutPaymentOptions extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodChanged;
  final bool isPayOnDeliveryDisabled;
  final String disabledMessage;

  const CheckoutPaymentOptions({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
    this.isPayOnDeliveryDisabled = false,
    this.disabledMessage = "",
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
              "How would you like to proceed?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            verticalSpaceSmall,
            RadioListTile<String>(
              title: Row(
                children: [
                  Icon(Icons.receipt),
                  const SizedBox(width: 12),
                  const Text('Confirm your order'),
                ],
              ),
              value: 'paystack',
              groupValue: selectedMethod,
              onChanged: (value) => onMethodChanged(value!),
            ),
            RadioListTile<String>(
              title: Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 24,
                    color: isPayOnDeliveryDisabled ? Colors.grey : null,
                  ),
                  const SizedBox(width: 12),
                  const Text('Pay on Delivery'),
                ],
              ),
              value: 'delivery',
              groupValue: selectedMethod,
              onChanged: isPayOnDeliveryDisabled ? null : (value) => onMethodChanged(value!),
              // tileColor: isPayOnDeliveryDisabled ? Colors.grey[200] : null,
            ),
            if (isPayOnDeliveryDisabled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  disabledMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}