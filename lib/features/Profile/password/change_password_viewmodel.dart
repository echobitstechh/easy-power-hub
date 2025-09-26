
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../app/app.router.dart';
import '../../../core/data/repositories/repository.dart';
import '../../../core/network/api_response.dart';

class ChangePasswordViewModel extends BaseViewModel {
  final _repo = locator<Repository>();
  final _log = getLogger("ChangePasswordViewModel");
  final _snackBar = locator<SnackbarService>();
  final _navigationService = locator<NavigationService>();

  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  bool _obscure = true;
  bool get obscure => _obscure;

  void toggleObscure() {
    _obscure = !_obscure;
    notifyListeners();
  }

  // --- Validation Methods ---
  String? validateOldPassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Current password is required';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'New password is required';
    }
    if (value!.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    // Add other password strength checks here as needed
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password confirmation is required';
    }
    if (value != newPassword.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // --- Core Logic ---
  Future<void> changePassword({required bool isResetPassword}) async {
    setBusy(true);
    try {
      final requestBody = {
        "currentPassword": oldPassword.text,
        "newPassword": newPassword.text,
      };

      ApiResponse res = await _repo.resetPassword(requestBody);

      if (res.statusCode == 200) {
        _snackBar.showSnackbar(message: "Password updated successfully.", duration: Duration(seconds: 2));
        _navigationService.clearStackAndShow(Routes.profileView); // Navigate back to a specific screen
      } else {
        _snackBar.showSnackbar(message: res.data["message"] ?? "Unable to update password.", duration: Duration(seconds: 2));
      }
    } catch (e) {
      _log.e("Error changing password: $e");
      _snackBar.showSnackbar(message: "An error occurred while updating your password.", duration: Duration(seconds: 2));
    } finally {
      setBusy(false);
    }
  }
}