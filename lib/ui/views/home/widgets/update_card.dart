import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easyph/core/utils/config.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateCardDialog extends StatelessWidget {
  const UpdateCardDialog({super.key});

  void _launchURL(BuildContext context) async {
    final url = Platform.isIOS ? AppConfig.APPLESTOREURL : AppConfig.GOOGLESTOREURL;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                'A new version of Easy PH is now available. download now to enjoy our lastest features.',
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
                  onPressed: () => _launchURL(context),
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