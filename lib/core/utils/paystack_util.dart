import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:easyph/utils/money_util.dart';
import 'package:easyph/core/data/models/profile.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.router.dart';

import '../../ui/views/cart/raffle_reciept.dart';
import '../data/models/cart_item.dart';

class PaystackUtil {
  static final _plugin = PaystackPlugin();


  static void initialize(String publicKey) {
    _plugin.initialize(publicKey: publicKey);
  }


  static Future<bool> processPayment({
    required BuildContext context,
    required int amountInNaira,
    required String email,
    required String ref,
    required List<CartItem> cartItems,
    required int deliveryFee,
  }) async {
    final charge = Charge()
      ..amount = (amountInNaira + deliveryFee) * 100 // Paystack expects kobo
      ..reference = ref
      ..email = email;

    final response = await _plugin.checkout(
      context,
      method: CheckoutMethod.card,
      charge: charge,
    );

    if (response.status == true) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RaffleReceiptPage(
            carts: cartItems,
            totalAmount: amountInNaira,
          ),
        ),
      );
      return true;
    } else {
      locator<SnackbarService>().showSnackbar(
        message: "Payment failed. Please try again.",
        duration: const Duration(seconds: 2),
      );

      locator<NavigationService>().clearStackAndShow(Routes.homeView);

      Future.delayed(const Duration(milliseconds: 200), () {
        locator<NavigationService>().navigateTo(
          Routes.orderView,
          transition: (context, animation, secondaryAnimation, child) => child,
        );
      });

      return false;
    }
  }
}
