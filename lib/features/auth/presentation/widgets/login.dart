import 'package:easy_ph/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked/stacked.dart';

import '../../../../app/app.locator.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../../../../ui/components/glass/glass_button.dart';
import '../../../../ui/components/glass/glass_card.dart';
import '../../../../ui/components/glass/glass_scaffold.dart';
import '../../../../ui/components/glass/glass_text_field.dart';
import '../auth_viewmodel.dart';

class Login extends StackedView<AuthViewModel> {
  const Login({super.key});

  @override
  Widget builder(BuildContext context, AuthViewModel viewModel, Widget? child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      body: Stack(
        children: [
          // Amber glow orb
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    kcPrimaryColor.withOpacity(isDark ? 0.20 : 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    verticalSpaceMedium,

                    // Logo + headline
                    Image.asset('assets/images/easy_ph_logo.png',
                        height: 64, width: 64),
                    verticalSpaceSmall,
                    Text(
                      "Welcome back",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'HostGrotesk',
                        color: isDark ? kcWhiteColor : kcBlackColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Sign in to your account",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'HostGrotesk',
                        color: isDark
                            ? kcWhiteColor.withOpacity(0.55)
                            : kcMediumGrey,
                      ),
                    ),

                    verticalSpaceMedium,

                    GlassCard(
                      borderRadius: 28,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email / phone field
                          ValueListenableBuilder<bool>(
                            valueListenable: viewModel.isPhoneNumberNotifier,
                            builder: (context, isPhone, _) {
                              return GlassTextField(
                                hint: isPhone
                                    ? "Phone number"
                                    : "Email or phone",
                                controller: viewModel.inputController,
                                prefixText: isPhone ? "+234 " : null,
                                keyboardType: isPhone
                                    ? TextInputType.phone
                                    : TextInputType.emailAddress,
                                onChanged: viewModel.onEmailOrPhoneChanged,
                              );
                            },
                          ),

                          verticalSpaceSmall,

                          // Password field
                          GlassTextField(
                            hint: "Password",
                            controller: viewModel.password,
                            obscureText: viewModel.obscure,
                            suffix: GestureDetector(
                              onTap: viewModel.toggleObscure,
                              child: Icon(
                                viewModel.obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: isDark
                                    ? kcWhiteColor.withOpacity(0.5)
                                    : kcMediumGrey,
                              ),
                            ),
                          ),

                          verticalSpaceTiny,

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => locator<NavigationService>()
                                  .navigateToEnterEmailView(),
                              child: Text(
                                "Forgot password?",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: kcPrimaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          verticalSpaceSmall,

                          GlassButton(
                            label: "Sign In",
                            isLoading: viewModel.isBusy,
                            onTap: viewModel.login,
                          ),

                          verticalSpaceSmall,

                          // Register link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? kcWhiteColor.withOpacity(0.55)
                                      : kcMediumGrey,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => locator<NavigationService>()
                                    .navigateTo(Routes.register),
                                child: const Text(
                                  "Create account",
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
        ],
      ),
    );
  }

  @override
  void onViewModelReady(AuthViewModel viewModel) => viewModel.init();

  @override
  AuthViewModel viewModelBuilder(BuildContext context) => AuthViewModel();
}
