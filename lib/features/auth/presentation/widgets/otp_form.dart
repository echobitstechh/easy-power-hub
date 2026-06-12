import 'package:easy_ph/app/app.locator.dart';
import 'package:easy_ph/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../../state.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../../../../ui/components/code_input.dart';
import '../../../../ui/components/glass/glass_button.dart';
import '../../../../ui/components/glass/glass_card.dart';
import '../../../../ui/components/glass/glass_scaffold.dart';
import '../../../../ui/components/glass/glass_text_field.dart';
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
  Widget builder(BuildContext context, AuthViewModel viewModel, Widget? child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                verticalSpaceMedium,

                Text(
                  viewModel.isOtpRequested ? "Verify your identity" : "Create account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'HostGrotesk',
                    color: isDark ? kcWhiteColor : kcBlackColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.isOtpRequested
                      ? "Enter the code sent to your email or phone"
                      : "Create an account to explore our products.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'HostGrotesk',
                    color: isDark ? kcWhiteColor.withOpacity(0.55) : kcMediumGrey,
                  ),
                ),

                verticalSpaceMedium,

                GlassCard(
                  borderRadius: 28,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!viewModel.isOtpRequested)
                        GlassTextField(
                          hint: viewModel.isPhoneNumber
                              ? "Phone number"
                              : "Email or phone",
                          controller: viewModel.isPhoneNumber
                              ? viewModel.phone
                              : viewModel.email,
                          prefixText: viewModel.isPhoneNumber ? "+234 " : null,
                          keyboardType: viewModel.isPhoneNumber
                              ? TextInputType.phone
                              : TextInputType.emailAddress,
                          onChanged: viewModel.onEmailOrPhoneChanged,
                        ),

                      if (viewModel.isOtpRequested) ...[
                        const SizedBox(height: 8),
                        CodeInputWidget(
                          codeController: viewModel.otp,
                          onCompleted: (_) => viewModel.submitOtp(),
                        ),
                      ],

                      verticalSpaceSmall,

                      ValueListenableBuilder<bool>(
                        valueListenable: appLoading,
                        builder: (context, isLoading, _) => GlassButton(
                          label: viewModel.isOtpRequested
                              ? 'Verify OTP'
                              : 'Get OTP',
                          isLoading: isLoading,
                          onTap: viewModel.isOtpRequested
                              ? viewModel.submitOtp
                              : viewModel.requestOtp,
                        ),
                      ),

                      verticalSpaceSmall,

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already a user? ",
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? kcWhiteColor.withOpacity(0.55)
                                  : kcMediumGrey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => locator<NavigationService>()
                                .navigateTo(Routes.login),
                            child: const Text(
                              "Sign in",
                              style: TextStyle(
                                fontSize: 13,
                                color: kcPrimaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                verticalSpaceMedium,
              ],
            ),
          ),
        ),
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
