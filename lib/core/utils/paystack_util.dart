import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../app/app.router.dart';
import '../../features/Profile/onSuccess/success_view.dart';
import '../../ui/dialogs/info_alert/payment_modal.dart';
import '../data/models/cart_item.dart';

class PaystackUtil {


  static Future<bool> processPayment({
    required BuildContext context,
    required int amountInNaira,
    required String email,
    required String ref,
    required List<CartItem> cartItems,
    String? accessCode,
    String? url,
  }) async {


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
                // builder: (_) => RaffleReceiptPage(
                //   carts: cartItems,
                //   totalAmount: amountInNaira,
                // ),
                builder: (context) => const PaymentSuccessView(),
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
