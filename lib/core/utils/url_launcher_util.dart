// lib/core/utils/url_launcher_util.dart

import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/app.locator.dart';

class UrlLauncherUtil {
  static final _snackBar = locator<SnackbarService>();

  /// Launches a URL in the phone's default browser or app.
  static Future<void> launchUrl(Uri url) async {
    if (!await canLaunchUrl(url)) {
      _snackBar.showSnackbar(message: "Could not launch URL.");
    } else {
      await launchUrl(url);
    }
  }

  /// Launches the phone's dialer with a phone number.
  static Future<void> launchDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(phoneUri);
  }
}