import 'package:afriprize/app/app.locator.dart';
import 'package:afriprize/app/app.logger.dart';
import 'package:afriprize/core/data/models/cart_item.dart';
import 'package:afriprize/core/data/models/raffle_cart_item.dart';
import 'package:afriprize/core/data/repositories/repository.dart';
import 'package:afriprize/core/network/api_response.dart';
import 'package:afriprize/core/utils/config.dart';
import 'package:afriprize/core/utils/local_store_dir.dart';
import 'package:afriprize/core/utils/local_stotage.dart';
import 'package:afriprize/state.dart';
import 'package:afriprize/ui/views/cart/raffle_reciept.dart';
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
  final refferalCode = TextEditingController();

  ValueNotifier<PaymentMethod> selectedPaymentMethod =
      ValueNotifier(PaymentMethod.flutterwave);
  ValueNotifier<bool> isPaymentProcessing = ValueNotifier(false);

  PaymentMethod get selectedMethod => selectedPaymentMethod.value;

  final bool _isDisposed = false;

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
    setBusy(false);
    notifyListeners();
  }

  // void clearRaffleCart() async{
  //   for (var element in itemsToDeleteRaffle) {
  //     raffleCart.value.remove(element);
  //   }
  //   itemsToDelete.clear();
  //   raffleCart.notifyListeners();
  //   List<Map<String, dynamic>> storedList =
  //   raffleCart.value.map((e) => e.toJson()).toList();
  //   await locator<LocalStorage>().save(LocalStorageDir.raffleCart, storedList);
  //   rebuildUi();
  //   getRaffleSubTotal();
  // }

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
          product?.price != null ? double.parse(product!.price!) : 0;

      // Multiply ticketPrice by quantity and cast to int
      total += (ticketPrice * element.quantity!).toInt();
    }

    raffleSubTotal = total;
    rebuildUi();
  }

  void checkoutRaffle(BuildContext context) async {
    if (cart.value.isEmpty) {
      return null;
    }
    isPaymentProcessing.value = true;
    setBusy(true);
    try {
      ApiResponse res =
          await repo.saveOrder({"payment_method": selectedMethod.name});
      if (res.statusCode == 201) {
        // String paymentLink = res.data['data']['payment_link'];
        String orderId = res.data['data']['order']['_id'];
        print('oder id $orderId');
        // final Uri toLaunch = Uri.parse(paymentLink);

        // if (!await launchUrl(toLaunch, mode: LaunchMode.inAppBrowserView)) {
        //   snackBar.showSnackbar(message: "Could not launch payment link");
        //   throw Exception('Could not launch $paymentLink');
        // }
        processPayment(selectedMethod, context, AppModules.raffle, orderId);
      } else {
        snackBar.showSnackbar(message: res.data["message"]);
        isPaymentProcessing.value = false;
        notifyListeners();
      }
    } catch (e) {
      log.e(e);
      snackBar.showSnackbar(message: 'network error, try again');
      isPaymentProcessing.value = false;
      notifyListeners();
    }
  }

  processPayment(PaymentMethod paymentMethod, BuildContext context,
      AppModules module, String orderId) async {
    // Calculate the amount
    int amount = raffleSubTotal;

    try {
      ApiResponse res = await MoneyUtils()
          .chargeCardUtil(paymentMethod, context, amount, orderId);

      if (res.statusCode == 200) {
        Navigator.pop(context);
        showReceipt(module, context);
      } else {
        Navigator.pop(context);
        locator<SnackbarService>().showSnackbar(message: res.data["message"]);
        locator<NavigationService>().replaceWithHomeView();
      }
    } catch (e) {
      log.e(e);
    } finally {
      isPaymentProcessing.value = false;
      setBusy(false);
    }
  }

  Future<void> showReceipt(AppModules module, BuildContext context) async {
    if (module == AppModules.raffle) {
      List<CartItem> receiptCart = List<CartItem>.from(cart.value);

      cart.notifyListeners();
      List<Map<String, dynamic>> storedList =
          cart.value.map((e) => e.toJson()).toList();
      locator<LocalStorage>().save(LocalStorageDir.raffleCart, storedList);

      showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: false,
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext context) {
          return RaffleReceiptPage(carts: receiptCart);
        },
      );
      cart.value.clear();
      // clearRaffleCart();
      await repo.clearCart();
    }
  }

  Future<void> fetchOnlineCart() async {
    setBusy(true);
    try {
      ApiResponse res = await repo.cartList();
      if (res.statusCode == 200) {
        // Corrected the key to "cartItems" and added a null check
        List<dynamic> items = res.data["cartItems"] ?? [];

        print('online cart items: $items');

        // Map the items list to List<CartItem>
        if (items.isNotEmpty) {
          List<CartItem> onlineItems = items
              .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
              .toList();

          print('Saved items are: ${onlineItems.first.product?.productName}');

          // Sync online items with the local cart
          cart.value = onlineItems;
          getRaffleSubTotal();
          notifyListeners();
          print(
              'Saved raffle cart are: ${cart.value.first.product?.productName}');

          // Update local storage
          List<Map<String, dynamic>> storedList =
              cart.value.map((e) => e.toJson()).toList();
          await locator<LocalStorage>()
              .save(LocalStorageDir.raffleCart, storedList);
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
    }
  }

  // Future<void> loadPayStackPlugin() async{
  //   final plugin = PaystackPlugin();
  //   plugin.initialize(publicKey: AppConfig.paystackApiKeyTest);
  // }
}
