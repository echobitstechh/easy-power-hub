import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:app_links/app_links.dart';
import 'app.router.dart';
import 'app.locator.dart';

class DeepLinkHandler {
  static final AppLinks _appLinks = AppLinks();
  static bool _isInitialized = false;
  static StreamSubscription<Uri>? _linkSubscription;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      developer.log('🔗 Initializing deep link handler...', name: 'DeepLink');

      await _handleInitialDeepLink();

      _listenToDeepLinks();

      _isInitialized = true;
      developer.log('Deep link handler initialized successfully', name: 'DeepLink');

    } catch (error, stackTrace) {
      developer.log('Failed to initialize deep link handler: $error',
          name: 'DeepLink', error: error, stackTrace: stackTrace);

      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Failed to initialize deep link handler',
      );
    }
  }

  static Future<void> _handleInitialDeepLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        developer.log('📱 Initial deep link received: ${uri.toString()}', name: 'DeepLink');
        await _navigateFromUri(uri);
      }
    } catch (error, stackTrace) {
      developer.log('Failed to handle initial deep link: $error',
          name: 'DeepLink', error: error, stackTrace: stackTrace);

      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Failed to handle initial deep link',
        printDetails: true,
      );
    }
  }

  static void _listenToDeepLinks() {
    try {
      _linkSubscription = _appLinks.uriLinkStream.listen(
            (uri) {
          developer.log('🔗 Deep link received: ${uri.toString()}', name: 'DeepLink');
          _navigateFromUri(uri);
        },
        onError: (error, stackTrace) {
          developer.log('Deep link stream error: $error',
              name: 'DeepLink', error: error, stackTrace: stackTrace);

          FirebaseCrashlytics.instance.recordError(
            error,
            stackTrace ?? StackTrace.current,
            reason: 'Deep link stream error',
          );
        },
      );
    } catch (error, stackTrace) {
      developer.log('Failed to setup deep link listener: $error',
          name: 'DeepLink', error: error, stackTrace: stackTrace);

      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Failed to setup deep link listener',
      );
    }
  }

  static Future<void> _navigateFromUri(Uri uri) async {
    try {
      final host = uri.host.toLowerCase();
      final path = uri.path;
      final queryParams = uri.queryParameters;

      developer.log('🧭 Processing deep link - Host: $host, Path: $path', name: 'DeepLink');

      await FirebaseCrashlytics.instance.setCustomKey('last_deep_link_host', host);
      await FirebaseCrashlytics.instance.setCustomKey('last_deep_link_path', path);
      await FirebaseCrashlytics.instance.setCustomKey('last_deep_link_full', uri.toString());

      if (host.contains("payment-success")) {
        developer.log('Payment success deep link detected', name: 'DeepLink');
        _navigateToPaymentSuccess(queryParams);

      } else if (host.contains("payment-failed")) {
        developer.log('💳 Payment failed deep link detected', name: 'DeepLink');
        _navigateToPaymentFailed(queryParams);

      } else {
        developer.log(' Unknown deep link pattern: ${uri.toString()}', name: 'DeepLink');
        _handleUnknownDeepLink(uri);
      }

    } catch (error, stackTrace) {
      developer.log('Failed to navigate from deep link: $error',
          name: 'DeepLink', error: error, stackTrace: stackTrace);

      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Failed to navigate from deep link: ${uri.toString()}',
        printDetails: true,
      );
    }
  }

  static void _navigateToPaymentSuccess(Map<String, String> queryParams) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        locator<NavigationService>().clearStackAndShow(
          Routes.paymentSuccessPage,
          arguments: queryParams,
        );
        developer.log('Navigated to payment success page', name: 'DeepLink');
      } catch (error) {
        developer.log('Failed to navigate to payment success: $error', name: 'DeepLink');
      }
    });
  }

  static void _navigateToPaymentFailed(Map<String, String> queryParams) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        locator<NavigationService>().clearStackAndShow(
          Routes.orderList,
          arguments: queryParams,
        );
        developer.log('Navigated to order list after payment failure', name: 'DeepLink');
      } catch (error) {
        developer.log('Failed to navigate after payment failure: $error', name: 'DeepLink');
      }
    });
  }

  static void _handleUnknownDeepLink(Uri uri) {
    developer.log('Unknown deep link, navigating to home', name: 'DeepLink');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        locator<NavigationService>().clearStackAndShow(Routes.startupView);
      } catch (error) {
        developer.log(' Failed to navigate to home: $error', name: 'DeepLink');
      }
    });
  }

  static Future<void> handleDeepLink(String url) async {
    try {
      final uri = Uri.parse(url);
      await _navigateFromUri(uri);
    } catch (error, stackTrace) {
      developer.log('Failed to handle manual deep link: $error',
          name: 'DeepLink', error: error, stackTrace: stackTrace);
    }
  }

  static Future<bool> canHandleDeepLinks() async {
    try {
      await _appLinks.getInitialLink();
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<void> dispose() async {
    try {
      await _linkSubscription?.cancel();
      _linkSubscription = null;
      _isInitialized = false;
      developer.log('Deep link handler disposed', name: 'DeepLink');
    } catch (error) {
      developer.log('Error disposing deep link handler: $error', name: 'DeepLink');
    }
  }

  static void resumeListening() {
    if (_isInitialized) {
      _listenToDeepLinks();
      developer.log('Deep link listening resumed', name: 'DeepLink');
    }
  }
}