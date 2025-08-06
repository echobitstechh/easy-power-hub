import 'package:easyph/ui/views/checkout/widgets/checkout.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easyph/ui/views/checkout/checkout_viewmodel.dart';
import 'package:easyph/core/data/models/cart_item.dart';
import 'package:easyph/ui/components/submit_button.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/utils/money_util.dart';
import 'package:easyph/core/data/models/delivery_zone.dart';
import 'package:easyph/core/data/models/category.dart';
import 'package:easyph/state.dart';
import 'package:easyph/ui/components/text_field_widget.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../core/data/models/profile.dart';

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
    required this.calculatedFinalTotal
  });

  @override
  void onViewModelReady(CheckoutViewModel viewModel){
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
      body: viewModel.isPaying
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CheckoutOrderSummary(cartItems: cartItems),
          verticalSpaceSmall,
          ShippingDetailsWidget(onAddAddress: () => _showAddAddressBottomSheet(context, viewModel)),
          verticalSpaceSmall,
          BillingSummary(subtotal: cartSubtotal),
          verticalSpaceSmall,
          const DeliveryMethodWidget(),
          verticalSpaceSmall,
          CheckoutPaymentOptions(selectedMethod: viewModel.paymentMethod,
            onMethodChanged: viewModel.updatePaymentMethod),
          verticalSpaceLarge,
          SubmitButton(
            family: 'Roboto',
            isLoading: viewModel.loading,
            label: viewModel.paymentMethod == "delivery"
                ? "Confirm Order"
                : "Pay ${MoneyUtils().formatAmount(viewModel.calculatedFinalTotal)}",
            submit: () async {
              if (viewModel.pickUpOption == "Delivery") {
                bool isElectronics = cart.value.any((item) {
                  final category = globalCategories.value.firstWhere(
                        (cat) => cat.id == item.product?.categoryId,
                    orElse: () => Category(id: 0, name: '', status: CategoryStatus.active),
                  );
                  return category.name.toLowerCase().contains('electronics');
                });

                Address? selectedAddress = viewModel.shippingAddresses.firstWhere(
                      (address) => address.id == viewModel.shippingId,
                  orElse: () => Address(address: '', city: '', state: '', phoneNumber: '', id: '', type: '', userId: ''),
                );
                print('Selected Address: ${selectedAddress.address}, State: ${selectedAddress.state}');
                if (selectedAddress.id == null || selectedAddress.id!.isEmpty){
                  locator<SnackbarService>().showSnackbar(
                    message: "Please select or add a shipping address.",
                    duration: const Duration(seconds: 3),
                  );
                  return;
                }
                print('went on after return');

                bool? isInAbuja = selectedAddress.state?.toLowerCase().contains("abuja");
                if (isElectronics && !isInAbuja!) {
                  locator<SnackbarService>().showSnackbar(
                    message: "Home delivery for electronics is only available in Abuja.",
                    duration: const Duration(seconds: 3),
                  );
                  return;
                }
              }

              await viewModel.processPayment(viewModel.calculatedFinalTotal, viewModel.paymentMethod, context);
            },
            color: kcPrimaryColor,
            boldText: true,
            icon: viewModel.paymentMethod == "delivery" ? Icons.shopping_bag : Icons.credit_card,
            iconColor: Colors.blue,
            iconIsPrefix: true,
          ),
        ],
      ),
    );
  }

  void _showAddAddressBottomSheet(BuildContext context, CheckoutViewModel model) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Add Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    verticalSpaceSmall,
                    TextFieldWidget(
                      hint: 'House address',
                      controller: model.houseAddressController,
                      onChanged: (_) {},
                    ),
                    verticalSpaceSmall,
                    TextFieldWidget(
                      hint: 'City',
                      controller: model.cityController,
                      onChanged: (_) {},
                    ),
                    verticalSpaceSmall,
                    TextFieldWidget(
                      hint: 'State/Nationality',
                      controller: model.stateController,
                      onChanged: (_) {},
                    ),
                    verticalSpaceSmall,
                    TextFieldWidget(
                      hint: 'Phone Number',
                      controller: model.phoneNumberController,
                      onChanged: (_) {},
                    ),
                    verticalSpaceSmall,
                    DropdownButtonFormField<DeliveryZone>(
                      decoration: const InputDecoration(
                        labelText: "Delivery Zone",
                        border: OutlineInputBorder(),
                      ),
                      value: model.selectedDeliveryZone,
                      items: model.deliveryZones.map((zone) {
                        return DropdownMenuItem<DeliveryZone>(
                          value: zone,
                          child: Text('${zone.name} (${zone.baseFee?.toStringAsFixed(0) ?? ''} NGN)'),
                        );
                      }).toList(),
                      onChanged: (zone) => setModalState(() => model.selectedDeliveryZone = zone),
                    ),
                    verticalSpaceMedium,
                    SubmitButton(
                      isLoading: model.loading,
                      label: 'Add Address',
                      submit: () async {
                        if (model.houseAddressController.text.isNotEmpty &&
                            model.cityController.text.isNotEmpty &&
                            model.stateController.text.isNotEmpty &&
                            model.phoneNumberController.text.isNotEmpty &&
                            model.selectedDeliveryZone != null) {
                          await model.createNewShipping();
                          Navigator.pop(context);
                          await model.getShippings();
                        }
                      },
                      color: kcPrimaryColor,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  CheckoutViewModel viewModelBuilder(BuildContext context) => CheckoutViewModel();
}
