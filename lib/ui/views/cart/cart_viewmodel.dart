import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.logger.dart';
import 'package:easyph/core/data/models/cart_item.dart';
import 'package:easyph/core/data/models/raffle_cart_item.dart';
import 'package:easyph/core/data/repositories/repository.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:easyph/core/utils/config.dart';
import 'package:easyph/core/utils/local_store_dir.dart';
import 'package:easyph/core/utils/local_stotage.dart';
import 'package:easyph/state.dart';
import 'package:easyph/ui/views/cart/raffle_reciept.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/app.dialogs.dart';
import '../../../app/app.router.dart';
import '../../../core/data/models/order_info.dart';
import '../../../utils/binance_pay.dart';
import '../../../utils/money_util.dart';
import 'custom_reciept.dart';

/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class CartViewModel extends BaseViewModel {
  final repo = locator<Repository>();
  final snackBar = locator<SnackbarService>();
  final log = getLogger("CartViewModel");
  List<CartItem> itemsToDeleteRaffle = [];
  int shopSubTotal = 0;
  int raffleSubTotal = 0;
  int deliveryFee = 0;
  int cartSubtotal = 0;
  int cartDiscount = 0;
  int cartFinalTotal = 0;
  bool isLoading = false;
  final refferalCode = TextEditingController();

  ValueNotifier<PaymentMethod> selectedPaymentMethod =
      ValueNotifier(PaymentMethod.flutterwave);
  ValueNotifier<bool> isPaymentProcessing = ValueNotifier(false);

  PaymentMethod get selectedMethod => selectedPaymentMethod.value;

  final bool _isDisposed = false;
  final Map<String, int> selectedInstallments = {}; // productId -> selected frequency


  @override
  void dispose() {
    selectedPaymentMethod.dispose();
    super.dispose();
  }

  void selectMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
    notifyListeners(); // Notify overall ViewModel listeners
  }

  void removeItem(CartItem item) async {

    //print('wee2 ${item.product?.id}');
    await repo.deleteFromCart(item.product!.id.toString())
        .then((value) async {
    //  print('wee3');
      itemsToDeleteRaffle.remove(item);
      cart.value.remove(item);
      cart.notifyListeners();
     // print('wee4');
      await refreshData();
    })
        .catchError((e) {
    // show error: Error in deleting item from cart
     // print('wee5');
    });
  }

  void addRemoveDeleteRaffle(CartItem item) async {
      itemsToDeleteRaffle.contains(item)
          ? itemsToDeleteRaffle.remove(item)
          : itemsToDeleteRaffle.add(item);


    rebuildUi();
    notifyListeners();
  }

  Future<void> refreshData() async {
    setBusy(true);
    notifyListeners();
    // getResourceList();
    fetchOnlineCart();
    setBusy(false);
    notifyListeners();
  }

  void modifyCartQuantity(CartItem item, String action) async {
    setBusy(true);
    try {
      ApiResponse res = await repo.modifyCartItem(item.product!.id.toString(), action);

      if (res.statusCode == 200) {
        if (action == "increment") {
          item.quantity = item.quantity! + 1;
        } else if (action == "decrement" && item.quantity! > 1) {
          item.quantity = item.quantity! - 1;
        }

        getRaffleSubTotal();
        await refreshData();
        cart.notifyListeners();
      } else {
        snackBar.showSnackbar(message: "Failed to update cart: ${res.data['message']}");
      }
    } catch (e) {
      log.e("Cart modification error: $e");
      snackBar.showSnackbar(message: "An error occurred while updating the cart");
    } finally {
      setBusy(false);
    }
  }

  void clearRaffleCart(int index) async {
    setBusy(true);
    try {
      print('about to clear cart');
      // Remove from the online cart
      ApiResponse res = await repo.clearCart();
      if (res.statusCode == 200) {
        // Clear the local cart
        cart.value.clear(); // Use clear() with parentheses
        print('cleared cart');
        cart.notifyListeners(); // Notify listeners to update the UI
        List<Map<String, dynamic>> storedList =
            cart.value.map((e) => e.toJson()).toList();
        await locator<LocalStorage>()
            .save(LocalStorageDir.raffleCart, storedList);

        getRaffleSubTotal();
        rebuildUi(); // Ensure UI rebuilds properly
      } else {
        snackBar.showSnackbar(
            message:
                "Failed to delete items from cart: ${res.data['message']}");
      }
    } catch (e) {
      log.e(e);
      snackBar.showSnackbar(
          message: "An error occurred while clearing the cart: $e");
    } finally {
      setBusy(false);
    }
  }

  void getRaffleSubTotal() {
    int total = 0;

    for (var element in cart.value) {
      final product = element.product;

      // Convert ticketPrice from String to double, defaulting to 0 if ticketPrice is null
      final ticketPrice =
          product?.salePrice != null ? double.parse(product!.salePrice!) : 0;

      // Multiply ticketPrice by quantity and cast to int
      total += (ticketPrice * element.quantity!).toInt();
    }

    raffleSubTotal = total;
    rebuildUi();
  }

  Future<void> fetchOnlineCart() async {
    setBusy(true);
    isLoading = true;
    try {
      ApiResponse res = await repo.cartList();
      if (res.statusCode == 200) {
        List<dynamic> items = res.data["cartItems"] ?? [];
        Map<String, dynamic> summary = res.data["summary"] ?? {};

        cartSubtotal = summary["totalPrice"] ?? 0;
        cartDiscount = summary["discountAmount"] ?? 0;
        cartFinalTotal = summary["finalPrice"] ?? 0;

        if (items.isNotEmpty) {
          List<CartItem> onlineItems = items
              .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          cart.value = onlineItems;
          await locator<LocalStorage>().save(LocalStorageDir.raffleCart, onlineItems.map((e) => e.toJson()).toList());
          cart.notifyListeners();
          notifyListeners();
        } else {
          cart.value.clear();
          await locator<LocalStorage>().delete(LocalStorageDir.raffleCart);
          notifyListeners();
    }
    }
    } catch (e) {
      locator<SnackbarService>()
          .showSnackbar(message: "Failed to load cart from server: $e");
      print('Couldn\'t get online cart: $e');
    } finally {
      setBusy(false);
      cart.notifyListeners();
      isLoading = false;
    }
  }

  Future<void> selectInstallmentOption(CartItem item, int frequency) async {
    try {
      selectedInstallments[item.product!.id!] = frequency;
      item.installmentFrequency = frequency;
      notifyListeners();

      final res = await repo.modifyCartItem(item.product!.id!, "installment", newFrequency: frequency);

      if (res.statusCode == 200) {
        await refreshData();
      } else {
        snackBar.showSnackbar(message: res.data["message"] ?? "Failed to update installment");
      }
    } catch (e) {
      snackBar.showSnackbar(message: "An error occurred: $e");
    }
  }

}
