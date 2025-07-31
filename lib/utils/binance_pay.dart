import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app.locator.dart';
import '../core/data/repositories/repository.dart';
import '../core/network/api_response.dart';
import '../state.dart';
import '../ui/components/empty_state.dart';

class BinancePayModal extends StatefulWidget {
  final Map binanceData;
  final List<String> orderIds;
  final AppModules module;

  const BinancePayModal({Key? key, required this.binanceData, required this.orderIds, required this.module}) : super(key: key);

  @override
  _BinancePayModalState createState() => _BinancePayModalState();
}

class _BinancePayModalState extends State<BinancePayModal> {
  bool isModalOpen = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isLoading = true;
      _openBinanceApp(widget.binanceData);
      pollPaymentStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset("assets/images/binance.png", scale: 4),
            if (isLoading)
              const Padding(
              padding: EdgeInsets.all(16.0),
              child: EmptyState(
                animation: "binance_loader.json",
                label: "paying...",
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void pollPaymentStatus() async {
    if (!isModalOpen) {
      return;
    }

    setState(() {
      isLoading = true;
    });
    bool paymentSuccessful = await checkPaymentStatus(widget.orderIds);

    if (paymentSuccessful) {
      Navigator.pop(context);
      setState(() {
        showReceipt(widget.module);
      });

    } else {
      // Payment not successful, continue polling
      Future.delayed(const Duration(seconds: 10), pollPaymentStatus);
    }
  }

  checkPaymentStatus(List<String> orderIds) async {
    try {
      var payload = {
        "orderId": [...orderIds],
        "id": profile.value.id,
      };
      ApiResponse res = await locator<Repository>()
          .getOrdersStatus(payload);
      if (res.statusCode == 200) {
        return false;
      }else{
        return true;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  void showReceipt(AppModules module) {
    // if(module == AppModules.raffle){
    //   List<RaffleCartItem> receiptCart = List<RaffleCartItem>.from(cart.value);
    //   cart.value.clear();
    //   cart.notifyListeners();
    //   List<Map<String, dynamic>> storedList = cart.value.map((e) => e.toJson()).toList();
    //   locator<LocalStorage>().save(LocalStorageDir.raffleCart, storedList);
    //
    //   showModalBottomSheet(
    //     isScrollControlled: true,
    //     isDismissible: false,
    //     backgroundColor: Colors.white,
    //     context: context,
    //     builder: (BuildContext context) {
    //       return RaffleReceiptPage(cart:receiptCart);
    //     },
    //   );
    // }
  }


  Future<void> _openBinanceApp(Map binanceData) async {

    String deeplink = binanceData["deeplink"];
    final Uri deepLinkUri = Uri.parse(deeplink);
    final Uri checkoutUrl = Uri.parse(binanceData["checkoutUrl"]);

    // Check if any app can handle the deep link
    if (await canLaunchUrl(deepLinkUri)) {
      await launchUrl(deepLinkUri, mode: LaunchMode.platformDefault);
    } else {
      // No app found to handle the deep link,continue in browser
      if (!await launchUrl(checkoutUrl, mode: LaunchMode.platformDefault)) {
        // Fallback failed, show an error message
        final snackBarService = locator<SnackbarService>();
        snackBarService.showSnackbar(message: 'Could not open the web browser');
      }
    }
  }

}
