   import 'package:afriprize/ui/common/app_colors.dart';
import 'package:afriprize/ui/common/ui_helpers.dart';
import 'package:afriprize/ui/components/submit_button.dart';
import 'package:afriprize/ui/components/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import '../../../state.dart';
import 'enter_email_viewmodel.dart';

class EnterEmailView extends StackedView<EnterEmailViewModel> {
  const EnterEmailView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context,
      EnterEmailViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView( // Wrap everything in a SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/images/easy_power_logo.svg",
                    height: 60,
                    fit: BoxFit.fitHeight,
                  ),
                ],
              ),
              verticalSpaceMedium,
              Text(
                "Forgot Password",
                style: GoogleFonts.bricolageGrotesque(
                  textStyle: TextStyle(
                    fontSize: 20, // Custom font size
                    fontWeight: FontWeight.w700, // Custom font weight
                    color: uiMode.value == AppUiModes.dark
                        ? Colors.white // Dark mode logo
                        : Colors.black, // Custom text color (optional)
                  ),
                ),
              ),
              //if sending code is successful change the text to "Code Sent"

              Text(
                viewModel.codeSent ? "Enter verification code": "Input Your Email Address associated with your account",
                style: GoogleFonts.redHatDisplay(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: kcWhiteColor,
                  ),
                ),
              ),
              verticalSpaceLarge,
              if(viewModel.codeSent) ...[
                TextFieldWidget(
                  hint: "Enter Verification Code",
                  controller: viewModel.codeController,
                ),
                verticalSpaceSmall,
                TextFieldWidget(
                  inputType: TextInputType.visiblePassword,
                  hint: "Password",
                  controller: viewModel.password,
                  obscureText: viewModel.obscure,
                  suffix: InkWell(
                    onTap: () {
                      viewModel.toggleObscure();
                    },
                    child: Icon(
                      viewModel.obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Password must contain at least one uppercase letter';
                    }
                    if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return 'Password must contain at least one lowercase letter';
                    }
                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Password must contain at least one digit';
                    }
                    if (!RegExp(r'[!@#$%^&*]').hasMatch(value)) {
                      return 'Password must contain at least one special character';
                    }
                    return null; // Return null to indicate no validation error
                  },
                ),
                verticalSpaceSmall,
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Must be at least 8 characters with a combination of letters and numbers",
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ),
                verticalSpaceMedium,
                TextFieldWidget(
                  hint: "Confirm password",
                  controller: viewModel.cPassword,
                  obscureText: viewModel.obscure,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Password confirmation is required';
                    }
                    if (value != viewModel.password.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  suffix: InkWell(
                    onTap: () {
                      viewModel.toggleObscure();
                    },
                    child: Icon(
                      viewModel.obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ],
              if(!viewModel.codeSent)
                TextFieldWidget(
                  hint: "Enter Email",
                  controller: viewModel.emailController,
                ),
              verticalSpaceMedium,
              SubmitButton(
                isLoading: viewModel.isBusy,
                label: "Continue",
                submit: viewModel.codeSent ? viewModel.resetPassword : viewModel.sendCode,
                color: kcPrimaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  EnterEmailViewModel viewModelBuilder(
      BuildContext context,
      ) =>
      EnterEmailViewModel();
}
