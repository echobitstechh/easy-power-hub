import 'dart:convert';

import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.logger.dart';
import 'package:easyph/app/app.router.dart';
import 'package:easyph/core/data/repositories/repository.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:easyph/ui/components/success_page.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/data/models/profile.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../state.dart';

class OtpViewModel extends BaseViewModel {
  final otp = TextEditingController();
  final repo = locator<Repository>();
  final snackBar = locator<SnackbarService>();
  final log = getLogger("OtpViewModel");

  void verify(String email, context) async {
    setBusy(true);

    try {
      // Perform the API call
      ApiResponse res = await repo.verify({
        "email": email,
        "otp": otp.text.toString(),
      });

      // Check if the status code is 201
      if (res.statusCode == 201) {
        // Extract the 'data' from the response
        if (res.data != null && res.data["data"] != null) {
          final data = res.data["data"];

          // Extract user information
          if (data["user"] != null && data["user"] is Map<String, dynamic>) {
            profile.value = Profile.fromJson(Map<String, dynamic>.from(data["user"]));

            print('value of data is: $data');
            // Extract tokens
            String? token = data["accessToken"];
            String? refreshToken = data["refreshToken"];

            if (token != null && refreshToken != null) {
              // Save tokens and user data
              locator<LocalStorage>().save(LocalStorageDir.authToken, token);
              locator<LocalStorage>().save(LocalStorageDir.authRefreshToken, refreshToken);
              locator<LocalStorage>().save(LocalStorageDir.authUser, jsonEncode(data["user"]));

              // Set the user as logged in
              userLoggedIn.value = true;

              // Navigate to the Success Page
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
                return SuccessPage(
                  title: "Congratulations!!!",
                  description: "Your account is ready!",
                  callback: () {
                    locator<NavigationService>().clearStackAndShow(Routes.homeView);
                  },
                );
              }));
            } else {
              // Handle missing tokens
              snackBar.showSnackbar(message: "Authentication tokens are missing.");
            }
          } else {
            // Handle invalid user data
            snackBar.showSnackbar(message: "Invalid user data received.");
          }
        } else {
          // Handle missing 'data' in the response
          snackBar.showSnackbar(message: "Invalid response from server.");
        }
      } else {
        // Show the error message from the response
        snackBar.showSnackbar(message: res.data["message"] ?? "Verification failed.");
      }
    } catch (e) {
      // Log the error and show a generic error message
      log.e(e);
      snackBar.showSnackbar(message: "An error occurred during verification.");
    }

    setBusy(false);
  }

  void resendOtp(String email, context) async {
    setBusy(true);

    try {
      ApiResponse res = await repo.sendOtp({
        "email": email,
      });
      if (res.statusCode == 201) {
        snackBar.showSnackbar(message:"Otp sent to $email");
        otp.text = '';
      } else {
        snackBar.showSnackbar(message: res.data["message"]);
      }
    } catch (e) {
      log.e(e);
    }

    setBusy(false);
  }

}


