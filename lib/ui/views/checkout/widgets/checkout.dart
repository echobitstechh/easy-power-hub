// checkout_widgets.dart

import 'package:flutter/material.dart';
import 'package:easyph/core/data/models/cart_item.dart';
import 'package:stacked/stacked.dart';

import '../../../../utils/money_util.dart';
import '../../../common/app_colors.dart';
import '../../../common/ui_helpers.dart';
import '../checkout_viewmodel.dart';

class CheckoutOrderSummary extends StatelessWidget {
  final List<CartItem> cartItems;

  const CheckoutOrderSummary({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: const Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold)),
        children: cartItems.map((item) {
          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(item.product?.images?.first ?? '')),
            title: Text(item.product?.productName ?? ''),
            trailing: Text("₦${item.price}", style: const TextStyle(fontFamily: 'Roboto')),
          );
        }).toList(),
      ),
    );
  }
}

class CheckoutPaymentOptions extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onMethodChanged;

  const CheckoutPaymentOptions({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: const Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          RadioListTile(
            value: "paystack",
            groupValue: selectedMethod,
            onChanged: (value) => onMethodChanged(value!),
            title: const Text("Paystack"),
          ),
          RadioListTile(
            value: "delivery",
            groupValue: selectedMethod,
            onChanged: (value) => onMethodChanged(value!),
            title: const Text("Pay on Delivery"),
          ),
        ],
      ),
    );
  }
}

class BillingSummary extends ViewModelWidget<CheckoutViewModel> {
  const BillingSummary({super.key, required this.subtotal});

  final int subtotal;

  @override
  Widget build(BuildContext context, CheckoutViewModel model) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
        title: const Text("Billing summary", style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Sub-total", style: TextStyle(fontSize: 16)),
              Text(MoneyUtils().formatAmount(model.cartSubtotal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Roboto',)),
            ],
          ),
          verticalSpaceTiny,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Delivery-Fee", style: TextStyle(fontSize: 16)),
              model.isCalculating
                  ? const SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(MoneyUtils().formatAmount(model.calculatedDeliveryFee), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Roboto')),
            ],
          ),
          verticalSpaceTiny,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Discount", style: TextStyle(fontSize: 16)),
              Text("- ${MoneyUtils().formatAmount(model.discountAmount)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green, fontFamily: 'Roboto',)),
            ],
          ),
          const Divider(thickness: 2),
          verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              model.isCalculating
                  ? const SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(MoneyUtils().formatAmount(model.calculatedFinalTotal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily: 'Roboto',)),
            ],
          ),
          verticalSpaceSmall
        ],
      ),
    );
  }
}

class ShippingDetailsWidget extends ViewModelWidget<CheckoutViewModel> {
  final VoidCallback onAddAddress;
  const ShippingDetailsWidget({super.key, required this.onAddAddress});

  @override
  Widget build(BuildContext context, CheckoutViewModel viewModel) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: const Text("Shipping details", style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          viewModel.isShippingLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              if (viewModel.shippingAddresses.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewModel.shippingAddresses.length,
                  itemBuilder: (context, index) {
                    final address = viewModel.shippingAddresses[index];
                    return ListTile(
                      title: Text("${address.address}, ${address.city}, ${address.state}"),
                      subtitle: Text("Phone: ${address.phoneNumber}"),
                      trailing: Radio<String>(
                        value: address.id ?? '',
                        groupValue: viewModel.shippingId,
                        onChanged: (String? value) {
                          if (value != null) {
                            viewModel.updateShippingId(value);
                            viewModel.calculateOrder();
                          }
                        },
                      ),
                    );
                  },
                ),
              if (viewModel.shippingAddresses.isEmpty)
                const Text("No Shipping address found"),
              verticalSpaceSmall,
              TextButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kcPrimaryColor)),
                child: const Text("Add new shipping address", style: TextStyle(color: kcWhiteColor)),
                onPressed: onAddAddress,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DeliveryMethodWidget extends ViewModelWidget<CheckoutViewModel> {
  const DeliveryMethodWidget({super.key});

  @override
  Widget build(BuildContext context, CheckoutViewModel viewModel) {
    Widget buildOption({
      required String value,
      required String title,
      required String subtitle,
    }) {
      final isSelected = viewModel.pickUpOption == value;
      return InkWell(
        onTap: () {
          viewModel.updatePickupOption(value);
          viewModel.calculateOrder();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 70,
          decoration: BoxDecoration(
            border: Border.all(color: kcBlackColor, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kcBlackColor, width: 1),
                ),
                child: isSelected
                    ? const Center(child: Icon(Icons.check, size: 12))
                    : const SizedBox(),
              ),
              horizontalSpaceSmall,
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              horizontalSpaceSmall,
              Expanded(child: Text(subtitle, style: const TextStyle(fontSize: 11))),
            ],
          ),
        ),
      );
    }

    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        title: const Text("Delivery method", style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          buildOption(
            value: "Pickup",
            title: "Pickup station",
            subtitle: "You will be notified when your order is ready for pickup",
          ),
          verticalSpaceSmall,
          buildOption(
            value: "Delivery",
            title: "Home delivery",
            subtitle: "Your order will be delivered to your address",
          ),
        ],
      ),
    );
  }
}
