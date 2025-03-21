import 'package:easyph/app/app.locator.dart';
import 'package:easyph/core/data/repositories/repository.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentView extends StatefulWidget {
  final String url;
  final bool isPayForOrder;

  const PaymentView({
    Key? key,
    required this.url,
    this.isPayForOrder = false,
  }) : super(key: key);

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  late WebViewController controller;

  @override
  void initState() {
    initWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }

  initWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            const Center(
              child: CircularProgressIndicator(),
            );
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {
            if (url.contains("trxref")) {
              Uri uri = Uri.parse(url);
              String? trxref = uri.queryParameters['trxref'];

              if (widget.isPayForOrder) {
                locator<NavigationService>().back(result: true);
              } else {
                await locator<Repository>().verifyTransaction(trxref!);
                locator<NavigationService>().popRepeated(3);
              }
            }
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }
}
