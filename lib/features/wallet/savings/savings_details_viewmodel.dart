import 'package:easy_ph/core/data/models/cart_item.dart';
import 'package:easy_ph/core/data/models/savings.dart';
import 'package:easy_ph/core/data/repositories/repository.dart';
import 'package:easy_ph/core/utils/paystack_util.dart';
import 'package:easy_ph/state.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../app/app.bottomsheets.dart';

class SavingsDetailsViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _repo = locator<Repository>();
  final _snackbarService = locator<SnackbarService>();

  late SavingsPlan _plan;
  SavingsPlan get plan => _plan;

  Future<void> init(SavingsPlan plan) async {
    _plan = plan;
    await fetchPlanDetails();
  }

  Future<void> fetchPlanDetails() async {
    setBusy(true);
    try {
      final res = await _repo.getSavingsDetail(_plan.id);
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data['data'] ?? res.data['savings'] ?? res.data;
        _plan = SavingsPlan.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      print('Error fetching savings details: $e');
    } finally {
      setBusy(false);
    }
  }

  void showPaymentOverlay(BuildContext context) async {
    final response = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.savingsPayment,
      data: _plan,
    );

    if (response?.confirmed == true && response?.data != null) {
      final double amount = response!.data;
      await _initializeSavingsPayment(context, amount);
    }
  }

  Future<void> _initializeSavingsPayment(
      BuildContext context, double amount) async {
    setBusy(true);
    try {
      final res = await _repo.initializePayment({
        'paymentMethod': 'CreditCard',
        'paymentType': 'Paystack',
        'savingPlanId': _plan.id,
        'savingAmount': amount.toInt(),
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
          cartItems: [], // No cart items for savings payment
        );
        _navigationService.navigateTo(Routes.savingsSuccessView);
      } else {
        _snackbarService.showSnackbar(
          message: res.data['message'] ?? 'Payment initialization failed',
          duration: const Duration(seconds: 2)
        );
      }
    } catch (e) {
      _snackbarService.showSnackbar(message: 'Payment error: $e',
      duration: const Duration(seconds: 2));
    } finally {
      setBusy(false);
    }
  }

  void moveToCheckout() {
    final product = _plan.product;
    final price =
        double.tryParse(product.salePrice ?? product.price ?? '0') ?? 0;

    final cartItem = CartItem(
      product: product,
      quantity: 1,
      price: price,
      isInstallment: false,
    );

    _navigationService.navigateTo(
      Routes.checkoutView,
      arguments: CheckoutViewArguments(
        cartSubtotal: price.toInt(),
        cartDiscount: 0,
        cartItems: [cartItem],
        calculatedFinalTotal: price.toInt(),
      ),
    );
  }

  void goBack() {
    _navigationService.back();
  }
}
