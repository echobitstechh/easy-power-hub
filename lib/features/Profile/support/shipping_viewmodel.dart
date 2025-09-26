import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../core/utils/url_launcher_util.dart';

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

  // _sendEmail now gets the context from the NavigationService
  Future<void> _sendEmail() async {
    EmailContent email = EmailContent(
      to: [
        "support@easyph.com",
      ],
      bcc: ['dev@easyph.com', 'support@echobitstech.com'],
    );

    final context = _navigationService.navigatorKey?.currentContext;

    if (context != null) {
      OpenMailAppResult result =
      await OpenMailApp.composeNewEmailInMailApp(
          nativePickerTitle: 'Select email app to compose',
          emailContent: email);
      if (!result.didOpen && !result.canOpen) {
        _snackBar.showSnackbar(message: 'Could not launch email app.');
      } else if (!result.didOpen && result.canOpen) {
        showDialog(
          context: context,
          builder: (_) => MailAppPickerDialog(
            mailApps: result.options,
            emailContent: email,
          ),
        );
      }
    }
  }

  // void _launchFaqs(String url) async {
  //   await UrlLauncherUtil.launchUrl(Uri.parse(url));
  // }

  Future<void> _launchFaqs() async {
    EmailContent email = EmailContent(
      to: [
        'marketing@easypowerhub.com',
        'support@echobitstech.com'
      ],
      bcc: ['dev@easyph.com', 'echobitstech@gmail.com'],
    );

    OpenMailAppResult result =
    await OpenMailApp.composeNewEmailInMailApp(
        nativePickerTitle: 'Select email app to compose',
        emailContent: email);
    if (!result.didOpen && !result.canOpen) {
      _snackBar.showSnackbar(message: 'Could not launch email app.');
    } else if (!result.didOpen && result.canOpen) {
      final context = StackedService.navigatorKey?.currentContext;
      if (context != null) {
        showDialog(
          context: context,
          builder: (_) => MailAppPickerDialog(
            mailApps: result.options,
            emailContent: email,
          ),
        );
      }

    }
  }


  void _launchDialer(String phoneNumber) async {
      final res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      if (res != true) {
        _snackBar.showSnackbar(message: 'Could not launch dialer.');
      }
  }
}