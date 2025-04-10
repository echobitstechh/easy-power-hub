import 'dart:ffi';

import 'package:easyph/app/app.locator.dart';
import 'package:easyph/core/data/models/order_info.dart';
import 'package:easyph/core/data/models/profile.dart';
import 'package:easyph/core/data/repositories/repository.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:easyph/state.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/components/submit_button.dart';
import 'package:easyph/ui/views/cart/raffle_reciept.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../core/data/models/cart_item.dart';
import '../../../core/network/interceptors.dart';
import '../../../utils/money_util.dart';
import '../../common/ui_helpers.dart';
import '../../components/text_field_widget.dart';
import 'add_shipping.dart';
import 'cart_viewmodel.dart';

class Checkout extends StatefulWidget {
  final CartViewModel viewModel;

  const Checkout({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  bool loading = false;
  bool isShippingLoading = false;
  String paymentMethod = "paystack";
  String pickUpOption = "Pickup";
  String shippingId = "";
  bool makingDefault = false;
  String publicKeyTest = MoneyUtils().payStackPublicKey;
  List<Address> shippingAddresses = [];
  int discountAmount = 0;
  bool freeDelivery = false;

  final plugin = PaystackPlugin();

  bool isPaying = false;
  final TextEditingController houseAddressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    plugin.initialize(publicKey: publicKeyTest);
    getShippings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Checkout",
        ),
      ),
      body: isPaying
          ? CircularProgressIndicator() // Show loader when updating
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: const Text(
                      "Order review",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${getTotalItems()} items in cart"),
                    children: List.generate(cart.value.length, (index) {
                      CartItem item = cart.value[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(10),
                        // height: 100,
                        decoration: BoxDecoration(
                          color: uiMode.value == AppUiModes.light
                              ? kcWhiteColor
                              : kcBlackColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color:
                                    const Color(0xFFE5E5E5).withOpacity(0.4),
                                offset: const Offset(8.8, 8.8),
                                blurRadius: 8.8)
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: (item.product?.images?.isNotEmpty ==
                                              true &&
                                          item.product!.images![0].isNotEmpty)
                                      ? DecorationImage(
                                          image: NetworkImage(
                                              item.product!.images![0]),
                                          fit: BoxFit
                                              .cover, // Optional: Adjust the image fit
                                        )
                                      : null,
                                ),
                              ),
                              horizontalSpaceMedium,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item.product!.productName ?? "", style: const TextStyle(
                                        fontSize: 10),),
                                    verticalSpaceTiny,
                                    Text(
                                      "N${item.product!.salePrice}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                verticalSpaceSmall,
                Card(
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: const Text(
                      "Billing summary",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      verticalSpaceSmall,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Sub-total",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            MoneyUtils()
                                .formatAmount(widget.viewModel.cartSubtotal),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      verticalSpaceTiny,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Delivery-Fee",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            getDeliveryFee() == 0
                                ? "-"
                                : "N${getDeliveryFee()}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      verticalSpaceTiny,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Discount",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "- ${MoneyUtils().formatAmount(widget.viewModel.cartDiscount)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      verticalSpaceTiny,
                      if (freeDelivery)
                        const Text(
                          "Free Delivery Applied!",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      const Divider(
                        thickness: 2,
                      ),
                      verticalSpaceSmall,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            MoneyUtils()
                                .formatAmount(widget.viewModel.cartFinalTotal),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      verticalSpaceSmall
                    ],
                  ),
                ),
                verticalSpaceSmall,
                Card(
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: const Text(
                      "Shipping details",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      isShippingLoading == true
                          ? const CircularProgressIndicator()
                          : shippingAddresses.isEmpty
                              ? Column(
                                  children: [
                                    const Text("No Shipping address found"),
                                    TextButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                kcPrimaryColor),
                                      ),
                                      child: const Text(
                                        "Add new shipping address",
                                        style: TextStyle(color: kcWhiteColor),
                                      ),
                                      onPressed: showAddAddressBottomSheet,
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: shippingAddresses.length,
                                  itemBuilder: (context, index) {
                                    final address = shippingAddresses[index];
                                    return ListTile(
                                      title: Text(
                                          "${address.address}, ${address.city}, ${address.state}"),
                                      subtitle:
                                          Text("Phone: ${address.phoneNumber}"),
                                      trailing: Radio<String>(
                                        value: address.id,
                                        groupValue: shippingId,
                                        onChanged: (String? value) {
                                          setState(() {
                                            shippingId = value!;
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                    ],
                  ),
                ),
                verticalSpaceSmall,
                Card(
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    title: const Text(
                      "Delivery method",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [

                      /// pickup station
                      InkWell(
                        onTap: () {
                          setState(() {
                            pickUpOption = "Pickup";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          height: 70,
                          decoration: BoxDecoration(
                              border: Border.all(color: kcBlackColor, width: 0.5)),
                          child: Row(
                            children: [
                              _buildDeliveryRadioIcon("Pickup"),
                              horizontalSpaceSmall,
                              const Text(
                                "Pickup station",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              horizontalSpaceSmall,
                              const Expanded(
                                child: Text(
                                  "You will be notified when your order is ready for pickup",
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      verticalSpaceSmall,
                      /// home delivery
                      InkWell(
                        onTap: () {
                          setState(() {
                            pickUpOption = "Delivery";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          height: 70,
                          decoration: BoxDecoration(
                              border: Border.all(color: kcBlackColor, width: 0.5)),
                          child: Row(
                            children: [
                              _buildDeliveryRadioIcon("Delivery"),
                              horizontalSpaceSmall,
                              const Text(
                                "Home delivery",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              horizontalSpaceSmall,
                              const Expanded(
                                child: Text(
                                  "Your order will be delivered to your address",
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpaceSmall,
                Card(
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    title: const Text(
                      "Payment method",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      /// --- Paystack option ---
                      InkWell(
                        onTap: () {
                          setState(() {
                            paymentMethod = "paystack";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          height: 70,
                          decoration: BoxDecoration(
                              border: Border.all(color: kcBlackColor, width: 0.5)),
                          child: Row(
                            children: [
                              _buildRadioIcon("paystack"),
                              horizontalSpaceSmall,
                              const Text(
                                "Paystack",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              horizontalSpaceSmall,
                              const Expanded(
                                child: Text(
                                  "You will be redirected to the Paystack website after submitting your order",
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      verticalSpaceSmall,

                      /// --- Pay on delivery option ---
                      InkWell(
                        onTap: () {
                          setState(() {
                            paymentMethod = "delivery";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          height: 70,
                          decoration: BoxDecoration(
                              border: Border.all(color: kcBlackColor, width: 0.5)),
                          child: Row(
                            children: [
                              _buildRadioIcon("delivery"),
                              horizontalSpaceSmall,
                              const Text(
                                "Pay on delivery",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              horizontalSpaceSmall,
                              const Expanded(
                                child: Text(
                                  "You can pay with your card or bank transfer at the time of delivery; simply inform our delivery agent when your order is being delivered.",
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      verticalSpaceSmall,
                      /// --- Info Row ---
                      Row(
                        children: const [
                          Icon(Icons.lock, color: kcSecondaryColor),
                          horizontalSpaceSmall,
                          Expanded(
                            child: Text(
                              "We protect your payment information using encryption to provide bank-level security.",
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                verticalSpaceLarge,
                SubmitButton(
                  isLoading: loading,
                  label: paymentMethod == "delivery"
                      ? "Confirm Order"
                      : "Pay ${MoneyUtils().formatAmount(getSubTotal() + getDeliveryFee())}",
                  submit: () async {
                    if (paymentMethod == null) {
                     // showSnackbar(context, "Please select a payment method");
                      return;
                    }

                    setState(() {
                      loading = true;
                    });

                    try {
                        await chargeCard(getSubTotal() + getDeliveryFee(), paymentMethod);
                    } catch (e) {
                      print("Payment Error: $e");
                    }

                    setState(() {
                      loading = false;
                    });
                  },
                  color: kcPrimaryColor,
                  boldText: true,
                  icon: paymentMethod == "delivery" ? Icons.shopping_bag : Icons.credit_card,
                  iconColor: Colors.blue,
                  iconIsPrefix: true,
                ),


              ],
            ),
    );
  }

  int getTotalItems() {
    int quantity = 0;
    for (var element in cart.value) {
      quantity = quantity + element.quantity!;
    }

    return quantity;
  }

  int getSubTotal() {
    int total = 0;

    for (var element in cart.value) {
      total = total +
          (double.parse(element.product?.salePrice.toString() ?? '0').round() *
              element.quantity!);
    }

    return total;
  }

  int getTotalPrice() {
    int total = 0;

    for (var element in cart.value) {
      total = total +
          (double.parse(element.product?.salePrice.toString() ?? '0').round() *
              element.quantity!);
    }

    return total;
  }

  int getDeliveryFee() {
    int total = 0;

    // for (var element in raffleCart.value) {
    //   total = total + (element.product!.shippingFee!);
    // }

    return total;
  }

  Future<void> chargeCard(int amount, String paymentMethod) async {
    setState(() {
      isPaying = true;
    });

    // Build the new request body
    Map<String, dynamic> requestBody = {
      "orderType": paymentMethod == "delivery" ? "PayOnDelivery" : "InstantPayment",
      "deliveryOption": pickUpOption,
      "promoCode": "",
      "shippingFee": getDeliveryFee(),
      "installmentPayment": false,
      "productsData": cart.value.map((item) {
        return {
          "productId": item.product?.id,
          "quantity": item.quantity,
          "price":
              double.parse(item.product?.salePrice.toString() ?? '0').round(),
        };
      }).toList(),
    };

    ApiResponse res = await locator<Repository>().payForOrder(requestBody);

    if (res.statusCode == 201) {
      // final orderData = res.data['order'];
      // final Order order = Order.fromJson(orderData);
      if (paymentMethod == 'paystack') {
        var charge = Charge()
          ..amount = (getSubTotal() + getDeliveryFee()) * 100 // amount in kobo
          ..reference = MoneyUtils().getReference()
          ..email = profile.value.email;

        // Open the Paystack payment UI
        CheckoutResponse response = await plugin.checkout(
          context,
          method: CheckoutMethod.card,
          charge: charge,
        );

        if (response.status == true) {
          print('Paystack payment successful');

          // Send the updated API request
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RaffleReceiptPage(
                carts: cart.value, // Pass cleared cart or saved items
              ),
            ),
          );
        } else {
          print('Paystack payment failed');
          locator<SnackbarService>()
              .showSnackbar(message: "Payment failed. Please try again.");
        }
      }
      else{
        // Handle other payment methods here
        print('Payment method: $paymentMethod');
        // Show success message or navigate to receipt page
        locator<SnackbarService>().showSnackbar(
          message: "Order placed successfully",
          duration: const Duration(seconds: 2),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RaffleReceiptPage(
              carts: cart.value, // Pass cleared cart or saved items
            ),
          ),
        );

      }
      // Navigate to the receipt page with the `Order` object
    } else {
      locator<SnackbarService>().showSnackbar(
        message: res.data["message"] ?? "Failed to place the order",
      );
    }

    setState(() {
      isPaying = false;
    });
  }

  void showAddAddressBottomSheet() {
    String name = '';
    String houseAddress = '';
    String city = '';
    String state = '';
    String phoneNumber = '';
    bool isDefaultPayment = false;

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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Add Address',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFieldWidget(
                        hint: 'House address',
                        controller: houseAddressController,
                        onChanged: (value) => houseAddress = value,
                      ),
                      verticalSpaceSmall,
                      TextFieldWidget(
                        hint: 'City',
                        controller: cityController,
                        onChanged: (value) => city = value,
                      ),
                      verticalSpaceSmall,
                      TextFieldWidget(
                        hint: 'State/Nationality',
                        controller: stateController,
                        onChanged: (value) => state = value,
                      ),
                      verticalSpaceSmall,
                      TextFieldWidget(
                        hint: 'Phone Number',
                        controller: phoneNumberController,
                        onChanged: (value) => phoneNumber = value,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: isDefaultPayment,
                            activeColor: Colors.black,
                            checkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            onChanged: (value) {
                              setModalState(() {
                                isDefaultPayment = value ?? false;
                              });
                            },
                          ),
                          const Text("Set as default payment method"),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SubmitButton(
                          isLoading: false,
                          label: 'Add Address',
                          submit: () {
                            if (houseAddressController.text.isNotEmpty &&
                                cityController.text.isNotEmpty &&
                                stateController.text.isNotEmpty &&
                                phoneNumberController.text.isNotEmpty) {
                              createNewShipping();
                              // addAddress(
                              //     name, houseAddress, city, state, phoneNumber,
                              //     isDefaultPayment);
                            }
                            houseAddressController.clear();
                            cityController.clear();
                            stateController.clear();
                            phoneNumberController.clear();
                          },
                          color: kcPrimaryColor),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> createNewShipping() async {
    try {
      setState(() {
        loading = true;
      });

      final response = await repo.saveShipping({
        "address": houseAddressController.text,
        "city": cityController.text,
        "state": stateController.text,
        "phoneNumber": phoneNumberController.text,
        "type": "Shipping"
      });

      if (response.statusCode == 200) {
        locator<SnackbarService>().showSnackbar(
          message: "Created address successfully",
          duration: const Duration(seconds: 2),
        );
        Navigator.pop(context);
      } else {
        locator<SnackbarService>().showSnackbar(
          message: response.data["message"],
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
        message: "Failed to create address: $e",
        duration: const Duration(seconds: 2),
      );
    } finally {
      if(mounted){
        setState(() async {
          await getShippings();
          loading = false;
        });
      }

    }
  }

  Future<void> getShippings() async {
    try {
      // Indicate loading state
      setState(() {
        isShippingLoading = true;
      });

      // Fetch shipping addresses from the API
      final response = await repo.getAddresses();

      if (response.statusCode == 200) {
        final List<dynamic> addressList = response.data['data'] ?? [];

        final List<Address> fetchedAddresses = addressList
            .map((item) => Address.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        print('Fetched addresses: $fetchedAddresses');

        setState(() {
          shippingAddresses = fetchedAddresses;
          shippingId = fetchedAddresses.isNotEmpty
              ? fetchedAddresses[0].id
              : "";
        });
      } else {
        locator<SnackbarService>().showSnackbar(
          message: response.data["message"],
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      // Handle errors
      locator<SnackbarService>().showSnackbar(
        message: "Failed to fetch addresses: $e",
        duration: const Duration(seconds: 2),
      );
    } finally {
      // Stop the loading state
      if(mounted){
        setState(() {
          isShippingLoading = false;
        });
      }

    }
  }

  Widget _buildRadioIcon(String method) {
    return Container(
      height: 15,
      width: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kcBlackColor, width: 1),
      ),
      child: paymentMethod == method
          ? const Center(
        child: Icon(Icons.check, size: 12),
      )
          : const SizedBox(),
    );
  }

  Widget _buildDeliveryRadioIcon(String method) {
    return Container(
      height: 15,
      width: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kcBlackColor, width: 1),
      ),
      child: pickUpOption == method
          ? const Center(
        child: Icon(Icons.check, size: 12),
      )
          : const SizedBox(),
    );
  }

}
