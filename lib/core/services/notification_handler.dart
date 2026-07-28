import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../app/app.logger.dart';
import '../../app/app.router.dart';
import '../../state.dart';
import '../data/repositories/repository.dart';

/// Top-level background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // No navigation possible in background isolate; payload is stored
  // and acted on when the user taps the notification.
}

class NotificationHandler {
  static final _nav = locator<NavigationService>();
  static final _repo = locator<Repository>();
  static final _log = getLogger('NotificationHandler');

  /// Call once from main() after Firebase.initializeApp().
  static void initialize() {
    // Foreground messages — show an in-app snackbar
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // User taps notification while app is backgrounded
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // User taps notification that launched the app from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _handleMessageTap(message);
    });

    // Token can rotate at any time (reinstall, restore, periodic refresh by
    // the OS) — resend it whenever that happens so the backend never holds
    // a stale one.
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      if (userLoggedIn.value) _saveToken(newToken);
    });
  }

  /// Returns the FCM token, or null if unavailable.
  /// On iOS, skips FCM entirely when the APNS token hasn't been issued yet —
  /// calling getToken() without an APNS token blocks indefinitely on iOS.
  static Future<String?> getFcmToken() async {
    try {
      await FirebaseMessaging.instance
          .requestPermission(alert: true, badge: true, sound: true);

      if (Platform.isIOS) {
        final apns = await FirebaseMessaging.instance
            .getAPNSToken()
            .timeout(const Duration(seconds: 5), onTimeout: () => null);
        if (apns == null) return null;
      }

      return await FirebaseMessaging.instance
          .getToken()
          .timeout(const Duration(seconds: 8), onTimeout: () => null);
    } catch (e) {
      _log.w('FCM token unavailable (non-fatal): $e');
      return null;
    }
  }

  /// Re-sends the current device's FCM token to the backend. Call this for
  /// any already-authenticated session (app cold start, token rotation) —
  /// login/register/OTP-verify already send it once at auth time, but
  /// nothing previously refreshed it afterward, so a session that stayed
  /// logged in could end up with a null/stale token server-side.
  static Future<void> syncFcmToken() async {
    if (!userLoggedIn.value) return;
    final token = await getFcmToken();
    if (token != null) await _saveToken(token);
  }

  static Future<void> _saveToken(String token) async {
    try {
      await _repo.updateFcmToken({
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
    } catch (e) {
      _log.w('Failed to sync FCM token (non-fatal): $e');
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    // Show in-app banner via snackbar
    final snack = locator<SnackbarService>();
    final title = message.notification?.title ?? 'Easy Power Hub';
    final body = message.notification?.body ?? '';
    snack.showSnackbar(
      message: body.isNotEmpty ? '$title\n$body' : title,
      duration: const Duration(seconds: 4),
    );
  }

  static void _handleMessageTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String? ?? '';

    switch (type) {
      case 'order':
        _nav.navigateTo(Routes.orderList);
        break;
      case 'KYC':
        _nav.navigateTo(Routes.profileView);
        break;
      case 'service_request':
        _nav.navigateTo(Routes.servicesView);
        break;
      default:
        // Unknown type — open home
        _nav.navigateTo(Routes.homeView);
    }
  }
}
