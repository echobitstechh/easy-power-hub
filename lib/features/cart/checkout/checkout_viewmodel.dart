
import 'package:easy_ph/features/cart/checkout/widget/delivery_method_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.bottomsheets.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/data/models/cart_item.dart';
import '../../../core/data/models/category.dart';
import '../../../core/data/models/delivery_zone.dart';
import '../../../core/data/models/profile.dart';
import '../../../core/data/repositories/repository.dart';
import '../../../core/utils/config.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../core/utils/paystack_util.dart';
import '../../../state.dart';
import '../../Profile/onSuccess/success_view.dart';
import '../../Profile/shipping/shipping_address_viewmodel.dart';

class CheckoutViewModel extends BaseViewModel {
  final _repo = locator<Repository>();
  final _snackBar = locator<SnackbarService>();
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _localStorage = locator<LocalStorage>();

  // State
  String paymentMethod = "paystack";
  PickUpOptions pickUpOption = PickUpOptions.Pickup;

  String shippingId = "";
  final publicKeyTest = AppConfig.paystackApiKeyTest;

  int calculatedDeliveryFee = 0;
  int calculatedFinalTotal = 0;
  int discountAmount = 0;
  int cartSubtotal = 0;

  bool isPaying = false;
  bool isCalculating = false;
  bool isShippingLoading = false;
  bool loading = false;
  bool makingDefault = false;
  bool isPayOnDeliveryDisabled = false;

  List<Address> shippingAddresses = [];
  List<DeliveryZone> deliveryZones = [];
  DeliveryZone? selectedDeliveryZone;


  final houseAddressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final phoneNumberController = TextEditingController();


  void init() async {
    await runBusyFuture(initData());
  }

  Future<void> initData() async {
    await fetchOnlineCart();
    await getDeliveryZones();
    await getShippings();
    checkPayOnDeliveryEligibility();
    if (shippingId.isNotEmpty) {
      await calculateOrder();
    }
  }

  Future<void> createNewShipping({
    required String houseAddress,
    required String city,
    required String state,
    required String phoneNumber,
    required String zoneId,
  }) async {
    setBusy(true);
    try {
      final response = await _repo.saveShipping({
        "address": houseAddress,
        "city": city,
        "state": state,
        "phoneNumber": phoneNumber,
        "type": "Shipping",
        "zoneId": zoneId,
      });
      if (response.statusCode == 201) {
        _snackBar.showSnackbar(message: "Created address successfully");
        await getShippings();
      } else {
        _snackBar.showSnackbar(message: response.data["message"]);
      }
    } catch (e) {
      _snackBar.showSnackbar(message: "Failed to create address: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> getShippings() async {
    isShippingLoading = true;
    notifyListeners();
    try {
      final response = await _repo.getAddresses();
      if (response.statusCode == 200) {
        shippingAddresses = (response.data['data'] as List)
            .map((item) => Address.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        shippingId = shippingAddresses.isNotEmpty ? shippingAddresses[0].id! : "";
      } else {
        _snackBar.showSnackbar(message: response.data["message"]);
      }
    } catch (e) {
      _snackBar.showSnackbar(message: "Failed to fetch addresses: $e");
    } finally {
      isShippingLoading = false;
      notifyListeners();
    }
  }

  Future<void> getDeliveryZones() async {
    try {
      final response = await _repo.getDeliveryZones();
      if (response.statusCode == 200) {
        deliveryZones = (response.data['zones'] as List)
            .map((item) => DeliveryZone.fromJson(item))
            .toList();
        notifyListeners();
      } else {
        _snackBar.showSnackbar(message: response.data["message"]);
      }
    } catch (e) {
      _snackBar.showSnackbar(message: "Failed to fetch delivery zones: $e");
    }
  }

  Future<void> calculateOrder() async {
    final String deliveryOptionString = pickUpOption.toString().split('.').last;

    if (shippingId.isEmpty && pickUpOption == PickUpOptions.Delivery) return;

    isCalculating = true;
    notifyListeners();
    try {
      final response = await _repo.calculateOrder({
        "deliveryAddressId": shippingId,
        "deliveryOption": deliveryOptionString,
      });
      if (response.statusCode == 200) {
        final data = response.data['data'];
        calculatedDeliveryFee = data['shippingFee'] ?? 0;
        calculatedFinalTotal = data['finalTotal'] ?? 0;
        discountAmount = data['discount'] ?? 0;
        cartSubtotal = data["subtotal"] ?? 0;
        notifyListeners();
      } else {
        _snackBar.showSnackbar(message: response.data['message'] ?? "Failed to calculate total");
      }
    } catch (e) {
      _snackBar.showSnackbar(message: "Error calculating order: $e");
    } finally {
      isCalculating = false;
      notifyListeners();
    }
  }

  Future<void> fetchOnlineCart() async {
    setBusy(true);
    notifyListeners();
    try {
      final res = await _repo.cartList();
      if (res.statusCode == 200) {
        List<dynamic> items = res.data["cartItems"] ?? [];
        cart.value = items.map((item) => CartItem.fromJson(Map<String, dynamic>.from(item))).toList();
        await _localStorage.save(LocalStorageDir.productCart, cart.value.map((e) => e.toJson()).toList());
      } else {
        _snackBar.showSnackbar(message: res.data["message"] ?? "Failed to load cart from server.",
            duration: Duration(seconds: 3));
      }
    } catch (e) {
      // _log.e('Failed to load online cart: $e');
      _snackBar.showSnackbar(message: "Failed to load cart from server.", duration: Duration(seconds: 3));
    } finally {
      setBusy(false);
    }
  }

  Future<void> processPayment(BuildContext context) async {
    final String deliveryOptionString = pickUpOption.toString().split('.').last;

    if (pickUpOption == PickUpOptions.Delivery) {
      final isElectronics = cart.value.any((item) {
        final category = globalCategories.value.firstWhere(
              (cat) => cat.id == item.product?.categoryId,
          orElse: () => Category(id: 0, name: '', status: CategoryStatus.active),
        );
        return category.name.toLowerCase().contains('electronics');
      });

      final selectedAddress = shippingAddresses.firstWhere(
            (address) => address.id == shippingId,
        orElse: () => Address(address: '', city: '', state: '', phoneNumber: '', id: '', type: '', userId: ''),
      );

      if (selectedAddress.id == null || selectedAddress.id!.isEmpty) {
        _snackBar.showSnackbar(message: "Please select or add a shipping address.");
        return;
      }

      final isInAbuja = selectedAddress.state?.toLowerCase().contains("abuja");
      if (isElectronics && !(isInAbuja ?? false)) {
        _snackBar.showSnackbar(message: "Home delivery for electronics is only available in Abuja.");
        return;
      }
    }

    isPaying = true;
    notifyListeners();

    final hasInstallment = cart.value.any((e) => e.isInstallment == true);
    final firstInstallmentItem = cart.value.firstWhere(
            (e) => e.isInstallment == true,
        orElse: () => cart.value.first);

    final requestBody = {
      "orderType": paymentMethod == "delivery" ? "PayOnDelivery" : "InstantPayment",
      "deliveryOption": deliveryOptionString,
      "promoCode": "",
      "installmentFrequency": hasInstallment ? firstInstallmentItem.installmentFrequency : null,
      "installmentPayment": hasInstallment,
      "deliveryAddressId": shippingId,
    };

    try {
      final res = await _repo.payForOrder(requestBody);
      if (res.statusCode == 201) {
        if (paymentMethod == 'paystack') {
          final response = await _repo.initializePayment({
            'paymentMethod': 'CreditCard',
            'paymentType': 'Paystack',
            'orderId': res.data['order']['id'],
          });
          if (response.statusCode == 200) {
            await PaystackUtil.processPayment(
              context: context,
              ref: response.data['data']['reference'],
              accessCode: response.data['data']['access_code'],
              url: response.data['data']['authorization_url'],
              amountInNaira: calculatedFinalTotal,
              email: profile.value.email!,
              cartItems: cart.value,
            );
          } else {
            _snackBar.showSnackbar(message: "Payment processing failed", duration: Duration(seconds: 2));
          }
        } else {
          _snackBar.showSnackbar(message: "Order placed successfully", duration: Duration(seconds: 2));
          _navigationService.navigateTo(Routes.paymentSuccessView);
        }
      } else {
        _snackBar.showSnackbar(message: res.data["message"] ?? "Failed to place the order", duration: Duration(seconds: 2));
      }
    } catch (e) {
      _snackBar.showSnackbar(message: "An error occurred during payment: $e", duration: Duration(seconds: 2));
    } finally {
      isPaying = false;
      notifyListeners();
    }
  }

  void updatePaymentMethod(String method) {
    paymentMethod = method;
    notifyListeners();
  }

  void updatePickupOption(PickUpOptions option) {
    pickUpOption = option;
    notifyListeners();
  }

  void updateShippingId(String id) {
    shippingId = id;
    notifyListeners();
  }

  Future<void> showAddAddressBottomSheet() async {
      final newViewModel = ShippingAddressesViewModel();
      await newViewModel.init();
      notifyListeners();


      final response = await _bottomSheetService.showCustomSheet(
          variant: BottomSheetType.addAddressBottom,
          isScrollControlled: true,
          title: 'Add Address',
          data: {
            'viewModel': newViewModel,
          }
      );

        print('calling get shipping after clossing sheet');
        await getShippings();

  }

  void checkPayOnDeliveryEligibility() {
    bool hasLightingProduct = false;
    for (final item in cart.value) {
      if (item.product?.categoryId == 3) {
        hasLightingProduct = true;
        break;
      }
    }

    isPayOnDeliveryDisabled = hasLightingProduct;

    // If Pay on Delivery is disabled, switch to Paystack
    if (isPayOnDeliveryDisabled) {
      updatePaymentMethod('paystack');
    }
    notifyListeners();
  }

}