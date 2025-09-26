
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../../app/app.locator.dart';
import '../../../../app/app.logger.dart';
import '../../../../app/app.router.dart';
import '../../../../core/data/repositories/repository.dart';
import '../../../../core/network/api_response.dart';


class EnterEmailViewModel extends BaseViewModel {
  final _repo = locator<Repository>();
  final _log = getLogger("EnterEmailViewModel");
  final _snackBar = locator<SnackbarService>();
  final _navigationService = locator<NavigationService>();

  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final password = TextEditingController();
  final cPassword = TextEditingController();

  bool _obscure = true;
  bool get obscure => _obscure;
  void toggleObscure() {
    _obscure = !_obscure;
    notifyListeners();
  }

  bool _codeSent = false;
  bool get codeSent => _codeSent;

  // --- Validation Helpers ---
  String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validateCode(String value) {
    if (value.isEmpty) {
      return 'Verification code is required';
    }
    // You might add additional checks here, e.g., code length
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters long';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Password must contain at least one uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Password must contain at least one lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Password must contain at least one digit';
    if (!RegExp(r'[!@#$%^&*]').hasMatch(value)) return 'Password must contain at least one special character';
    return null;
  }

  String? validateConfirmPassword(String value) {
    if (value.isEmpty) return 'Password confirmation is required';
    if (value != password.text) return 'Passwords do not match';
    return null;
  }

  // --- Core Logic ---

  Future<void> sendCode() async {
    await runBusyFuture(
      _sendCodeInternal(),
      busyObject: 'sendCode',
    );
  }

  Future<void> _sendCodeInternal() async {
    try {
      ApiResponse res = await _repo.forgotPassword({"email": emailController.text});

      if (res.statusCode == 201) {
        _snackBar.showSnackbar(message: "Code sent to ${emailController.text}");
        _codeSent = true;
      } else {
        _snackBar.showSnackbar(message: res.data["message"] ?? "Failed to send code. Please try again.");
      }
    } catch (e) {
      _log.e('Error in sendCode: $e');
      _snackBar.showSnackbar(message: "Unable to send code: $e");
    }
  }

  Future<void> resetPassword() async {
    await runBusyFuture(
      _resetPasswordInternal(),
      busyObject: 'resetPassword',
    );
  }

  Future<void> _resetPasswordInternal() async {
    try {
      ApiResponse res = await _repo.newPassword({
        "token": codeController.text,
        "password": password.text,
      });

      if (res.statusCode == 200) {
        _snackBar.showSnackbar(message: "Password changed successfully.");
        _navigationService.clearStackAndShow(Routes.login);
      } else {
        _snackBar.showSnackbar(message: res.data["message"] ?? "Failed to reset password. Please try again.");
      }
    } catch (e) {
      _log.e('Error in resetPassword: $e');
      _snackBar.showSnackbar(message: "Error resetting password: $e");
    }
  }
}