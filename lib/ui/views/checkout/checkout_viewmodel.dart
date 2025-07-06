import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/data/models/cart_item.dart';
import '../../../core/data/models/delivery_zone.dart';
import '../../../core/data/models/profile.dart';
import '../../../core/data/repositories/repository.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/interceptors.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../core/utils/paystack_util.dart';
import '../../../state.dart';
import '../../../utils/money_util.dart';
import '../../components/payment_success_page.dart';
import '../cart/payment_success_page.dart';
import '../cart/raffle_reciept.dart';
import '../profile/profile_viewmodel.dart';

class CheckoutViewModel extends BaseViewModel {
  // state
  String paymentMethod = "paystack";
  String pickUpOption = "Pickup";
  String shippingId = "";
  String publicKeyTest = MoneyUtils().payStackPublicKey;

  int calculatedDeliveryFee = 0;
  int calculatedFinalTotal = 0;
  int discountAmount = 0;

  bool isPaying = false;
  bool isCalculating = false;
  bool isShippingLoading = false;
  bool loading = false;
  bool makingDefault = false;

  List<Address> shippingAddresses = [];
  List<DeliveryZone> deliveryZones = [];
  DeliveryZone? selectedDeliveryZone;

  final plugin = PaystackPlugin();

  // Controllers
  final houseAddressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final phoneNumberController = TextEditingController();

  Future<void> createNewShipping() async {
    try {
      loading = true;
      notifyListeners();

      final response = await repo.saveShipping({
        "address": houseAddressController.text,
        "city": cityController.text,
        "state": stateController.text,
        "phoneNumber": phoneNumberController.text,
        "type": "Shipping",
        "zoneId": selectedDeliveryZone?.id ?? '',
      });

      if (response.statusCode == 201) {
        locator<SnackbarService>().showSnackbar(
          message: "Created address successfully",
          duration: const Duration(seconds: 2),
        );
        await getShippings();
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
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getShippings() async {
    try {
      isShippingLoading = true;
      notifyListeners();

      // Fetch shipping addresses from the API
      final response = await repo.getAddresses();

      if (response.statusCode == 200) {
        final List<dynamic> addressList = response.data['data'] ?? [];

        final List<Address> fetchedAddresses = addressList
            .map((item) => Address.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        shippingAddresses = fetchedAddresses;
        shippingId =
            (fetchedAddresses.isNotEmpty ? fetchedAddresses[0].id : "")!;
        notifyListeners();
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
      isShippingLoading = false;
      notifyListeners();
    }
  }

  int getTotalItems() {
    int quantity = 0;
    for (var element in cart.value) {
      quantity = quantity + element.quantity!;
    }

    return quantity;
  }

  Future<void> getDeliveryZones() async {
    try {
      final response = await repo.getDeliveryZones();

      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['zones'] ?? [];
        deliveryZones =
            list.map((item) => DeliveryZone.fromJson(item)).toList();
        notifyListeners();
      } else {
        locator<SnackbarService>().showSnackbar(
          message: response.data["message"],
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
        message: "Failed to fetch delivery zones: $e",
        duration: Duration(seconds: 2),
      );
    }
  }

  Future<void> fetchOnlineCart() async {
    try {
      ApiResponse res = await repo.cartList();
      if (res.statusCode == 200) {
        List<dynamic> items = res.data["cartItems"] ?? [];

        if (items.isNotEmpty) {
          List<CartItem> onlineItems = items
              .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          cart.value = onlineItems;
          await locator<LocalStorage>().save(LocalStorageDir.raffleCart,
              onlineItems.map((e) => e.toJson()).toList());
          cart.notifyListeners();
          notifyListeners();
        } else {
          cart.value.clear();
          await locator<LocalStorage>().delete(LocalStorageDir.raffleCart);
        }
      }
    } catch (e) {
      print('Couldn\'t get online cart: $e');
    }
  }

  Future<void> calculateOrder() async {
    if (shippingId.isEmpty || pickUpOption.isEmpty || pickUpOption == 'Pickup')
      return;

    isCalculating = true;
    notifyListeners();

    try {
      final response = await repo.calculateOrder({
        "deliveryAddressId": shippingId,
        "deliveryOption": pickUpOption,
      });

      if (response.statusCode == 200) {
        calculatedDeliveryFee = response.data['data']['shippingFee'] ?? 0;
        calculatedFinalTotal = response.data['data']['finalTotal'] ?? 0;
        notifyListeners();
      } else {
        locator<SnackbarService>().showSnackbar(
          message: response.data['message'] ?? "Failed to calculate total",
        );
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
        message: "Error calculating order: $e",
      );
    } finally {
      isCalculating = false;
      notifyListeners();
    }
  }

  Future<void> processPayment(int amount, String paymentMethod, BuildContext context) async {
    isPaying = true;
    notifyListeners();

    final hasInstallment = cart.value.any((e) => e.isInstallment == true);
    final firstInstallmentItem = cart.value.firstWhere(
        (e) => e.isInstallment == true,
        orElse: () => cart.value.first);

    Map<String, dynamic> requestBody = {
      "orderType":
          paymentMethod == "delivery" ? "PayOnDelivery" : "InstantPayment",
      "deliveryOption": pickUpOption,
      "promoCode": "",
      "installmentFrequency":
          hasInstallment ? firstInstallmentItem.installmentFrequency : null,
      "installmentPayment": hasInstallment,
      "deliveryAddressId": shippingId,
    };

    ApiResponse res = await locator<Repository>().payForOrder(requestBody);

    if (res.statusCode == 201) {
      if (paymentMethod == 'paystack') {
        ApiResponse response = await repo.initializePayment({
          'paymentMethod': 'CreditCard',
          'paymentType': 'Paystack',
          'orderId': res.data['order']['id'],
        });
        if (response.statusCode == 200) {
          print('Payment initialized successfully');

          await PaystackUtil.processPayment(
            context: context,
            ref: response.data['data']['reference'],
            accessCode: response.data['data']['access_code'],
            url: response.data['data']['authorization_url'],
            amountInNaira: amount,
            email: profile.value.email!,
            cartItems: cart.value,
          );
        } else {
          locator<SnackbarService>().showSnackbar(
              message: "Payment processing failed",
              duration: const Duration(seconds: 3));
        }
      } else {
        print('Payment method: $paymentMethod');
        locator<SnackbarService>().showSnackbar(
          message: "Order placed successfully",
          duration: const Duration(seconds: 2),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(),
        ));
      }
    } else {
      locator<SnackbarService>().showSnackbar(
        message: res.data["message"] ?? "Failed to place the order",
      );
    }

    isPaying = false;
    notifyListeners();
  }

  void updatePaymentMethod(String method) {
    paymentMethod = method;
    notifyListeners();
  }

  void updatePickupOption(String option) {
    pickUpOption = option;
    notifyListeners();
  }

  void updateShippingId(String id) {
    shippingId = id;
    notifyListeners();
  }

  Future<void> init() async {
    plugin.initialize(publicKey: publicKeyTest);
    await fetchOnlineCart();
    await getDeliveryZones();
    await getShippings();
    if (shippingId.isNotEmpty && pickUpOption.isNotEmpty) {
      await calculateOrder();
    }
  }
}
