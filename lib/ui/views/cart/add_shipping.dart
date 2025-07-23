import 'package:easyph/app/app.locator.dart';
import 'package:easyph/core/data/models/profile.dart';
import 'package:easyph/core/data/repositories/repository.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:easyph/state.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:easyph/ui/components/submit_button.dart';
import 'package:easyph/ui/components/text_field_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../core/data/models/country.dart';
import '../../../utils/country_picker_utils.dart';


/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///


class AddShipping extends StatefulWidget {
  const AddShipping({Key? key}) : super(key: key);

  @override
  State<AddShipping> createState() => _AddShippingState();
}

class _AddShippingState extends State<AddShipping> {
  final address = TextEditingController();
  String? countryId;
  late PhoneNumber phoneNumber;
  late PhoneNumber altPhoneNumber;
  final city = TextEditingController();
  final phone = TextEditingController();
  final altPhone = TextEditingController();
  final state = TextEditingController();
  final zipCode = TextEditingController();
  List<Country> countries = [];
  bool? loadingCountries = true;
  bool isLoading = false;


  @override
  void initState() {
    // loadCountries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Shipping Details"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFieldWidget(
            hint: "Street Address",
            controller: address,
          ),
          verticalSpaceMedium,
          // DropdownWidget(
          //   value: state,
          //   itemsList: states,
          //   hint: "State",
          //   onChanged: (value) {
          //     setState(() {
          //       state = value;
          //     });
          //   },
          // ),
          TextFieldWidget(
            hint: "State",
            controller: state,
          ),
          verticalSpaceMedium,
          TextFieldWidget(
            hint: "City",
            controller: city,
          ),
          verticalSpaceMedium,
          loadingCountries == true ? const CircularProgressIndicator() :
          IntlPhoneField(
            decoration: InputDecoration(
              labelText: 'Phone Number',
              labelStyle: const TextStyle(color: Colors.black,fontSize: 13),
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
            countries: countries.map((country) => CountryPickerUtils.getCountryByIsoCode(country.code!)).toList(),
            controller: phone,
            onChanged: (phone) {
              phoneNumber = phone;
              countryId = countries.firstWhere((country) => country.code == phone.countryISOCode).id!;
            },
          ),
          verticalSpaceMedium,
          loadingCountries == true ? const CircularProgressIndicator() :
          IntlPhoneField(
            decoration: InputDecoration(
              labelText: 'Alternative Phone Number',
              labelStyle: const TextStyle(color: Colors.black,fontSize: 13),
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
            countries: countries.map((country) => CountryPickerUtils.getCountryByIsoCode(country.code!)).toList(),
            controller: altPhone,
            onChanged: (phone) {
              altPhoneNumber = phone;
              countryId = countries.firstWhere((country) => country.code == phone.countryISOCode).id!;
            },
          ),
          verticalSpaceMedium,
          TextFieldWidget(
            hint: "Zip Code",
            controller: zipCode,
            validator: (value) {
              String pattern = r'^[0-9]+$';
              RegExp regExp = RegExp(pattern);

              // Check if the value matches the pattern
              if (value == null || value.isEmpty || !regExp.hasMatch(value)) {
                return 'Please enter a valid zip code'; // Error message
              }
              return null; // Return null if the input is valid
            },
          ),
          verticalSpaceMedium,
          SubmitButton(
            isLoading: isLoading,
            label: "Submit",
            submit: () async {
              if (!isLoading) {
                setState(() {
                  isLoading = true;
                });

                try {

                  ApiResponse res = await locator<Repository>().saveShipping({
                    "shipping_firstname": profile.value.firstName,
                    "shipping_lastname": profile.value.lastName,
                    "shipping_phone": phoneNumber.completeNumber,
                    "shipping_additional_phone":altPhoneNumber.completeNumber,
                    "shipping_address": address.text,
                    "shipping_additional_address": address.text,
                    "shipping_state": state.text,
                    "shipping_city": city.text,
                    "shipping_country": countryId,
                    "shipping_zip_code": int.parse(zipCode.text)
                  });
                  if (res.statusCode == 200) {
                    Shipping shipping = Shipping.fromJson(Map<String, dynamic>.from(res.data["shipment"]));
                    locator<SnackbarService>().showSnackbar(message: res.data["message"]);
                      try {
                        ApiResponse res = await locator<Repository>().setDefaultShipping(
                            {},
                            shipping.id!);
                        if (res.statusCode == 200) {
                          ApiResponse pRes = await locator<Repository>().getProfile();
                          if (pRes.statusCode == 200) {
                            profile.value = Profile.fromJson(Map<String, dynamic>.from(pRes.data["user"]));
                            profile.notifyListeners();
                          }
                        }
                      } catch (e) {
                        if (kDebugMode) {
                          print(e);
                        }
                      }
                      if (mounted) {
                        Navigator.pop(context);
                      }
                  } else {
                    if (res.data["message"].runtimeType.toString().toLowerCase().contains("list")) {
                      for (var element in (res.data["message"] as List)) {
                        locator<SnackbarService>().showSnackbar(message: element);
                      }
                    } else {
                      locator<SnackbarService>().showSnackbar(message: res.data["message"]);
                    }
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print(e);
                  }
                }

                setState(() {
                  isLoading = false;
                });
              }
            },
            color: kcPrimaryColor,
          )
        ],
      ),
    );
  }

  // void loadCountries() async {
  //   try {
  //     setState(() {
  //       loadingCountries = true;
  //     });
  //     List<Country> countries = await CountryUtils().getSupportedCountries();
  //     setState(() {
  //       this.countries = countries;
  //       loadingCountries = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       loadingCountries = false;
  //     });
  //     if (kDebugMode) {
  //       print('Error loading countries: $e');
  //     }
  //   }
  // }
}


List<String> states = [
  "Abia",
  "Adamawa",
  "Akwa Ibom",
  "Anambra",
  "Bauchi",
  "Bayelsa",
  "Benue",
  "Borno",
  "Cross River",
  "Delta",
  "Ebonyi",
  "Edo",
  "Ekiti",
  "Enugu",
  "FCT - Abuja",
  "Gombe",
  "Imo",
  "Jigawa",
  "Kaduna",
  "Kano",
  "Katsina",
  "Kebbi",
  "Kogi",
  "Kwara",
  "Lagos",
  "Nasarawa",
  "Niger",
  "Ogun",
  "Ondo",
  "Osun",
  "Oyo",
  "Plateau",
  "Rivers",
  "Sokoto",
  "Taraba",
  "Yobe",
  "Zamfara"
];
