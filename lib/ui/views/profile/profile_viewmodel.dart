import 'dart:convert';
import 'dart:io';

import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.logger.dart';
import 'package:easyph/core/data/models/profile.dart';
import 'package:easyph/core/data/repositories/repository.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:easyph/state.dart';
import 'package:stacked/stacked.dart';
import 'package:path/path.dart' as path;
import 'package:stacked_services/stacked_services.dart';

import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';

class ProfileViewModel extends BaseViewModel {
  final repo = locator<Repository>();
  final log = getLogger("ProfileViewModel");
  bool showChangePP = false;
  final snackBar = locator<SnackbarService>();

  void toggleShowChangePP() {
    showChangePP = !showChangePP;
    rebuildUi();
  }

  File? selectedFile;

  void updateProfileImage(File? file) {
    if (file == null) return;

    selectedFile = file;
    notifyListeners(); // Refresh UI
    updateProfilePicture(file); // Now triggers API call
  }

  void updateProfilePicture(File file) async {
    setBusy(true);

    try {
      // Read image as bytes
      List<int> imageBytes = await file.readAsBytes();

      // Convert to Base64
      String base64Image = base64Encode(imageBytes);

      log.i("Uploading Base64 Image");

      // Send Base64 string to API
      ApiResponse res = await repo.updateProfilePicture({
        "profilePicture": base64Image = "data:image/png;base64," + base64Encode(imageBytes)// Send as Base64 string
      });

      if (res.statusCode == 200) {
        snackBar.showSnackbar(message: res.data["message"]);
        getProfile(); // Refresh profile after upload
      } else {
        log.e("Failed to upload image");
      }
    } catch (e) {
      log.e("Error uploading image: $e");
    }

    setBusy(false);
  }

  void updateProfileData({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    Map<String, dynamic> updatedData = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
    };

    ApiResponse response = await repo.updateProfile(updatedData);

    if (response.statusCode == 200) {
      profile.value.firstName = firstName;
      profile.value.lastName = lastName;
      profile.value.email = email;
      profile.value.phoneNumber = phoneNumber;

      locator<SnackbarService>().showSnackbar(
        message: "Profile updated successfully",
        duration: Duration(seconds: 2),
      );
    } else {
      locator<SnackbarService>().showSnackbar(
        message: response.data["message"] ?? "Failed to update profile",
        duration: Duration(seconds: 2),
      );
    }
  }


  void getProfile() async {

    final localProfileJson = await locator<LocalStorage>().fetch(LocalStorageDir.profileView);
    if (localProfileJson != null) {
      profile.value = Profile.fromJson(localProfileJson);
      rebuildUi();
    }

    try {
      ApiResponse res = await repo.getProfile();
      if (res.statusCode == 200) {
        profile.value =
            Profile.fromJson(Map<String, dynamic>.from(res.data["data"]));
        await locator<LocalStorage>().save(LocalStorageDir.profileView, res.data["data"]); // Cache updated profile
        rebuildUi(); // Update UI with fresh data
      }
    } catch (e) {
      log.e(e);
    }

    setBusy(false);
  }


  // void getProfile() async {
  //   setBusy(true);
  //   try {
  //     ApiResponse res = await repo.getProfile();
  //     if (res.statusCode == 200) {
  //       profile.value =
  //           Profile.fromJson(Map<String, dynamic>.from(res.data["user"]));
  //       rebuildUi();
  //     }
  //   } catch (e) {
  //     log.e(e);
  //   }
  //   setBusy(false);
  // }


}
