import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.router.dart';

import '../../ui/dialogs/payment_modal.dart';
import '../../ui/views/cart/raffle_reciept.dart';
import '../data/models/cart_item.dart';

class PaystackUtil {
  //static final _plugin = PaystackPlugin();


  static void initialize(String publicKey) {
   // _plugin.initialize(publicKey: publicKey);
  }

  static Future<bool> processPayment({
    required BuildContext context,
    required int amountInNaira,
    required String email,
    required String ref,
    required List<CartItem> cartItems,
    String? accessCode,
    String? url,
  }) async {
    
    print('processing url is $url');

    if (url == null || url.isEmpty) {
      locator<SnackbarService>().showSnackbar(
        message: "Invalid payment URL.",
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentWebView(
          url: url,
          onSuccess: () {
            locator<SnackbarService>().showSnackbar(
              message: "Payment successful!",
              duration: const Duration(seconds: 2),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => RaffleReceiptPage(
                  carts: cartItems,
                  totalAmount: amountInNaira,
                ),
              ),
            );
          },
          onFailure: () {
            locator<SnackbarService>().showSnackbar(
              message: "Payment failed. Please try again.",
              duration: const Duration(seconds: 2),
            );
            locator<NavigationService>().clearStackAndShow(Routes.homeView);
            locator<NavigationService>().navigateTo(Routes.orderList);
          },
        ),
      ),
    );

    return result ?? false;
  }
}
