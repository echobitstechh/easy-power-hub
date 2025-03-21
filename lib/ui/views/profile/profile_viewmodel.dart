import 'dart:convert';
import 'dart:io';

import 'package:afriprize/app/app.locator.dart';
import 'package:afriprize/app/app.logger.dart';
import 'package:afriprize/core/data/models/profile.dart';
import 'package:afriprize/core/data/repositories/repository.dart';
import 'package:afriprize/core/network/api_response.dart';
import 'package:afriprize/state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
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
