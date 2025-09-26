
import 'package:flutter/material.dart';

import '../../../../ui/common/ui_helpers.dart';

enum PickUpOptions { Pickup, Delivery }

class DeliveryMethodWidget extends StatelessWidget {
  final PickUpOptions pickUpOption;
  final Function(PickUpOptions) onOptionChanged;

  const DeliveryMethodWidget({
    super.key,
    required this.pickUpOption,
    required this.onOptionChanged,
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
              "Delivery Method",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            verticalSpaceSmall,
            RadioListTile<PickUpOptions>(
              title: const Text('Home Delivery'),
              value: PickUpOptions.Delivery,
              groupValue: pickUpOption,
              onChanged: (value) => onOptionChanged(value!),
            ),
            RadioListTile<PickUpOptions>(
              title: const Text('Pickup'),
              value: PickUpOptions.Pickup,
              groupValue: pickUpOption,
              onChanged: (value) => onOptionChanged(value!),
            ),
          ],
        ),
      ),
    );
  }
}