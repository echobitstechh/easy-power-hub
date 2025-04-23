

import 'package:stacked_services/stacked_services.dart';

import '../app/app.dialogs.dart';
import '../app/app.locator.dart';
import '../state.dart';


Future<DialogResponse?> showDialogWithResponse(String title, String? description, bool isDialogBeingDisplayed) async {
  if (!isDialogBeingDisplayed) {
    isDialogBeingDisplayed = true;
    DialogResponse? res = await locator<DialogService>().showCustomDialog(
      variant: DialogType.infoAlert,
      title: title,
      description: description,
    );
    isDialogBeingDisplayed = false;
    return res;
  }
  return null;
}

Future<bool?> showDialog(String title, String? description, bool isDialogBeingDisplayed) async {
  if (!isDialogBeingDisplayed) {
    isDialogBeingDisplayed = true;
    // DialogResponse? res = await locator<DialogService>().showCustomDialog(
    //   variant: DialogType.infoAlert,
    //   title: title,
    //   description: description,
    // );
    locator<SnackbarService>().showSnackbar(title: title,message: description ?? '', duration: const Duration(seconds: 2));
    isDialogBeingDisplayed = false;
    appLoading.value = false;
    return isDialogBeingDisplayed;
  }
  return null;
}