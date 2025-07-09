import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';
import '../../../../state.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/app_fonts.dart';
import '../../../../ui/components/submit_button.dart';
import '../../../../ui/components/text_field_widget.dart';
import '../auth_viewmodel.dart';

class RegisterForm extends ViewModelWidget<AuthViewModel> {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context, AuthViewModel viewModel) {
    return SingleChildScrollView(
      child: Card(
        color: uiMode.value == AppUiModes.dark ? kcBlackColor : kcWhiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/icons/logo.svg', height: 74),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: SubmitButton(
                  iconIsPrefix: true,
                  isLoading: viewModel.isGoogleLoading,
                  label: "Register with Google",
                  svgFileName: "google.svg",
                  color: Colors.white,
                  textColor: Colors.black,
                  submit: viewModel.googleSignIn,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: hostGrotesk,
                        fontSize: 24,
                      ),
                    ),
                    GestureDetector(
                      onTap: viewModel.goToLogin,
                      child: RichText(
                        text: const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(fontSize: 16, fontFamily: hostGrotesk, fontWeight: FontWeight.w400, color: Colors.black),
                          children: [
                            TextSpan(
                              text: "Login →",
                              style: TextStyle(fontWeight: FontWeight.w600, color: kcSecondaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Form(
                key: viewModel.formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFieldWidget(
                            hint: "Enter First Name",
                            controller: viewModel.firstNameController,
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFieldWidget(
                            hint: "Enter Last Name",
                            controller: viewModel.lastNameController,
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      hint: "Enter Email",
                      controller: viewModel.emailController,
                      validator: (val) => val == null || !val.contains('@') ? 'Enter valid email' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      hint: "Enter Username",
                      controller: viewModel.usernameController,
                      validator: (val) => val == null || val.isEmpty ? 'Username is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      hint: "Enter Password",
                      controller: viewModel.passwordController,
                      obscureText: !viewModel.passwordVisible,
                      validator: (val) => val == null || val.length < 6 ? 'Min 6 characters' : null,
                      suffix: IconButton(
                        icon: Icon(viewModel.passwordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: viewModel.togglePasswordVisibility,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SubmitButton(
                      isLoading: viewModel.isRegistering,
                      label: "Create Account",
                      color: const Color(0xFF084834),
                      submit: viewModel.register,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}