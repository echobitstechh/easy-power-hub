import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';

void setupSnackbarUi() {
  locator<SnackbarService>().registerSnackbarConfig(
    SnackbarConfig(
      backgroundColor: const Color(0xFF1E1E2E),
      textColor: Colors.white,
      messageColor: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      borderRadius: 12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: const Duration(seconds: 3),
      isDismissible: true,
    ),
  );
}
