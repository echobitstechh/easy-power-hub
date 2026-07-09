import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../app/app.router.dart';

/// Top-level background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // No navigation possible in background isolate; payload is stored
  // and acted on when the user taps the notification.
}

class NotificationHandler {
  static final _nav = locator<NavigationService>();

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
