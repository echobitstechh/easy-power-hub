import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.router.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:easyph/ui/components/submit_button.dart';
import 'package:easyph/ui/components/text_field_widget.dart';
import 'package:easyph/ui/views/auth/auth_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../state.dart';
import 'authService.dart';
import 'auth_view.dart';


/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class Login extends StatefulWidget {
  final Function(PresentPage) updateIsLogin;
  const Login({Key? key, required this.updateIsLogin}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool terms = false;
  bool isPhoneNumber = false;

  final AuthService _authService = AuthService(); // Ensure AuthService is imported and instantiated

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
          },
          viewModelBuilder: () => AuthViewModel(),
          builder: (context, model, child) => ListView(
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
                child: TextField(
                  controller: isPhoneNumber
                      ? model.phone
                      : model.email, // A single controller for both
                  decoration: InputDecoration(
                    hintText: isPhoneNumber
                        ? "Enter phone number"
                        : "Enter email or Phone",
                    prefixText:
                        isPhoneNumber ? "+234 " : null, // Default to Nigeria
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: isPhoneNumber
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty && RegExp(r'^\d').hasMatch(value)) {
                        isPhoneNumber = true;
                        isLoginByEmail.value = false;
                        model.email.clear();
                      } else {
                        isPhoneNumber = false;
                        model.phone.clear();
                        isLoginByEmail.value = true;
                      }
                    });
                  },
                ),
              ),
              verticalSpaceMedium,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFieldWidget(
                  hint: "Password",
                  controller: model.password,
                  obscureText: model.obscure,
                  suffix: InkWell(
                    onTap: () {
                      model.toggleObscure();
                    },
                    child: Icon(model.obscure
                        ? Icons.visibility_off
                        : Icons.visibility),
                  ),
                ),
              ),
              verticalSpaceTiny,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // InkWell(
                  //   onTap: model.toggleRemember,
                  //   child: Row(
                  //     children: [
                  //       Container(
                  //           height: 20,
                  //           width: 20,
                  //           decoration: BoxDecoration(
                  //               color: model.remember
                  //                   ? kcSecondaryColor
                  //                   : Colors.transparent,
                  //               borderRadius: BorderRadius.circular(5),
                  //               border: Border.all(
                  //                   color: model.remember
                  //                       ? Colors.transparent
                  //                       : kcSecondaryColor)),
                  //           child: model.remember
                  //               ? const Center(
                  //             child: Icon(
                  //               Icons.check,
                  //               color: kcWhiteColor,
                  //               size: 14,
                  //             ),
                  //           )
                  //               : const SizedBox()),
                  //       horizontalSpaceSmall,
                  //       const Text(
                  //         "Remember Me",
                  //         style: TextStyle(
                  //             fontSize: 14, decoration: TextDecoration.underline),
                  //       )
                  //     ],
                  //   ),
                  // ),
                  InkWell(
                    onTap: () {
                      locator<NavigationService>()
                          .navigateToChangePasswordView(isResetPassword: true);
                    },
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
                child: ValueListenableBuilder<bool>(
                  valueListenable: appLoading,
                  builder: (context, isLoading, child) {
                    return SubmitButton(
                      isLoading:
                          isLoading, // Dynamically updates based on `appLoading.value`
                      boldText: true,
                      label: "Login",
                      submit: () async {
                        await model.login(context);
                      },
                      color: kcPrimaryColor,
                    );
                  },
                ),
              ),
              verticalSpaceMedium,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              verticalSpaceMedium,
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2, // Subtle shadow
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: const Size(double.infinity, 54), // Full-width button
                ),
                onPressed: () {
                  model.signInWithGoogle(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      "https://firebasestorage.googleapis.com/v0/b/flutterbricks-public.appspot.com/o/crypto%2Fsearch%20(2).png?alt=media&token=24a918f7-3564-4290-b7e4-08ff54b3c94c",
                      width: 20,
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'Sign in with Google',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // SubmitButton(
              //   isLoading: model.isBusy,
              //   boldText: true,
              //   iconIsPrefix: true,
              //   icon: FontAwesomeIcons.google,
              //   label: "Sign in with Google",
              //   textColor: Colors.black,
              //   submit:() {
              //     model.signInWithGoogle(context);
              //   },
              //   color: Colors.grey,
              // ),
              verticalSpaceMedium,
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    widget.updateIsLogin(PresentPage.signup);
                    //gotoRegister();
                  },
                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 12,
                      color: kcSecondaryColor,
                    ),
                  ),
                )
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
