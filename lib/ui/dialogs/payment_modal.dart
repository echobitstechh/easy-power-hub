import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:easyph/app/app.locator.dart';

class PaymentWebView extends StatefulWidget {
  final String url;
  final VoidCallback onSuccess;
  final VoidCallback onFailure;

  const PaymentWebView({
    Key? key,
    required this.url,
    required this.onSuccess,
    required this.onFailure,
  }) : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  final snackbarService = locator<SnackbarService>();

  @override
  void initState() {
    super.initState();
    initWebViewController();
  }

  void initWebViewController() {
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            debugPrint('Page finished loading: $url');

            if (url.contains("status=success") || url.contains("transaction/success")) {
              widget.onSuccess();
              Navigator.pop(context); // Close the webview
            } else if (url.contains("status=failed") || url.contains("transaction/failed")) {
              widget.onFailure();
              Navigator.pop(context); // Close the webview
            }
          },
          onWebResourceError: (WebResourceError error) {
            snackbarService.showSnackbar(
              message: "An error occurred: ${error.description}",
              duration: const Duration(seconds: 3),
            );
            widget.onFailure();
            Navigator.pop(context);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
