// Updated OTP Form with input state
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stacked/stacked.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/components/submit_button.dart';
import '../auth_viewmodel.dart';

class OtpForm extends ViewModelWidget<AuthViewModel> {
  const OtpForm({super.key});

  @override
  Widget build(BuildContext context, AuthViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/icons/logo.svg', height: 64),
            const SizedBox(height: 24),
            const Text("Enter OTP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Text("An OTP has been sent to your email"),
            const SizedBox(height: 12),
            Form(
              key: viewModel.otpFormKey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextFormField(
                      controller: viewModel.otpControllers[index],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(counterText: ''),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '';
                        }
                        return null;
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: viewModel.resendOtp,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Resend", style: TextStyle(color: kcSecondaryColor)),
                  Icon(Icons.arrow_forward, size: 16, color: kcSecondaryColor),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SubmitButton(
              isLoading: viewModel.isVerifyingOtp,
              label: "Sign Up",
              color: kcPrimaryColor,
              submit: viewModel.verifyOtp,
            )
          ],
        ),
      ),
    );
  }
}
