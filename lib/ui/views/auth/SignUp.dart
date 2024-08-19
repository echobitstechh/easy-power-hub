import 'package:flutter/cupertino.dart';
import 'package:growsmart/app/app.locator.dart';
import 'package:growsmart/app/app.router.dart';
import 'package:growsmart/ui/common/app_colors.dart';
import 'package:growsmart/ui/common/ui_helpers.dart';
import 'package:growsmart/ui/components/submit_button.dart';
import 'package:growsmart/ui/components/text_field_widget.dart';
import 'package:growsmart/ui/views/auth/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/utils/code_input.dart';


/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);



  @override
  State<SignUp> createState() => _LoginState();
}

class _LoginState extends State<SignUp> {
  bool terms = false;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Scaffold(
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
                    verticalSpaceMassive,
                    Text(
                      "Input OTP",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kcPrimaryColor,
                      ),
                    ),
                    verticalSpaceTiny,
                    Text(
                      "Please enter the code sent to your email ma*****@gmail.com",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              verticalSpaceMedium,
              if(!model.isOtpRequested)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFieldWidget(
                  hint: "Email Address",
                  controller: model.email,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'required';
                    }
                    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
                      return 'Invalid email address';
                    }
                    return null; // Return null to indicate no validation error
                  },
                ),
              ),
              verticalSpaceMedium,
              if(model.isOtpRequested)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CodeInputWidget(
                    codeController: model.otp,
                    onCompleted: (String value) {
                      model.SubmitOtp();
                    },
                  ),
                ),
              verticalSpaceMedium,
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SubmitButton(
                  isLoading: model.isBusy,
                  boldText: true,
                  label: model.isOtpRequested ? 'Verify OTP' : 'Get OTP',
                  submit: () {
                    model.requestOtp();
                  },
                  color: kcPrimaryColor,
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                    const Text(
                      "Resend OTP  ",
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                       // gotoRegister();

                      },
                      child: const Text(
                        "(00:30)",
                        style: TextStyle(
                          fontSize: 12,
                          color: kcSecondaryColor,
                        ),
                      ),
                    )

                  ]
              ),
            ],
          ),
        ),
      ),
    );
  }

  void gotoRegister() {
  }
}
