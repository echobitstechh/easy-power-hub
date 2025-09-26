
import 'package:flutter/material.dart';

import '../../../../ui/common/ui_helpers.dart';
import '../checkout_viewmodel.dart';

class ShippingDetailsWidget extends StatelessWidget {
  final VoidCallback onAddAddress;
  final CheckoutViewModel viewModel;

  const ShippingDetailsWidget({super.key, required this.onAddAddress, required this.viewModel});

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Shipping Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                TextButton.icon(
                  onPressed: onAddAddress,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add New"),
                ),
              ],
            ),
            verticalSpaceSmall,
            viewModel.isShippingLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.shippingAddresses.isEmpty
                ? const Text("No shipping addresses found. Add one to continue.")
                : Column(
              children: viewModel.shippingAddresses.map((address) {
                return ListTile(
                  title: Text(address.address ?? 'No address'),
                  subtitle: Text('${address.city ?? ''}, ${address.state ?? ''}'),
                  trailing: Radio(
                    value: address.id,
                    groupValue: viewModel.shippingId,
                    onChanged: (id) => viewModel.updateShippingId(id as String),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}