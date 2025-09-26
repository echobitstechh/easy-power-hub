import 'package:easy_ph/app/app.locator.dart';
import 'package:easy_ph/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../../state.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../../../../ui/components/code_input.dart';
import '../../../../ui/components/submit_button.dart';
import '../auth_viewmodel.dart';

class OTPView extends StackedView<AuthViewModel> {
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
  Widget builder(
      BuildContext context,
      AuthViewModel viewModel,
      Widget? child,
      ) {
    // The Scaffold provides the Material context
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                verticalSpaceMassive,
                Text(
                  viewModel.isOtpRequested ? "Input OTP" : "Create account",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kcPrimaryColor,
                  ),
                ),
                verticalSpaceTiny,
                Text(
                  viewModel.isOtpRequested
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
          if (!viewModel.isOtpRequested)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: viewModel.isPhoneNumber ? viewModel.phone : viewModel.email,
                decoration: InputDecoration(
                  hintText: viewModel.isPhoneNumber ? "Enter phone number" : "Enter email or phone",
                  prefixText: viewModel.isPhoneNumber ? "+234 " : null,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: viewModel.isPhoneNumber ? TextInputType.phone : TextInputType.emailAddress,
                onChanged: (value) => viewModel.onEmailOrPhoneChanged(value),
              ),
            ),
          verticalSpaceMedium,
          if (viewModel.isOtpRequested)
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: CodeInputWidget(
                codeController: viewModel.otp,
                onCompleted: (String value) => viewModel.submitOtp(),
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
                label: viewModel.isOtpRequested ? 'Verify OTP' : 'Get OTP',
                submit: () => viewModel.isOtpRequested ? viewModel.submitOtp() : viewModel.requestOtp(),
                color: kcPrimaryColor,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already a user? ", style: TextStyle(fontSize: 12)),
              GestureDetector(
                onTap: () => locator<NavigationService>().navigateToLogin,
                child: const Text("Login", style: TextStyle(fontSize: 14, color: kcSecondaryColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void onViewModelReady(AuthViewModel viewModel) {
    viewModel.isOtpRequested = isOtpRequested;
    if (phone != null) viewModel.phone.text = phone!;
    if (email != null) viewModel.email.text = email!;
  }

  @override
  AuthViewModel viewModelBuilder(BuildContext context) => AuthViewModel();
}