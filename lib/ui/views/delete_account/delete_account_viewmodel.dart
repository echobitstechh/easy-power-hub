import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.logger.dart';
import 'package:easyph/app/app.router.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/data/repositories/repository.dart';

class DeleteAccountViewModel extends BaseViewModel {
  final repo = locator<Repository>();
  final log = getLogger("EnterEmailViewModel");
  final email = TextEditingController();
  final code = TextEditingController();
  final snackBar = locator<SnackbarService>();
  bool emailVerified = false;

  void sendCode() async {
    setBusy(true);

    try {
      ApiResponse res = await repo.requestDelete({
        "email": email.text,
      });
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

  void delete() async {
    setBusy(true);

    try {
      ApiResponse res = await repo.deleteAccount({
        "code": code.text,
      });
      if (res.statusCode == 200) {
        snackBar.showSnackbar(message: "Account deleted");
        locator<NavigationService>().replaceWithAuthView();
      }
    } catch (e) {
      log.e(e);
    }

    setBusy(false);
  }
}
