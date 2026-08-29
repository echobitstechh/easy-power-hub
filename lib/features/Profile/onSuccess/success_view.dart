import 'package:easy_ph/features/Profile/onSuccess/success_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';

import '../../../ui/common/app_colors.dart';

class PaymentSuccessView extends StackedView<PaymentSuccessViewModel> {
  const PaymentSuccessView({super.key});

  @override
  Widget builder(
      BuildContext context,
      PaymentSuccessViewModel viewModel,
      Widget? child,
      ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? kcBlackColor : kcWhiteColor,
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
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : kcBlackColor,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Your order have been placed successfully ',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDarkMode ? Colors.white70 : kcBlackColor,
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
                  onPressed: viewModel.onContinueShopping,
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

  @override
  PaymentSuccessViewModel viewModelBuilder(BuildContext context) =>
      PaymentSuccessViewModel();
}