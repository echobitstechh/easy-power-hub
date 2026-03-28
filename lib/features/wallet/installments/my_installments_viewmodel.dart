import 'package:easy_ph/core/data/models/installment.dart';
import 'package:easy_ph/core/data/repositories/repository.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';

class MyInstallmentsViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _repository = locator<Repository>();
  final _snackbar = locator<SnackbarService>();

  List<InstallmentPlan> _allInstallments = [];
  List<InstallmentPlan> _filteredInstallments = [];
  List<InstallmentPlan> get installments => _filteredInstallments;

  String _currentFilter = 'All';
  String get currentFilter => _currentFilter;

  Future<void> init() async {
    setBusy(true);
    try {
      final response = await _repository.getInstallments();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data =
            response.data['data'] ?? response.data['installments'] ?? [];
        _allInstallments = data
            .map((e) => InstallmentPlan.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _filteredInstallments = _allInstallments;
      } else {
        _snackbar.showSnackbar(
          message: response.data['message'] ?? 'Failed to load installments',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _snackbar.showSnackbar(
        message: 'Error loading installments',
        duration: const Duration(seconds: 2),
      );
    } finally {
      setBusy(false);
    }
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    if (filter == 'All') {
      _filteredInstallments = _allInstallments;
    } else if (filter == 'In Progress') {
      _filteredInstallments =
          _allInstallments.where((p) => !p.isCompleted).toList();
    } else if (filter == 'Completed') {
      _filteredInstallments =
          _allInstallments.where((p) => p.isCompleted).toList();
    }
    notifyListeners();
  }

  void navigateToDetails(InstallmentPlan plan) {
    _navigationService.navigateTo(Routes.installmentDetailsView,
        arguments: InstallmentDetailsViewArguments(plan: plan));
  }

  void goBack() {
    _navigationService.back();
  }
}
