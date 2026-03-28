import 'package:easy_ph/core/data/models/installment.dart';
import 'package:easy_ph/core/data/repositories/repository.dart';
import 'package:easy_ph/core/utils/paystack_util.dart';
import 'package:easy_ph/state.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../app/app.bottomsheets.dart';

class InstallmentDetailsViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _repo = locator<Repository>();
  final _snackbarService = locator<SnackbarService>();

  late InstallmentPlan _plan;
  InstallmentPlan get plan => _plan;

  void init(InstallmentPlan plan) {
    _plan = plan;
  }

  void showPaymentOverlay(BuildContext context) async {
    final response = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.installmentPayment,
      data: _plan,
    );

    if (response?.confirmed == true && response?.data != null) {
      final double amount = response!.data;
      await _initializeInstallmentPayment(context, amount);
    }
  }

  Future<void> _initializeInstallmentPayment(
      BuildContext context, double amount) async {
    if (_plan.orderId == null) {
      _snackbarService.showSnackbar(message: 'Order ID missing for this plan',
      duration: const Duration(seconds: 2)
      );
      return;
    }

    setBusy(true);
    try {
      final res = await _repo.initializePayment({
        'paymentMethod': 'CreditCard',
        'paymentType': 'Paystack',
        'orderId': _plan.orderId,
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data['data'];
        await PaystackUtil.processPayment(
          context: context,
          ref: data['reference'],
          accessCode: data['access_code'],
          url: data['authorization_url'],
          amountInNaira: amount.toInt(),
          email: profile.value.email ?? '',
          cartItems: [],
        );
        _navigationService.navigateTo(Routes.paymentSuccessView);
      } else {
        _snackbarService.showSnackbar(
          message: res.data['message'] ?? 'Payment initialization failed',
          duration: const Duration(seconds: 2)
        );
      }
    } catch (e) {
      _snackbarService.showSnackbar(message: 'Payment error: $e',
      duration: const Duration(seconds: 2)
      );
    } finally {
      setBusy(false);
    }
  }

  void goBack() {
    _navigationService.back();
  }
}
