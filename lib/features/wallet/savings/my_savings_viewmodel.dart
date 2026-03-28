import 'package:easy_ph/core/data/models/savings.dart';
import 'package:easy_ph/core/data/repositories/repository.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';

class MySavingsViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _repo = locator<Repository>();
  final _snackbarService = locator<SnackbarService>();

  List<SavingsPlan> _savingsPlans = [];
  List<SavingsPlan> get savingsPlans => _savingsPlans;

  Future<void> init() async {
    setBusy(true);
    try {
      final response = await _repo.getSavings();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data =
            response.data['data'] ?? response.data['savings'] ?? [];
        _savingsPlans = data
            .map((e) => SavingsPlan.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        _snackbarService.showSnackbar(
          message: response.data['message'] ?? 'Failed to load savings plans',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Error loading savings plans',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> cancelPlan(String planId) async {
    setBusy(true);
    try {
      final response = await _repo.cancelSavingsPlan(planId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _snackbarService.showSnackbar(
            message: 'Plan cancelled successfully',
            duration: const Duration(seconds: 3));
        await init(); // Refresh list
      } else {
        _snackbarService.showSnackbar(
            message: response.data['message'] ?? 'Failed to cancel plan',
            duration: const Duration(seconds: 3));
      }
    } catch (e) {
      _snackbarService.showSnackbar(
          message: 'An error occurred', duration: const Duration(seconds: 3));
    } finally {
      setBusy(false);
    }
  }

  void navigateToDetails(SavingsPlan plan) {
    _navigationService.navigateTo(
      Routes.savingsDetailsView,
      arguments: SavingsDetailsViewArguments(plan: plan),
    );
  }

  void navigateToCreateSavings() {
    _navigationService.navigateTo(Routes.createSavingsView);
  }

  void goBack() {
    _navigationService.back();
  }
}
