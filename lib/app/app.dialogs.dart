// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/dialogs/info_alert/info_alert_dialog.dart';
import '../ui/dialogs/info_alert/phone_input_dialog.dart';
import '../ui/dialogs/info_alert/rating_dialog.dart';
import '../ui/dialogs/info_alert/reason_form_dialog.dart';
import '../ui/dialogs/info_alert/update_dialog.dart';
import '../ui/dialogs/info_alert/incomplete_biodata_dialog.dart';

enum DialogType {
  infoAlert,
  rating,
  phoneInput,
  serviceRejectReason,
  update,
  incompleteBiodata,
}

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final Map<DialogType, DialogBuilder> builders = {
    DialogType.infoAlert: (context, request, completer) =>
        InfoAlertDialog(request: request, completer: completer),
    DialogType.rating: (context, request, completer) =>
        RatingDialog(request: request, completer: completer),
    DialogType.phoneInput: (context, request, completer) =>
        PhoneInputDialog(request: request, completer: completer),
    DialogType.serviceRejectReason: (context, request, completer) =>
        ServiceRejectReasonDialog(request: request, completer: completer),
    DialogType.update: (context, request, completer) =>
        UpdateDialog(request: request, completer: completer),
    DialogType.incompleteBiodata: (context, request, completer) =>
        IncompleteBiodataDialog(request: request, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}
