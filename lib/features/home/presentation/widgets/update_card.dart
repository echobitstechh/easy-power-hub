import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/config.dart';
import '../../../../ui/common/app_colors.dart';

class UpdateCard extends StatelessWidget {
  const UpdateCard({super.key});

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(
              'assets/icons/update.svg',
              height: 94,
            ),
            const ListTile(
              title: Text(
                'App Updates',
                style: TextStyle(
                    fontSize: 22,
                    fontFamily: "Panchang",
                    fontWeight: FontWeight.bold,
                    color: kcSecondaryColor),
              ),
              subtitle: Text(
                'A new version of WahalaHQ is now available. Download now to enjoy our latest features.',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: "Panchang",
                ),
              ),
            ),
            ButtonBar(
              children: <Widget>[
                TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(kcSecondaryColor)),
                  onPressed: () {
                    final url = Platform.isIOS
                        ? AppConfig.appleStoreUrl
                        : AppConfig.playStoreUrl;
                    _launchURL(url);
                    Navigator.pop(context);
                  },
                  child: const Text('Update Now',
                      style: TextStyle(
                          fontFamily: "Panchang",
                          fontWeight: FontWeight.bold,
                          color: kcWhiteColor)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
