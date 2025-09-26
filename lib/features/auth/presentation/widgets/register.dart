// lib/features/auth/presentation/register.dart

import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart' as intl_countries;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../../app/app.locator.dart';
import '../../../../app/app.router.dart';

import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../../../../ui/components/submit_button.dart';
import '../../../../ui/components/text_field_widget.dart';
import '../../../../ui/components/code_input.dart';
import '../auth_viewmodel.dart';



class Register extends StackedView<AuthViewModel> {
  const Register({super.key});

  @override
  Widget builder(
      BuildContext context,
      AuthViewModel viewModel,
      Widget? child,
      ) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              verticalSpaceMassive,
              const Text(
                "Create Account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Panchang",
                ),
              ),
              verticalSpaceTiny,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ", style: TextStyle(fontSize: 12)),
                  GestureDetector(
                    onTap: () { locator<NavigationService>().navigateTo(Routes.login); },
                    child: const Text("login Account", style: TextStyle(fontSize: 12, color: kcSecondaryColor)),
                  ),
                ],
              ),
              verticalSpaceMedium,
              _buildFormContent(viewModel, context, formKey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(AuthViewModel viewModel, BuildContext context, GlobalKey<FormState> formKey) {
    switch (viewModel.registrationStep) {
      case RegistrationStep.collectContact:
        return _buildCollectContactForm(viewModel, context, formKey);
      case RegistrationStep.verifyOtp:
        return _buildVerifyOtpForm(viewModel, context);
      case RegistrationStep.completeProfile:
        return _buildCompleteProfileForm(viewModel, context, formKey);
      default: return _buildCollectContactForm(viewModel, context, formKey);
    }
  }

  Widget _buildCollectContactForm(AuthViewModel viewModel, BuildContext context, GlobalKey<FormState> formKey ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ValueListenableBuilder<bool>(
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
        verticalSpace(30),
        SubmitButton(
          isLoading: viewModel.isBusy,
          label: 'Get OTP',
          submit: () {
            // New method in ViewModel to handle the first step
            viewModel.requestOtpForRegistration();
          },
          color: kcPrimaryColor,
          boldText: true,
        ),
      ],
    );
  }

  Widget _buildVerifyOtpForm(AuthViewModel viewModel, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Enter OTP",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        verticalSpaceMedium,
        CodeInputWidget(
          codeController: viewModel.otp,
          onCompleted: (String value) => viewModel.verifyOtpForRegistration(),
        ),
        verticalSpace(30),
        SubmitButton(
          isLoading: viewModel.isBusy,
          label: 'Verify OTP',
          submit: () => viewModel.verifyOtpForRegistration(),
          color: kcPrimaryColor,
          boldText: true,
        ),
      ],
    );
  }

  Widget _buildCompleteProfileForm(AuthViewModel viewModel, BuildContext context, GlobalKey<FormState> formKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFieldWidget(
                hint: "Firstname",
                controller: viewModel.firstname,
                inputType: TextInputType.name,
                validator: (value) => value!.isEmpty ? 'First name is required' : null,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: TextFieldWidget(
                hint: "Lastname",
                controller: viewModel.lastname,
                validator: (value) => value!.isEmpty ? 'Last name is required' : null,
              ),
            ),
          ],
        ),
        verticalSpaceMedium,
        // The conditionally displayed field for email or phone
        if (viewModel.isPhoneNumber) // If phone was used for OTP, ask for email
          TextFieldWidget(
            hint: "Email Address",
            controller: viewModel.email,
            validator: (value) {
              if (value!.isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) return 'Invalid email address';
              return null;
            },
          ),
        if (!viewModel.isPhoneNumber) // If email was used for OTP, ask for phone
          IntlPhoneField(
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            initialCountryCode: 'NG',
            controller: viewModel.phone,
            validator: (value) => value!.completeNumber.isEmpty ? 'Phone number is required' : null,
          ),
        verticalSpaceMedium,
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
        verticalSpace(30),
        SubmitButton(
          isLoading: viewModel.isBusy,
          label: "Create Account",
          submit: () {

            if (formKey.currentState!.validate()) {
              viewModel.completeRegistration();
            } else {
              print('Form validation failed.');
              locator<SnackbarService>().showSnackbar(message: 'fill all fields');
            }
          },
          color: kcPrimaryColor,
          boldText: true,
        ),
      ],
    );
  }

  @override
  AuthViewModel viewModelBuilder(BuildContext context) => AuthViewModel();
}