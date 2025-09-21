
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../../state.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../../../../ui/components/code_input.dart';
import '../../../../ui/components/submit_button.dart';
import '../auth_view.dart';
import '../auth_viewmodel.dart';

class OTPView extends StatelessWidget {
  final bool isOtpRequested;
  final String? userId;
  final String? verificationCode;
  final String? phone;
  final String? email;

  const OTPView({
    super.key,
    this.isOtpRequested = false,
    this.userId,
    this.verificationCode,
    this.phone,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AuthViewModel>.reactive(
      onViewModelReady: (model) {
        model.isOtpRequested = isOtpRequested;
        if (phone != null) model.phone.text = phone!;
        if (email != null) model.email.text = email!;
      },
      viewModelBuilder: () => AuthViewModel(),
      builder: (context, model, child) => ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                verticalSpaceMassive,
                Text(
                  model.isOtpRequested ? "Input OTP" : "Create account",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kcPrimaryColor,
                  ),
                ),
                verticalSpaceTiny,
                Text(
                  model.isOtpRequested
                      ? "Please enter the code sent to your email or phone"
                      : "Create an account to explore our high-quality products.",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          verticalSpaceMedium,
          if (!model.isOtpRequested)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: model.isPhoneNumber ? model.phone : model.email,
                decoration: InputDecoration(
                  hintText: model.isPhoneNumber ? "Enter phone number" : "Enter email or phone",
                  prefixText: model.isPhoneNumber ? "+234 " : null,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: model.isPhoneNumber ? TextInputType.phone : TextInputType.emailAddress,
                onChanged: (value) => model.onEmailOrPhoneChanged(value),
              ),
            ),
          verticalSpaceMedium,
          if (model.isOtpRequested)
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: CodeInputWidget(
                codeController: model.otp,
                onCompleted: (String value) => model.submitOtp(),
              ),
            ),
          verticalSpaceSmall,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ValueListenableBuilder<bool>(
              valueListenable: appLoading,
              builder: (context, isLoading, child) => SubmitButton(
                isLoading: isLoading,
                boldText: true,
                label: model.isOtpRequested ? 'Verify OTP' : 'Get OTP',
                submit: () => model.isOtpRequested ? model.submitOtp() : model.requestOtp(),
                color: kcPrimaryColor,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already a user? ", style: TextStyle(fontSize: 12)),
              GestureDetector(
                onTap: () => model.setPresentPage(PresentPage.login),
                child: const Text("Login", style: TextStyle(fontSize: 14, color: kcSecondaryColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}