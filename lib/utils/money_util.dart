import 'package:easyph/core/utils/config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:intl/intl.dart';
import 'package:stacked_services/stacked_services.dart';
import 'dart:io';

import '../app/app.locator.dart';
import '../core/data/repositories/repository.dart';
import '../core/network/api_response.dart';
import '../state.dart';
import 'flutterwave-service.dart';

class MoneyUtils extends TextInputFormatter {
  String payStackPublicKey = 'pk_test_aae035e8425d5319b6500ef86c0472474a38a5fd';
  // final plugin = PaystackPlugin();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue
      ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String newText = newValue.text.replaceAll(',', '');

    if (int.tryParse(newText) != null) {
      newText = NumberFormat("#,##0", "en_US").format(int.parse(newText));
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }



  String formatAmount(int amount) {
    final formatter = NumberFormat("#,##0", "en_US");

    return "₦${formatter.format(amount)}";
  }

  int getRate(int amount) {
    final formatter = NumberFormat("#,##0", "en_US");

    amount =  1450 * amount;
    return amount;
  }

  String formatAmountToDollars(int amount) {
    final formatter = NumberFormat("#,##0", "en_US");

    return "\$${formatter.format(amount)}";
  }

  String getReference() {
    var platform = (Platform.isIOS) ? 'iOS' : 'Android';
    final thisDate = DateTime.now().millisecondsSinceEpoch;
    return 'ChargedFrom${platform}_$thisDate';
  }

  int getAmountAsInt(TextEditingController amount) {
    String text = amount.text.replaceAll(',', ''); // Remove commas
    return int.tryParse(text) ?? 0; // Convert to int, return 0 if null
  }

  Future<ApiResponse> chargeCardUtil(PaymentMethod paymentMethod, BuildContext context, int amount, String orderId) async {


    // Handle Paystack payment
    // if (paymentMethod == PaymentMethod.paystack) {
    //   var charge = Charge()
    //     ..amount = amount * 100  // Convert to kobo
    //     ..reference = orderId
    //     ..email = profile.value.email;
    //
    //   plugin.initialize(publicKey: AppConfig.paystackApiKeyTest);
    //   CheckoutResponse checkoutResponse = await plugin.checkout(
    //     context,
    //     method: CheckoutMethod.card,
    //     charge: charge,
    //   );
    //
    //   if (checkoutResponse.status == true) {
    //     var successResponse = Response(
    //       requestOptions: RequestOptions(path: ''),
    //       data: checkoutResponse.message,
    //       statusCode: 200,
    //     );
    //     return ApiResponse(successResponse);
    //   } else {
    //     // Create a fake response to wrap the error message
    //     var errorResponse = Response(
    //       requestOptions: RequestOptions(path: ''),
    //       data: checkoutResponse.message,
    //       statusCode: 500,
    //     );
    //     return ApiResponse(errorResponse);
    //   }
    // }

    // Handle flutterwave payment
    if (paymentMethod == PaymentMethod.flutterwave) {
      // Assuming amount, currency, and customer email are passed as parameters
      final FlutterwavePaymentService paymentService = FlutterwavePaymentService();
      ChargeResponse response = await paymentService.makePayment(
        context: context,
        amount: amount.toString(),
        isTestMode: AppConfig.isTestMode,
        reference: orderId
      );

      if (response.success == true || response.status == 'completed') {
        print('flutterwave response was success');
        var successResponse = Response(
          requestOptions: RequestOptions(path: ''),
          data: response.transactionId,
          statusCode: 200,
        );
        return ApiResponse(successResponse);
      }else{
        print('flutterwave payment was different ${response.success}');
        locator<SnackbarService>().showSnackbar(message: response.status ?? 'flutterwave payment failed');
      }
    }


    var defaultResponse = Response(
      requestOptions: RequestOptions(path: ''),
      data: "Payment method not supported",
      statusCode: 500,
    );
    return ApiResponse(defaultResponse);
  }


  int getPaymentMethodCode(PaymentMethod paymentMethod) {
    switch (paymentMethod) {
      case PaymentMethod.wallet:
        return 1;
      case PaymentMethod.paystack:
        return 2;
      // case PaymentMethod.binancePay:
      //   return 3;
      case PaymentMethod.flutterwave:
        return 4;
      default:
        return 0;
    }
  }

}
