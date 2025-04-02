import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../state.dart';
import '../../../utils/code_input.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../components/submit_button.dart';
import '../../components/text_field_widget.dart';
import 'enter_email_viewmodel.dart';

/// Modified from SignUp to match the forgot password flow functionality.
/// This widget shows an email input if a reset code hasn’t been sent,
/// or verification code + password fields if it has.
class EnterEmailView extends StatefulWidget {
  const EnterEmailView({Key? key}) : super(key: key);

  @override
  State<EnterEmailView> createState() => _EnterEmailViewState();
}

class _EnterEmailViewState extends State<EnterEmailView> {
  // Define a global key for the form
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Using ViewModelBuilder from stacked for reactive UI updates.
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
                color: uiMode.value == AppUiModes.dark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            // Wrap your content in a Form widget
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo in the center
                  Center(
                    child: SvgPicture.asset(
                      "assets/images/easy_power_logo.svg",
                      height: 60,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  verticalSpaceMedium,
                  // Instruction text
                  Text(
                    viewModel.codeSent
                        ? "Enter the verification code sent to your email and set your new password"
                        : "Input your email address associated with your account",
                    style: GoogleFonts.redHatDisplay(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  verticalSpaceLarge,
                  // If the code has been sent, show verification code and password fields
                  if (viewModel.codeSent) ...[
                    TextFieldWidget(
                      hint: "Enter Verification Code",
                      controller: viewModel.codeController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Verification code is required';
                        }
                        return null;
                      },
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
                        return null;
                      },
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
                  // If code hasn't been sent, show the email input field
                  if (!viewModel.codeSent)
                    TextFieldWidget(
                      hint: "Enter Email",
                      controller: viewModel.emailController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                  verticalSpaceMedium,
                  // Submit button: calls sendCode if code not sent; else, resetPassword
                  SubmitButton(
                    isLoading: viewModel.isBusy,
                    label: "Continue",
                    submit: () {
                      // Validate all the fields in the form.
                      if (_formKey.currentState!.validate()) {
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
      ),
    );
  }
}