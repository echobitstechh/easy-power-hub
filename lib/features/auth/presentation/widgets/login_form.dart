import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stacked/stacked.dart';
import '../../../../ui/components/submit_button.dart';
import '../../../../ui/components/text_field_widget.dart';
import '../auth_viewmodel.dart';

class LoginForm extends ViewModelWidget<AuthViewModel> {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, AuthViewModel viewModel) {
    return SingleChildScrollView(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/icons/logo.svg', height: 74),
              const SizedBox(height: 24),
              SubmitButton(
                isLoading: viewModel.isGoogleLoading,
                label: "Login with Google",
                svgFileName: "google.svg",
                color: Colors.white,
                textColor: Colors.black,
                submit: viewModel.googleSignIn,
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Login Account", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Form(
                key: viewModel.loginFormKey,
                child: Column(
                  children: [
                    TextFieldWidget(
                      hint: "Enter Username",
                      controller: viewModel.usernameController,
                      validator: (val) => val == null || val.isEmpty ? 'Username required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      hint: "Enter Password",
                      controller: viewModel.passwordController,
                      obscureText: !viewModel.passwordVisible,
                      validator: (val) => val == null || val.length < 6 ? 'Invalid password' : null,
                      suffix: IconButton(
                        icon: Icon(viewModel.passwordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: viewModel.togglePasswordVisibility,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SubmitButton(
                      isLoading: viewModel.isLoggingIn,
                      label: "Login Account",
                      color: const Color(0xFF084834),
                      submit: viewModel.login,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: viewModel.goToRegister,
                child: const Text("Don’t have an account? Create One →"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

