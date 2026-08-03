import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../app/app.router.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../app/app.bottomsheets.dart';
import '../../app/app.locator.dart';
import '../../app/app.logger.dart';
import '../../core/data/models/profile.dart';
import '../../core/data/repositories/repository.dart';
import '../../core/network/api_response.dart';
import '../../core/utils/local_stotage.dart';
import '../../state.dart';

class ProfileViewModel extends BaseViewModel {
  final _repo = locator<Repository>();
  final _log = getLogger("ProfileViewModel");
  final _snackBar = locator<SnackbarService>();
  final _localStorage = locator<LocalStorage>();
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _dialogService = locator<DialogService>();

  String _appVersion = '';
  String get appVersion => _appVersion;

  void loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = '${info.version} (${info.buildNumber})';
      notifyListeners();
    } catch (e) {
      _log.e('Failed to load version: $e');
    }
  }

  File? _selectedFile;
  File? get selectedFile => _selectedFile;

  // void showProfileDetailBottomSheet() {
  //   _bottomSheetService..showBottomSheet(
  //       builder: (context, router) => ProfileScreen(viewModel: this),
  //       is
  //   );
  // }

  void showProfileDetailBottomSheet() {
    _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.profileScreen,
      data: this,
    );
  }

  void updateProfileImage(File? file) {
    if (file == null) return;
    _selectedFile = file;
    notifyListeners();
    _uploadProfilePicture(file);
  }

  // New method to handle the API upload
  void _uploadProfilePicture(File file) async {
    setBusy(true);

    try {
      List<int> imageBytes = await file.readAsBytes();
      String base64Image = "data:image/png;base64,${base64Encode(imageBytes)}";

      ApiResponse res = await _repo.updateProfilePicture({
        "profilePicture": base64Image // Send as Base64 string
      });

      if (res.statusCode == 200) {
        _snackBar.showSnackbar(message: res.data["message"]);
        getProfile();
      } else {
        _log.e("Failed to upload image");
        _snackBar.showSnackbar(message: res.data["message"] ?? "Failed to upload image.");
      }
    } catch (e) {
      _log.e("Error uploading image: $e");
      _snackBar.showSnackbar(message: "An error occurred while uploading the image.",
          duration: Duration(seconds: 1));
    } finally {
      setBusy(false);
    }
  }

  void updateProfileData({
    required String firstName,
    required String lastName,
     String? email,
     String? phoneNumber,
  }) async {
    setBusy(true);
    try {
      Map<String, dynamic> updatedData = {
        'firstName': firstName,
        'lastName': lastName,
        // 'email': email,
        // 'phoneNumber': phoneNumber,
      };

      ApiResponse response = await _repo.updateProfile(updatedData);

      if (response.statusCode == 200) {
        profile.value.firstName = firstName;
        profile.value.lastName = lastName;
        profile.value.email = email;
        profile.value.phoneNumber = phoneNumber;

        _snackBar.showSnackbar(
          message: "Profile updated successfully",
          duration: const Duration(seconds: 2),
        );
        getProfile(); // Refresh profile after update
      } else {
        _snackBar.showSnackbar(
          message: response.data["message"] ?? "Failed to update profile",
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _log.e("Error updating profile data: $e");
      _snackBar.showSnackbar(
        message: "An error occurred while updating your profile.",
        duration: const Duration(seconds: 2),
      );
    } finally {
      setBusy(false);
    }
  }

  void showEditProfileDialog(BuildContext context) {
    // These controllers are created here and will be disposed of when the dialog is dismissed.
    final TextEditingController firstNameController = TextEditingController(
      text: profile.value.firstName,
    );

    final TextEditingController lastNameController = TextEditingController(
      text: profile.value.lastName,
    );

    final TextEditingController emailController = TextEditingController(
      text: profile.value.email,
    );

    final TextEditingController phoneController = TextEditingController(
      text: profile.value.phoneNumber,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastNameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                String newFirstName = firstNameController.text.trim();
                String newLastName = lastNameController.text.trim();
                // String newEmail = emailController.text.trim();
                // String newPhone = phoneController.text.trim();

                // Call the ViewModel method with the new values
                updateProfileData(
                  firstName: newFirstName,
                  lastName: newLastName,
                  // email: newEmail,
                  // phoneNumber: newPhone,
                );

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }




  Future<void> getProfile() async {
    if (!userLoggedIn.value) return;

    setBusy(true);
    try {
      final localProfileJson = await _localStorage.fetch(LocalStorageDir.authUser);
      if (localProfileJson != null) {
        profile.value = Profile.fromJson(jsonDecode(localProfileJson));
      }

      ApiResponse res = await _repo.getProfile();
      if (res.statusCode == 200) {
        profile.value = Profile.fromJson(Map<String, dynamic>.from(res.data["data"]));
        await _localStorage.save(LocalStorageDir.authUser, jsonEncode(res.data["data"]));
      } else {
        _snackBar.showSnackbar(message: res.data['message'] ?? "Failed to fetch profile.");
      }
    } catch (e) {
      _log.e("Error fetching profile: $e");
      _snackBar.showSnackbar(message: "An error occurred while fetching your profile.");
    } finally {
      setBusy(false);
    }
  }

  Future<void> onDeleteAccount() async => onSignOut();

  Future<void> onSignOut() async {
    final context = StackedService.navigatorKey!.currentContext!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      userLoggedIn.value = false;
      await _localStorage.delete(LocalStorageDir.authToken);
      await _localStorage.delete(LocalStorageDir.authUser);
      await _localStorage.delete(LocalStorageDir.productCart);
      await _localStorage.delete(LocalStorageDir.authRefreshToken);
      cart.value.clear();
      _navigationService.clearStackAndShow(Routes.login);
    }
  }

  // Navigation Handlers
  void navigateToOrders() => _navigationService.navigateTo(Routes.orderList);
  void navigateToShippingAddresses() => _navigationService.navigateTo(Routes.shippingAddressesPage);
  void navigateToSupport() => _navigationService.navigateTo(Routes.supportView);
  void navigateToReferrals() => _navigationService.navigateTo(Routes.referralsView);
  void navigateToChangePassword() => _navigationService.navigateTo(Routes.changePasswordView);
  void navigateToLogin() => _navigationService.navigateTo(Routes.login);
  void navigateToRegister() => _navigationService.navigateTo(Routes.register);
}