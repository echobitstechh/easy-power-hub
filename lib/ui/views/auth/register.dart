 import 'package:easyph/core/data/models/country.dart';
import 'package:easyph/state.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/components/submit_button.dart';
import 'package:easyph/ui/components/text_field_widget.dart';
import 'package:easyph/ui/views/auth/auth_viewmodel.dart';
import 'package:easyph/utils/country_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/country_picker_utils.dart';
import '../../common/ui_helpers.dart';


/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///


class Register extends StatefulWidget {
  // final TabController controller;
  final Function(bool) updateIsLogin;
  const Register({Key? key, required this.updateIsLogin}) : super(key: key);



  @override
  State<Register> createState() => _RegisterState();

}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Country> countries = [];
  final List<String> genderOptions = ['Male', 'Female'];


  @override
  void initState() {
    super.initState();
    countries = [
      Country(
        code: 'NG', // ISO code for Nigeria
        isoCode: 'NG', // ISO code for Nigeria
        name: 'Nigeria',
        capital: 'Abuja',
        id2: 'NGA',
      ),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AuthViewModel>.reactive(
        viewModelBuilder: () => AuthViewModel(),
        builder: (context, model, child) =>
        Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      fontFamily: "Panchang"
                  ),
                ),
                verticalSpaceTiny,
                Row(
                    children:  [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          gotoLogin();
                        },
                        child: const Text(
                          "login Account",
                          style: TextStyle(
                            fontSize: 12,
                            color: kcSecondaryColor,
                          ),
                        ),
                      )

                    ]
                ),
                verticalSpaceMedium,
                Row(
                  children: [
                    Expanded(
                      child: TextFieldWidget(
                        hint: "Firstname",
                        controller: model.firstname,
                        inputType: TextInputType.name,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'required';
                          }
                          return null; // Return null to indicate no validation error
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: TextFieldWidget(
                        hint: "Lastname",
                        controller: model.lastname,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'required';
                          }
                          return null; // Return null to indicate no validation error
                        },
                      ),
                    ),
                    verticalSpaceSmall,
                  ],
                ),
                verticalSpaceMedium,
              isOtpRequestedByEmail.value
                  ? IntlPhoneField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: const TextStyle(color: Colors.black, fontSize: 13),
                  floatingLabelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0), // Add border curve
                    borderSide: const BorderSide(color: Color(0xFFCC9933)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0), // Add border curve
                    borderSide: const BorderSide(color: Color(0xFFCC9933)),
                  ),
                ),
                validator: (value) {
                  if (value!.completeNumber.isEmpty) {
                    return 'required';
                  }
                  return null; // Return null to indicate no validation error
                },
                initialCountryCode: 'NG',
                countries: countries.isNotEmpty
                    ? countries.map((country) => CountryPickerUtils.getCountryByIsoCode(country.code!)).toList()
                    : [],
                controller: model.phone,
                onChanged: (phone) {
                  model.phoneNumber = phone;
                  try {
                    // Attempt to find the country where the code matches phone.countryISOCode
                    print('phone code is: ${phone.countryISOCode}');
                    print('country code is: ${countries.first.code}');
                    model.countryId = countries.firstWhere((country) => country.code == phone.countryISOCode).id2!;
                  } catch (e) {
                    // Handle the case where no matching country is found
                    print('No matching country found for ISO code: ${phone.countryISOCode}');
                    model.countryId = ''; // or handle appropriately
                  }
                },
              )
                  : TextFieldWidget(
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
                verticalSpaceMedium,
                TextFieldWidget(
                  inputType: TextInputType.visiblePassword,
                  hint: "Password",
                  controller: model.password,
                  obscureText: model.obscure,
                  suffix: InkWell(
                    onTap: () {
                      model.toggleObscure();
                    },
                    child:
                    Icon(model.obscure ? Icons.visibility_off : Icons.visibility),
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
                  child: Text( style: TextStyle(
                    fontSize: 11,
                  ),
                      "Must be at least 8 characters with a combination of letters and numbers"),
                ),
                verticalSpaceMedium,
                TextFieldWidget(
                  hint: "Confirm password",
                  controller: model.cPassword,
                  obscureText: model.obscure,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Password confirmation is required';
                    }
                    if (value != model.password.text) {
                      return 'Passwords do not match';
                    }
                    return null; // Return null to indicate no validation error
                  },
                  suffix: InkWell(
                    onTap: () {
                      model.toggleObscure();
                    },
                    child:
                    Icon(model.obscure ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                verticalSpace(30),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: appLoading,
                    builder: (context, isLoading, child) {
                      return SubmitButton(
                        isLoading: appLoading.value,
                        label: "Create Account",
                        submit: () {
                          if (_formKey.currentState!.validate()) {
                            model.register();
                          }else {print('Hello World');}
                        },
                        color: kcPrimaryColor,
                        boldText: true,
                      );
                    },
                  ),
                ),


                verticalSpaceLarge,
                const SizedBox(
                  height: 50,
                ),
                verticalSpaceMassive
              ],
            ),
            ),
        );
  }

  void gotoLogin() {
    widget.updateIsLogin(true);
  }
}
