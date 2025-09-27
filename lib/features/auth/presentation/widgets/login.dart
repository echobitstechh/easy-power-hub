import 'package:easy_ph/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked/stacked.dart';
import 'dart:io';

import '../../../../app/app.locator.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../../../../ui/components/submit_button.dart';
import '../../../../ui/components/text_field_widget.dart';
import '../auth_viewmodel.dart';

class Login extends StackedView<AuthViewModel> {
  const Login({super.key});

  @override
  Widget builder(
      BuildContext context,
      AuthViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      // The Scaffold provides the Material context
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Login Account",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kcPrimaryColor,
                      ),
                    ),
                    verticalSpaceTiny,
                    Text(
                      "Welcome back you’ve been missed!",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpaceTiny,
              verticalSpaceMedium,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ValueListenableBuilder<bool>(
                  valueListenable: viewModel.isPhoneNumberNotifier,
                  builder: (context, isPhoneNumber, child) {
                    return TextField(
                      controller: viewModel.inputController,
                      decoration: InputDecoration(
                        hintText: isPhoneNumber ? "Enter phone number" : "Enter email or Phone",
                        prefixText: isPhoneNumber ? "+234 " : null,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: isPhoneNumber ? TextInputType.phone : TextInputType.emailAddress,
                      onChanged: (value) => viewModel.onEmailOrPhoneChanged(value),
                    );
                  },
                ),
              ),
              verticalSpaceMedium,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFieldWidget(
                  hint: "Password",
                  controller: viewModel.password,
                  obscureText: viewModel.obscure,
                  suffix: InkWell(
                    onTap: () => viewModel.toggleObscure(),
                    child: Icon(viewModel.obscure ? Icons.visibility_off : Icons.visibility),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[600]!
                          : Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              verticalSpaceTiny,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => locator<NavigationService>().navigateToEnterEmailView(),
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(
                        fontSize: 16,
                        color: kcSecondaryColor,
                      ),
                    ),
                  )
                ],
              ),
              verticalSpaceMedium,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SubmitButton(
                  isLoading: viewModel.isBusy,
                  boldText: true,
                  label: "Login",
                  submit: () => viewModel.login(),
                  color: kcPrimaryColor,
                ),
              ),
              verticalSpaceMedium,

              // if (Platform.isAndroid) ...[
              //   verticalSpaceMedium,
              //   const Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: <Widget>[
              //       Expanded(child: Divider(color: Colors.grey, thickness: 1)),
              //       Padding(
              //         padding: EdgeInsets.symmetric(horizontal: 8),
              //         child: Text("OR", style: TextStyle(fontSize: 14, color: Colors.grey)),
              //       ),
              //       Expanded(child: Divider(color: Colors.grey, thickness: 1)),
              //     ],
              //   ),
              //   ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       foregroundColor: Colors.black,
              //       backgroundColor: Colors.white,
              //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              //       elevation: 2,
              //       padding: const EdgeInsets.symmetric(horizontal: 16),
              //       minimumSize: const Size(double.infinity, 54),
              //     ),
              //     onPressed: () => viewModel.signInWithGoogle(),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Image.network(
              //           "https://firebasestorage.googleapis.com/v0/b/flutterbricks-public.appspot.com/o/crypto%2Fsearch%20(2).png?alt=media&token=24a918f7-3564-4290-b7e4-08ff54b3c94c",
              //           width: 20,
              //         ),
              //         const SizedBox(width: 20),
              //         const Text('Sign in with Google', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
              //       ],
              //     ),
              //   ),
              //   verticalSpaceMedium,
              // ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(fontSize: 12)),
                  GestureDetector(
                    onTap: () {locator<NavigationService>().navigateTo(Routes.register);},
                    child: const Text("Create Account", style: TextStyle(fontSize: 12, color: kcSecondaryColor)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onViewModelReady(AuthViewModel viewModel) {
    viewModel.init();
  }

  @override
  AuthViewModel viewModelBuilder(BuildContext context) => AuthViewModel();
}