import 'package:easyph/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easyph/ui/common/app_colors.dart'; // adjust if needed
import 'package:easyph/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uiMode.value == AppUiModes.dark
          ? kcBlackColor
          : kcWhiteColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            SvgPicture.asset(
              'assets/icons/happy_bags.svg',
              height: 180,
            ),
            const SizedBox(height: 24),
            Text(
              'Success!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: uiMode.value == AppUiModes.dark ? Colors.white : kcBlackColor,
              ),
            ),
            const SizedBox(height: 12),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Your order will be delivered soon.\nThank you for choosing our app!',
                style: TextStyle(
                  fontSize: 16,
                  color: uiMode.value == AppUiModes.dark ? Colors.white70 : kcBlackColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kcSecondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    locator<NavigationService>().clearStackAndShow(Routes.homeView);
                  },
                  child: const Text(
                    'CONTINUE SHOPPING',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
