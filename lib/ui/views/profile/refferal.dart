import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:share_plus/share_plus.dart';

import '../../../core/data/models/discount.dart';
import '../../common/app_colors.dart';


class Referral extends StatefulWidget {
  const Referral({super.key});

  @override
  State<Referral> createState() => _ReferralState();
}


class _ReferralState extends State<Referral> {

  Discount? discount;

  @override
  void initState() {
    getDiscount();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referrals'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: kcPrimaryColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Image.asset(
                "assets/images/ref_new.png",
                fit: BoxFit.cover,
              ),
            ),
            verticalSpaceSmall,
            if (discount != null)
              DottedBorder(
                borderType: BorderType.RRect,
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                radius: const Radius.circular(12),
                dashPattern: const [6, 3], // Dash pattern for the dotted border
                color: Colors.grey, // Color of the dotted border
                child: Container(
                  width: double.infinity, // The container takes full width
                  margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Referral Code',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 10,
                        ),
                      ),
                      verticalSpaceTiny,
                      SelectableText(
                        discount!.referralCode ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Clipboard.setData( ClipboardData(text: discount!.referralCode ?? ''));
                              // Optionally, show a snackbar or a toast message
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Tap to Copy', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),),
                                SizedBox(width: 8),
                                Icon(Icons.copy, color: kcSecondaryColor, size: 14), // Icon for copy action
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              shareReferralCode();
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Share Code', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),),
                                SizedBox(width: 8),
                                Icon(Icons.share, color: kcSecondaryColor, size: 14),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            if (discount != null)
              Card(
                elevation: 4,
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'If your friend / family uses your referral Code during checkout, you get 1 free Ticket on any of the available raffles.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      verticalSpaceSmall,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // _buildInfoCard('Your Earnings', 'NGN ${discount!.referrerBonus ?? '0.0'}'),
                          _buildInfoCard('Referral Count', '${discount!.usageCount ?? '0'}'),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            // Add additional content here
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.monetization_on, size: 40, color: kcSecondaryColor,),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }

  void getDiscount() async {
      // discount = profile.value.discounts?.first;
  }

  void shareReferralCode() {
    final String referralCode = discount!.referralCode ?? '';
    // final String profileName = profile.value.firstname ?? 'Your friend'; // Make sure you have a profile name
    // final String shareText = "Hello! $profileName has shared you their Easyph referral code $referralCode, buy a ticket with their code to give them a chance at a free ticket.";
    final String shareText =
        "Sharing is caring, but winning is better! Use my code $referralCode"
        " when you sign up for Easyph and get a head start on winning!"
        " #Easyph #FriendsWhoRaffleTogether. https://staging.easyph.com";


    //Share.share(shareText, subject: 'Easyph: where losing is (almost) impossible!');
  }

}