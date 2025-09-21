import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:stacked/stacked.dart';
import 'package:intl_phone_field/countries.dart' as intl_countries;
import '../../../../state.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../../../../ui/components/submit_button.dart';
import '../../../../ui/components/text_field_widget.dart';
import '../auth_view.dart';
import '../auth_viewmodel.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AuthViewModel>.reactive(
      // The ViewModel should be registered as a factory in GetIt
      viewModelBuilder: () => AuthViewModel(),
      builder: (context, model, child) {
        // Form key is now a local final variable, so it's not recreated on every rebuild
        final formKey = GlobalKey<FormState>();

        // We can simplify the country logic and let the ViewModel handle it
        final List<intl_countries.Country> intlCountries = [
          intl_countries.Country(
            name: 'Nigeria',
            flag: '🇳🇬',
            code: 'NG',
            dialCode: '234',
            minLength: 10,
            maxLength: 10, nameTranslations: {},
          ),
        ];

        return Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpaceLarge,
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Panchang",
                  ),
                ),
                verticalSpaceTiny,
                Row(
                  children: [
                    const Text("Already have an account? ", style: TextStyle(fontSize: 12)),
                    GestureDetector(
                      onTap: () => model.setPresentPage(PresentPage.login),
                      child: const Text("login Account", style: TextStyle(fontSize: 12, color: kcSecondaryColor)),
                    ),
                  ],
                ),
                verticalSpaceMedium,
                Row(
                  children: [
                    Expanded(
                      child: TextFieldWidget(
                        hint: "Firstname",
                        controller: model.firstname,
                        inputType: TextInputType.name,
                        validator: (value) => value!.isEmpty ? 'First name is required' : null,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: TextFieldWidget(
                        hint: "Lastname",
                        controller: model.lastname,
                        validator: (value) => value!.isEmpty ? 'Last name is required' : null,
                      ),
                    ),
                  ],
                ),
                verticalSpaceMedium,
                // Use a ValueListenableBuilder to handle the dynamic input field
                ValueListenableBuilder<bool>(
                  valueListenable: isOtpRequestedByEmail,
                  builder: (context, isByEmail, child) {
                    return isByEmail
                        ? IntlPhoneField(
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: const TextStyle(color: Colors.black, fontSize: 13),
                        floatingLabelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Color(0xFFCC9933))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Color(0xFFCC9933))),
                      ),
                      validator: (value) => value!.completeNumber.isEmpty ? 'Phone number is required' : null,
                      initialCountryCode: 'NG',
                      countries: countries, // Pass the static countries list
                      controller: model.phone,
                      onChanged: (phone) {
                        model.onEmailOrPhoneChanged(phone.completeNumber);
                      },
                    )
                        : TextFieldWidget(
                      hint: "Email Address",
                      controller: model.email,
                      validator: (value) {
                        if (value!.isEmpty) return 'Email is required';
                        if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) return 'Invalid email address';
                        return null;
                      },
                    );
                  },
                ),
                verticalSpaceMedium,
                TextFieldWidget(
                  inputType: TextInputType.visiblePassword,
                  hint: "Password",
                  controller: model.password,
                  obscureText: model.obscure,
                  suffix: InkWell(
                    onTap: () => model.toggleObscure(),
                    child: Icon(model.obscure ? Icons.visibility_off : Icons.visibility),
                  ),
                  validator: (value) => model.validatePassword(value!), // Delegate validation to ViewModel
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
                  controller: model.cPassword,
                  obscureText: model.obscure,
                  validator: (value) => model.validateConfirmPassword(value!), // Delegate validation
                  suffix: InkWell(
                    onTap: () => model.toggleObscure(),
                    child: Icon(model.obscure ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                verticalSpace(30),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: appLoading,
                    builder: (context, isLoading, child) => SubmitButton(
                      isLoading: appLoading.value,
                      label: "Create Account",
                      submit: () {
                        if (formKey.currentState!.validate()) {
                          model.register();
                        } else {
                          // Show a snackbar or dialog to inform the user
                          print('Form validation failed.');
                        }
                      },
                      color: kcPrimaryColor,
                      boldText: true,
                    ),
                  ),
                ),
                verticalSpaceLarge,
                const SizedBox(height: 50),
                verticalSpaceMassive,
              ],
            ),
          ),
        );
      },
    );
  }
}