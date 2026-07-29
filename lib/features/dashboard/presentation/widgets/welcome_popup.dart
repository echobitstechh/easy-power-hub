import 'package:flutter/material.dart';

import '../../../../ui/common/app_colors.dart';
import '../dashboard_viewmodel.dart';

/// One-time offer popup shown on first home visit, matching web's welcome
/// dialog. Dismissing it sets a permanent local flag so it never shows again.
class WelcomePopup extends StatelessWidget {
  final DashboardViewModel viewModel;

  const WelcomePopup({super.key, required this.viewModel});

  static Future<void> show(BuildContext context, DashboardViewModel viewModel) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => WelcomePopup(viewModel: viewModel),
    ).then((_) => viewModel.dismissWelcomePopup());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration_rounded, color: kcPrimaryColor, size: 44),
            const SizedBox(height: 12),
            const Text(
              'Special Offer!',
              style: TextStyle(fontFamily: 'HostGrotesk',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Free Delivery Rules Updated — enjoy FREE delivery when you '
              'purchase 3+ Electronics products. Valid in Abuja and Lagos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
