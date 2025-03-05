import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/network/api_response.dart';
import '../../../state.dart';
import '../../../utils/code_input.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../components/submit_button.dart';
import '../../components/text_field_widget.dart';
import 'auth_view.dart';
import 'auth_viewmodel.dart';


/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../state.dart';
import '../../../utils/code_input.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../components/submit_button.dart';
import '../../components/text_field_widget.dart';
import 'auth_viewmodel.dart';

/// @author
/// George David
/// email: georgequin19@gmail.com
/// Feb, 2024

class SignUp extends StatefulWidget {
  final Function(PresentPage) updatePage;
  final bool isOtpRequested;
  final String? userId;
  final String? verificationCode;
  final String? phone;
  final String? email;

  const SignUp({
    Key? key,
    required this.updatePage,
    this.isOtpRequested = false,
    this.userId,
    this.verificationCode,
    this.phone,
    this.email,
  }) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isPhoneNumber = false;
  final snackBar = locator<SnackbarService>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    appLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ViewModelBuilder<AuthViewModel>.reactive(
          onViewModelReady: (model) {
            model.init();
            if (widget.phone != null) model.phone.text = widget.phone!;
            if (widget.email != null) model.email.text = widget.email!;
            model.isOtpRequested = widget.isOtpRequested;
          },
          viewModelBuilder: () => AuthViewModel(),
          builder: (context, model, child) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    verticalSpaceMassive,
                    Text(
                      model.isOtpRequested ? "Input OTP" : "Create account",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kcPrimaryColor,
                      ),
                    ),
                    verticalSpaceTiny,
                    Text(
                      model.isOtpRequested
                          ? "Please enter the code sent to your email or phone"
                          : "Create an account to explore our high-quality products.",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpaceMedium,
              if (!model.isOtpRequested)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller:
                    isPhoneNumber ? model.phone : model.email, // One controller for both
                    decoration: InputDecoration(
                      hintText: isPhoneNumber
                          ? "Enter phone number"
                          : "Enter email or phone",
                      prefixText: isPhoneNumber ? "+234 " : null,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: isPhoneNumber
                        ? TextInputType.phone
                        : TextInputType.emailAddress,
                    onChanged: (value) {
                      setState(() {
                        if (value.isNotEmpty &&
                            RegExp(r'^\d').hasMatch(value)) {
                          isPhoneNumber = true;
                          model.email.clear();
                        } else {
                          isPhoneNumber = false;
                          model.phone.clear();
                        }
                      });
                    },
                  ),
                ),
              verticalSpaceMedium,
              if (model.isOtpRequested)
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: CodeInputWidget(
                    codeController: model.otp,
                    onCompleted: (String value) {
                      model.submitOtp(context);
                    },
                  ),
                ),
              verticalSpaceSmall,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ValueListenableBuilder<bool>(
                  valueListenable: appLoading,
                  builder: (context, isLoading, child) {
                    return SubmitButton(
                      isLoading: isLoading,
                      boldText: true,
                      label: model.isOtpRequested ? 'Verify OTP' : 'Get OTP',
                      submit: () async {
                        if (model.isOtpRequested) {
                          model.submitOtp(context); // Call submitOtp for verification
                          widget.updatePage(PresentPage.register);
                        } else {
                          final ApiResponse? response = await model.requestOtp();
                          if (response != null) {
                            if (response.statusCode == 200) {
                              // OTP successfully sent
                              model.isOtpRequested = true;
                              snackBar.showSnackbar(
                                message: 'OTP sent successfully',
                                duration: const Duration(seconds: 5),
                              );
                            } else if (response.statusCode == 400) {
                              final errorData = response.data;
                              if (errorData['message'] == 'Email already exists') {
                                snackBar.showSnackbar(
                                  message: 'The email is already registered. Please log in.',
                                  duration: const Duration(seconds: 5),
                                );
                                widget.updatePage(PresentPage.login); // Navigate to login
                              } else if (errorData['incompleteBiodata'] == true) {
                                snackBar.showSnackbar(
                                  message: 'Your profile is incomplete. Please complete your profile.',
                                  duration: const Duration(seconds: 5),
                                );
                                widget.updatePage(PresentPage.register);
                                isLoginByEmail.value = model.email.text != '';
                                profile.value.id = errorData['userId'];
                              } else {
                                snackBar.showSnackbar(
                                  message: errorData['message'] ?? 'An error occurred',
                                  duration: const Duration(seconds: 5),
                                );
                              }
                            } else {
                              snackBar.showSnackbar(
                                message: 'Unexpected response from the server',
                                duration: const Duration(seconds: 5),
                              );
                            }
                          } else {
                            snackBar.showSnackbar(
                              message: 'Request failed. Please try again later.',
                              duration: const Duration(seconds: 5),
                            );
                          }
                        }
                      },
                      color: kcPrimaryColor,
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already a user? ",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.updatePage(PresentPage.login);
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 14,
                        color: kcSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}