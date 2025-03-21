import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.logger.dart';
import 'package:easyph/core/data/models/bank.dart';
import 'package:easyph/core/data/repositories/repository.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class WithdrawViewModel extends BaseViewModel {
  final repo = locator<Repository>();
  final snackBar = locator<SnackbarService>();
  final log = getLogger("WithdrawViewModel");
  final amount = TextEditingController();
  final accountName = TextEditingController();
  final accountNumber = TextEditingController();
  List<Bank> banks = [];
  String? selectedBank;

  void changeBank(v) {
    selectedBank = v;
    rebuildUi();
  }

  void withdraw(context) async {
    setBusy(true);
    Bank bank =
        banks.where((element) => element.name == selectedBank).toList().first;
    try {
      ApiResponse res = await repo.withdraw({
        "account_name": accountName.text,
        "account_number": accountNumber.text,
        "bank_code": bank.code,
        "amount": int.parse(amount.text),
        "reason": "withdrawal"
      });
      if (res.statusCode == 200) {
        snackBar.showSnackbar(message: res.data["message"]);
        Navigator.pop(context);
      } else {
        snackBar.showSnackbar(message: res.data["message"]);
      }
    } catch (e) {
      log.e(e);
    }
    setBusy(false);
  }

  void verifyName() async {
    try {
      Bank bank =
          banks.where((element) => element.name == selectedBank).toList().first;
      ApiResponse res = await repo.verifyName({
        "bank_code": bank.code,
        "account_number": accountNumber.text,
      });
      if (res.statusCode == 200) {
        accountName.text = res.data["details"]["data"]["account_name"];
      } else {
        snackBar.showSnackbar(message: res.data["message"]);
      }
    } catch (e) {
      log.e(e);
    }
  }

  void getBanks() async {
    setBusyForObject(banks, true);
    try {
      ApiResponse res = await repo.getBanks();
      if (res.statusCode == 200) {
        banks = (res.data["banks"]["data"] as List)
            .map((e) => Bank.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        rebuildUi();
      }
    } catch (e) {
      log.e(e);
    }
    setBusyForObject(banks, false);
  }
}
