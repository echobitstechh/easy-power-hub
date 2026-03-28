import 'package:easy_ph/ui/common/app_colors.dart';
import 'package:easy_ph/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';

class SavingsSuccessView extends StatelessWidget {
  final String message;
  const SavingsSuccessView({Key? key, this.message = "Payment Successful!"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 60, color: Colors.white),
              ),
              verticalSpaceLarge,
              const Text(
                "Success!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              verticalSpaceSmall,
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              verticalSpaceLarge,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => locator<NavigationService>().back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kcOrangeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Continue",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
