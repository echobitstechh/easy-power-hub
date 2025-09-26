import 'package:easy_ph/features/cart/checkout/widget/billing_summary.dart';
import 'package:easy_ph/features/cart/checkout/widget/checkout_order_summary.dart';
import 'package:easy_ph/features/cart/checkout/widget/checkout_payment_options.dart';
import 'package:easy_ph/features/cart/checkout/widget/delivery_method_widget.dart';
import 'package:easy_ph/features/cart/checkout/widget/shipping_details_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../core/data/models/cart_item.dart';
import '../../../core/utils/money_util.dart';
import '../../../ui/common/app_colors.dart';
import '../../../ui/common/ui_helpers.dart';
import '../../../ui/components/shimmers/checkout_page_shimmer.dart';
import '../../../ui/components/shimmers/shipping_list_shimmers.dart';
import '../../../ui/components/submit_button.dart';
import 'checkout_viewmodel.dart';

class CheckoutView extends StackedView<CheckoutViewModel> {
  final int cartSubtotal;
  final int cartDiscount;
  final int calculatedFinalTotal;
  final List<CartItem> cartItems;

  const CheckoutView({
    super.key,
    required this.cartSubtotal,
    required this.cartDiscount,
    required this.cartItems,
    required this.calculatedFinalTotal,
  });

  @override
  void onViewModelReady(CheckoutViewModel viewModel) {
    viewModel.init();
    viewModel.calculatedFinalTotal = calculatedFinalTotal;
  }

  @override
  Widget builder(
      BuildContext context, CheckoutViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Checkout"),
      ),
      body: viewModel.isBusy
          ? const CheckoutPageShimmer()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      CheckoutOrderSummary(cartItems: cartItems),
                      verticalSpaceSmall,
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Shipping Details",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  TextButton.icon(
                                    onPressed:
                                        viewModel.showAddAddressBottomSheet,
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text("Add New"),
                                  ),
                                ],
                              ),
                              verticalSpaceSmall,
                              viewModel.isShippingLoading
                                  ? const ShippingListShimmer()
                                  : viewModel.shippingAddresses.isEmpty
                                      ? const Text(
                                          "No shipping addresses found. Add one to continue.")
                                      : Column(
                                          children: viewModel.shippingAddresses
                                              .map((address) {
                                            return ListTile(
                                              title: Text(address.address ??
                                                  'No address'),
                                              subtitle: Text(
                                                  '${address.city ?? ''}, ${address.state ?? ''}'),
                                              trailing: Radio(
                                                value: address.id,
                                                groupValue:
                                                    viewModel.shippingId,
                                                onChanged: (id) =>
                                                    viewModel.updateShippingId(
                                                        id as String),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                            ],
                          ),
                        ),
                      ),
                      verticalSpaceSmall,
                      BillingSummary(
                        subtotal: viewModel.cartSubtotal,
                        discount: viewModel.discountAmount,
                        deliveryFee: viewModel.calculatedDeliveryFee,
                        total: viewModel.calculatedFinalTotal,
                      ),
                      verticalSpaceSmall,
                      DeliveryMethodWidget(
                        pickUpOption: viewModel.pickUpOption,
                        onOptionChanged: (option) {
                          viewModel.updatePickupOption(option);
                          viewModel.calculateOrder();
                        },
                      ),
                      verticalSpaceSmall,
                      CheckoutPaymentOptions(
                        selectedMethod: viewModel.paymentMethod,
                        onMethodChanged: viewModel.updatePaymentMethod,
                      ),
                    ],
                  ),
                ),
                // Pinned SubmitButton at the bottom
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: SubmitButton(
                      family: 'Roboto',
                      isLoading: viewModel.isPaying,
                      label: viewModel.paymentMethod == "delivery"
                          ? "Confirm Order"
                          : "Pay ${MoneyUtils().formatAmount(viewModel.calculatedFinalTotal)}",
                      submit: () => viewModel.processPayment(context),
                      color: kcPrimaryColor,
                      boldText: true,
                      icon: viewModel.paymentMethod == "delivery"
                          ? Icons.shopping_bag
                          : Icons.credit_card,
                      iconColor: Colors.blue,
                      iconIsPrefix: true,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  CheckoutViewModel viewModelBuilder(BuildContext context) =>
      CheckoutViewModel();
}
