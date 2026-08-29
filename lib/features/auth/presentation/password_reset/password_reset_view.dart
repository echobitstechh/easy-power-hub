import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../../../../ui/components/glass/glass_button.dart';
import '../../../../ui/components/glass/glass_card.dart';
import '../../../../ui/components/glass/glass_scaffold.dart';
import '../../../../ui/components/glass/glass_text_field.dart';
import 'password_reset_viewmodel.dart';

class EnterEmailView extends StatelessWidget {
  const EnterEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ViewModelBuilder<EnterEmailViewModel>.reactive(
      viewModelBuilder: () => EnterEmailViewModel(),
      builder: (context, viewModel, child) => GlassScaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? kcGlassSurfaceDark : kcGlassSurfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark ? kcWhiteColor : kcBlackColor,
              ),
            ),
          ),
          title: Text(
            "Forgot Password",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'HostGrotesk',
              color: isDark ? kcWhiteColor : kcBlackColor,
            ),
          ),
        ),
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    viewModel.codeSent
                        ? "Enter the verification code and set your new password"
                        : "Enter your email address to receive a reset code",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark
                          ? kcWhiteColor.withOpacity(0.65)
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
                        if (viewModel.codeSent) ...[
                          GlassTextField(
                            hint: "Verification code",
                            controller: viewModel.codeController,
                            keyboardType: TextInputType.number,
                            validator: (v) => viewModel.validateCode(v ?? ''),
                          ),
                          verticalSpaceSmall,
                          GlassTextField(
                            hint: "New password",
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
                                color: isDark
                                    ? kcWhiteColor.withOpacity(0.5)
                                    : kcMediumGrey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "At least 8 characters with letters and numbers",
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? kcWhiteColor.withOpacity(0.4)
                                  : kcMediumGrey,
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
                                color: isDark
                                    ? kcWhiteColor.withOpacity(0.5)
                                    : kcMediumGrey,
                              ),
                            ),
                          ),
                        ],

                        if (!viewModel.codeSent)
                          GlassTextField(
                            hint: "Email address",
                            controller: viewModel.emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => viewModel.validateEmail(v ?? ''),
                          ),

                        verticalSpaceSmall,

                        GlassButton(
                          label: "Continue",
                          isLoading: viewModel.isBusy,
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              viewModel.codeSent
                                  ? viewModel.resetPassword()
                                  : viewModel.sendCode();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
