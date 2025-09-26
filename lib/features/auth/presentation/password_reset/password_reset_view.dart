import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../../../state.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../../../../ui/components/submit_button.dart';
import '../../../../ui/components/text_field_widget.dart';
import 'password_reset_viewmodel.dart';

class EnterEmailView extends StatelessWidget {
  const EnterEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a form key as a local variable for a stateless widget
    final formKey = GlobalKey<FormState>();

    return ViewModelBuilder<EnterEmailViewModel>.reactive(
      viewModelBuilder: () => EnterEmailViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: Text(
            "Forgot Password",
            style: GoogleFonts.bricolageGrotesque(
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SvgPicture.asset(
                    "assets/images/easy_power_logo.svg",
                    height: 60,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                verticalSpaceMedium,
                Text(
                  viewModel.codeSent
                      ? "Enter the verification code sent to your email and set your new password"
                      : "Input your email address associated with your account",
                  style: GoogleFonts.redHatDisplay(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                verticalSpaceLarge,
                if (viewModel.codeSent) ...[
                  TextFieldWidget(
                    hint: "Enter Verification Code",
                    controller: viewModel.codeController,
                    validator: (value) => viewModel.validateCode(value!),
                  ),
                  verticalSpaceSmall,
                  TextFieldWidget(
                    inputType: TextInputType.visiblePassword,
                    hint: "Password",
                    controller: viewModel.password,
                    obscureText: viewModel.obscure,
                    suffix: InkWell(
                      onTap: () => viewModel.toggleObscure(),
                      child: Icon(viewModel.obscure ? Icons.visibility_off : Icons.visibility),
                    ),
                    validator: (value) => viewModel.validatePassword(value!),
                  ),
                  verticalSpaceSmall,
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Must be at least 8 characters with a combination of letters and numbers",
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  verticalSpaceMedium,
                  TextFieldWidget(
                    hint: "Confirm password",
                    controller: viewModel.cPassword,
                    obscureText: viewModel.obscure,
                    validator: (value) => viewModel.validateConfirmPassword(value!),
                    suffix: InkWell(
                      onTap: () => viewModel.toggleObscure(),
                      child: Icon(viewModel.obscure ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                ],
                if (!viewModel.codeSent)
                  TextFieldWidget(
                    hint: "Enter Email",
                    controller: viewModel.emailController,
                    validator: (value) => viewModel.validateEmail(value!),
                  ),
                verticalSpaceMedium,
                SubmitButton(
                  isLoading: viewModel.isBusy,
                  label: "Continue",
                  submit: () {
                    if (formKey.currentState!.validate()) {
                      viewModel.codeSent
                          ? viewModel.resetPassword()
                          : viewModel.sendCode();
                    }
                  },
                  color: kcPrimaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}