import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../app/app.locator.dart';
import '../../../core/data/repositories/repository.dart';

class PaymentWebView extends StatefulWidget {
  final String url;
  final String? reference;
  final VoidCallback onSuccess;
  final VoidCallback onFailure;

  const PaymentWebView({
    Key? key,
    required this.url,
    this.reference,
    required this.onSuccess,
    required this.onFailure,
  }) : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isVerifying = false;
  bool _hasHandledResult = false;
  final _repo = locator<Repository>();

  @override
  void initState() {
    super.initState();
    initWebViewController();
  }

  Future<void> _verifyAndComplete(bool isSuccessUrl) async {
    if (_hasHandledResult) return;

    if (widget.reference != null && widget.reference!.isNotEmpty) {
      setState(() => _isVerifying = true);
      try {
        final res = await _repo.verifyTransaction(widget.reference!);
        if (res.statusCode == 200) {
          _hasHandledResult = true;
          if (mounted) Navigator.pop(context);
          widget.onSuccess();
          return;
        }
      } catch (e) {
        debugPrint('Transaction verification error: $e');
      } finally {
        if (mounted) setState(() => _isVerifying = false);
      }
    }

    if (_hasHandledResult) return;
    _hasHandledResult = true;
    if (mounted) Navigator.pop(context);
    if (isSuccessUrl) {
      widget.onSuccess();
    } else {
      widget.onFailure();
    }
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
          onPageFinished: (String url) async {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
            debugPrint('Page finished loading: $url');

            final lowerUrl = url.toLowerCase();
            if (lowerUrl.contains("status=success") ||
                lowerUrl.contains("transaction/success") ||
                (lowerUrl.contains("trxref=") && lowerUrl.contains("reference="))) {
              await _verifyAndComplete(true);
            } else if (lowerUrl.contains("status=failed") ||
                lowerUrl.contains("transaction/failed") ||
                lowerUrl.contains("status=cancelled")) {
              await _verifyAndComplete(false);
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebResourceError: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            final redirectedUrl = request.url;
            debugPrint("Navigating to: $redirectedUrl");

            final uri = Uri.parse(redirectedUrl);

            // Allow all standard HTTP/HTTPS browsing inside WebView (Paystack checkout, 3DS bank pages)
            if (uri.scheme == 'http' || uri.scheme == 'https') {
              return NavigationDecision.navigate;
            }

            // Launch external app schemes (e.g. intent://, kuda://, tel:, etc.)
            launchUrl(uri, mode: LaunchMode.externalApplication).catchError((e) {
              debugPrint('Could not launch external URL: $e');
              return false;
            });
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isVerifying,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Payment"),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading || _isVerifying)
              Container(
                color: Colors.white70,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (_isVerifying) ...[
                        const SizedBox(height: 16),
                        const Text("Verifying payment..."),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
