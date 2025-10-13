import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:open_mail/open_mail.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';

class SupportViewModel extends BaseViewModel {
  final _snackBar = locator<SnackbarService>();
  final _navigationService = locator<NavigationService>();

  late final List<Map<String, dynamic>> supportOptions;

  SupportViewModel() {
    // The actions no longer take a BuildContext directly.
    supportOptions = [
      {
        'icon': Icons.email_outlined,
        'title': 'Email Us',
        'subtitle': 'support@easyph.com',
        'action': () => _sendEmail(), // Corrected function call
      },
      // {
      //   'icon': Icons.help_outline,
      //   'title': 'FAQs',
      //   'subtitle': 'Find answers to common questions',
      //   'action': () => _launchFaqs(),
      // },
      {
        'icon': Icons.phone,
        'title': 'Electronics Customer Care',
        'subtitle': '08081099871',
        'action': () => _launchDialer('08081099871'),
      },
      {
        'icon': Icons.phone,
        'title': 'Lighting Customer Care',
        'subtitle': '09059114923',
        'action': () => _launchDialer('09059114923'),
      },
    ];
  }

  Future<void> _sendEmail() async {
    final context = _navigationService.navigatorKey?.currentContext;

    if (context == null) {
      _snackBar.showSnackbar(message: 'Unable to get current context.');
      return;
    }

    try {
      // Compose email content
      final emailData = EmailContent(
        to: ['support@easyph.com'],
        bcc: ['dev@easyph.com', 'support@echobitstech.com'],
        subject: 'Support Request',
        body: 'Hi, I need help with...',
      );

      // Try to open directly
      final emailResult = await OpenMail.composeNewEmailInMailApp(
        emailContent: emailData,
        nativePickerTitle: 'Select an email app',
      );

      if (!emailResult.didOpen && !emailResult.canOpen) {
        _snackBar.showSnackbar(message: 'No mail app found on device.');
      }else{
        _snackBar.showSnackbar(message: 'Email sent successfully.');
      }
    } catch (e) {
      _snackBar.showSnackbar(message: 'Error opening mail app: $e');
    }
  }

  // void _launchFaqs(String url) async {
  //   await UrlLauncherUtil.launchUrl(Uri.parse(url));
  // }

  void _launchDialer(String phoneNumber) async {
      final res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      if (res != true) {
        _snackBar.showSnackbar(message: 'Could not launch dialer.');
      }
  }
}