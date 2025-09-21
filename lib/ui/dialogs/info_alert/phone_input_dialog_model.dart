import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class PhoneInputDialogModel extends BaseViewModel {
  final phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}