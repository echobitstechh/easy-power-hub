import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.logger.dart';
import 'package:easyph/core/data/repositories/repository.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.router.dart';

class EnterEmailViewModel extends BaseViewModel {
  final repo = locator<Repository>();
  final log = getLogger("EnterEmailViewModel");
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final password = TextEditingController();
  final cPassword = TextEditingController();
  final snackBar = locator<SnackbarService>();
  bool obscure = true;
  bool _codeSent = false; // Make this private and use a getter

  // Getter for codeSent to ensure proper encapsulation
  bool get codeSent => _codeSent;

  void toggleObscure() {
    obscure = !obscure;
    notifyListeners(); // Use notifyListeners() to rebuild the UI
  }

  void sendCode() async {
    setBusy(true);
    debugPrint('Starting sendCode process');

    try {
      ApiResponse res = await repo.forgotPassword({
        "email": emailController.text,
      });

      if (res.statusCode == 201) {
        debugPrint('Code sent successfully'); // Debug log
        snackBar.showSnackbar(message: "Code sent to ${emailController.text}");
        _codeSent = true; // Update the private variable
        notifyListeners(); // Trigger UI rebuild
        debugPrint('_codeSent updated to true'); // Debug log
      } else {
        debugPrint('Failed to send code: ${res.statusCode}'); // Debug log
      }
    } catch (e) {
      debugPrint('Error in sendCode: $e');
      snackBar.showSnackbar(message: "Unable to send code: $e");
    } finally {
      setBusy(false); // Ensure busy state is reset
    }

    debugPrint('Completed sendCode process');
  }

  void resetPassword() async {
    setBusy(true);

    try {
      ApiResponse res = await repo.newPassword({
        "email": emailController.text,
        "otp": codeController.text,
        "password": password.text,
        "confirm_password": cPassword.text,
      });

      if (res.statusCode == 201) {
        snackBar.showSnackbar(message: "Password Successfully changed");
        locator<NavigationService>().clearStackAndShow(Routes.authView);
      }
    } catch (e) {
      debugPrint('Error in resetPassword: $e');
      snackBar.showSnackbar(message: "Error resetting password: $e");
    } finally {
      setBusy(false); // Ensure busy state is reset
    }
  }
}