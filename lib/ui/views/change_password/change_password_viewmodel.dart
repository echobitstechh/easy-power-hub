import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.logger.dart';
import 'package:easyph/core/data/repositories/repository.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ChangePasswordViewModel extends BaseViewModel {
  final repo = locator<Repository>();
  final log = getLogger("EnterEmailViewModel");
  final email = TextEditingController();
  final code = TextEditingController();
  final newPassword = TextEditingController();
  final oldPassword = TextEditingController();
  final confirmPassword = TextEditingController();
  final snackBar = locator<SnackbarService>();
  bool emailVerified = false;
  bool obscure = true;

  void toggleObscure() {
    obscure = !obscure;
    rebuildUi();
  }

  void sendCode() async {
    setBusy(true);

    try {
      ApiResponse res = await repo.resetPasswordRequest(email.text);
      if (res.statusCode == 200) {
        snackBar.showSnackbar(message: "Verification code sent");
        emailVerified = true;
        rebuildUi();
      }
    } catch (e) {
      log.e(e);
    }

    setBusy(false);
  }

  void changePassword(context, bool isResetPassword) async {
    setBusy(true);
    try {
      ApiResponse res =
          await repo.resetPassword(
              {
                "currentPassword": oldPassword.text,
                "newPassword": newPassword.text,
              },
            );

      if (res.statusCode == 200) {
        snackBar.showSnackbar(message: "Password Updated");
        Navigator.pop(context);
      }
    } catch (e) {
      log.e(e);
      snackBar.showSnackbar(message: "Unable to update password: $e");
    }

    setBusy(false);
  }
}
