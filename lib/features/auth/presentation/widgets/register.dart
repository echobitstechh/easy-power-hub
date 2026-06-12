import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../../app/app.locator.dart';
import '../../../../app/app.router.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../../../../ui/components/code_input.dart';
import '../../../../ui/components/glass/glass_button.dart';
import '../../../../ui/components/glass/glass_card.dart';
import '../../../../ui/components/glass/glass_scaffold.dart';
import '../../../../ui/components/glass/glass_text_field.dart';
import '../auth_viewmodel.dart';

class Register extends StackedView<AuthViewModel> {
  const Register({super.key});

  @override
  Widget builder(BuildContext context, AuthViewModel viewModel, Widget? child) {
    final formKey = GlobalKey<FormState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    kcSecondaryColor.withOpacity(isDark ? 0.20 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Create Account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'HostGrotesk',
                        color: isDark ? kcWhiteColor : kcBlackColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
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

                    verticalSpaceMedium,

                    GlassCard(
                      borderRadius: 28,
                      padding: const EdgeInsets.all(24),
                      child: _buildStepContent(
                          viewModel, context, formKey, isDark),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(AuthViewModel viewModel, BuildContext context,
      GlobalKey<FormState> formKey, bool isDark) {
    switch (viewModel.registrationStep) {
      case RegistrationStep.collectContact:
        return _contactStep(viewModel, isDark);
      case RegistrationStep.verifyOtp:
        return _otpStep(viewModel, isDark);
      case RegistrationStep.completeProfile:
        return _profileStep(viewModel, context, formKey, isDark);
      default:
        return _contactStep(viewModel, isDark);
    }
  }

  Widget _contactStep(AuthViewModel viewModel, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Enter your contact",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? kcWhiteColor : kcBlackColor,
          ),
        ),
        verticalSpaceSmall,
        ValueListenableBuilder<bool>(
          valueListenable: viewModel.isPhoneNumberNotifier,
          builder: (context, isPhone, _) => GlassTextField(
            hint: isPhone ? "Phone number" : "Email or phone",
            controller: viewModel.inputController,
            prefixText: isPhone ? "+234 " : null,
            keyboardType:
                isPhone ? TextInputType.phone : TextInputType.emailAddress,
            onChanged: viewModel.onEmailOrPhoneChanged,
          ),
        ),
        verticalSpaceSmall,
        GlassButton(
          label: "Get OTP",
          isLoading: viewModel.isBusy,
          onTap: viewModel.requestOtpForRegistration,
        ),
      ],
    );
  }

  Widget _otpStep(AuthViewModel viewModel, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Enter the OTP sent to you",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? kcWhiteColor : kcBlackColor,
          ),
        ),
        verticalSpaceSmall,
        CodeInputWidget(
          codeController: viewModel.otp,
          onCompleted: (_) => viewModel.verifyOtpForRegistration(),
        ),
        verticalSpaceSmall,
        GlassButton(
          label: "Verify OTP",
          isLoading: viewModel.isBusy,
          onTap: viewModel.verifyOtpForRegistration,
        ),
      ],
    );
  }

  Widget _profileStep(AuthViewModel viewModel, BuildContext context,
      GlobalKey<FormState> formKey, bool isDark) {
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Complete your profile",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? kcWhiteColor : kcBlackColor,
          ),
        ),
        verticalSpaceSmall,

        Row(
          children: [
            Expanded(
              child: GlassTextField(
                hint: "First name",
                controller: viewModel.firstname,
                keyboardType: TextInputType.name,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GlassTextField(
                hint: "Last name",
                controller: viewModel.lastname,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ),
          ],
        ),

        verticalSpaceSmall,

        if (viewModel.isPhoneNumber)
          GlassTextField(
            hint: "Email address",
            controller: viewModel.email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v!.isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                  .hasMatch(v)) return 'Invalid email';
              return null;
            },
          ),

        if (!viewModel.isPhoneNumber) ...[
          IntlPhoneField(
            decoration: inputDecoration.copyWith(labelText: 'Phone number'),
            initialCountryCode: 'NG',
            controller: viewModel.phone,
            validator: (v) =>
                v!.completeNumber.isEmpty ? 'Phone required' : null,
          ),
        ],

        verticalSpaceSmall,

        GlassTextField(
          hint: "Password",
          controller: viewModel.password,
          obscureText: viewModel.obscure,
          keyboardType: TextInputType.visiblePassword,
          validator: (v) => viewModel.validatePassword(v ?? ''),
          suffix: GestureDetector(
            onTap: viewModel.toggleObscure,
            child: Icon(
              viewModel.obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: isDark ? kcWhiteColor.withOpacity(0.5) : kcMediumGrey,
            ),
          ),
        ),

        const SizedBox(height: 4),
        Text(
          "At least 8 characters with letters and numbers",
          style: TextStyle(
            fontSize: 11,
            color: isDark ? kcWhiteColor.withOpacity(0.4) : kcMediumGrey,
          ),
        ),

        verticalSpaceSmall,

        GlassTextField(
          hint: "Confirm password",
          controller: viewModel.cPassword,
          obscureText: viewModel.obscure,
          validator: (v) => viewModel.validateConfirmPassword(v ?? ''),
          suffix: GestureDetector(
            onTap: viewModel.toggleObscure,
            child: Icon(
              viewModel.obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: isDark ? kcWhiteColor.withOpacity(0.5) : kcMediumGrey,
            ),
          ),
        ),

        verticalSpaceSmall,

        GlassTextField(
          hint: "Referral code (optional)",
          controller: viewModel.referralCode,
        ),

        verticalSpaceSmall,

        GlassButton(
          label: "Create Account",
          isLoading: viewModel.isBusy,
          onTap: () {
            if (formKey.currentState!.validate()) {
              viewModel.completeRegistration();
            } else {
              locator<SnackbarService>()
                  .showSnackbar(message: 'Please fill all fields');
            }
          },
        ),
      ],
    );
  }

  @override
  AuthViewModel viewModelBuilder(BuildContext context) => AuthViewModel();
}
