import 'package:easy_ph/core/data/models/wallet_transaction.dart';
import 'package:easy_ph/core/data/repositories/repository.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../app/app.router.dart';

class WalletViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _repository = locator<Repository>();
  final _snackbar = locator<SnackbarService>();

  double _totalBalance = 0.0;
  double get totalBalance => _totalBalance;

  bool _isBalanceVisible = true;
  bool get isBalanceVisible => _isBalanceVisible;

  List<WalletTransaction> _allTransactions = [];
  List<WalletTransaction> _filteredTransactions = [];
  List<WalletTransaction> get transactions => _filteredTransactions;

  String _currentFilter = 'All';
  String get currentFilter => _currentFilter;

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  Future<void> init() async {
    setBusy(true);

    await Future.wait([
      _fetchBalance(),
      _fetchHistory(),
    ]);

    setBusy(false);
  }

  Future<void> _fetchBalance() async {
    try {
      final res = await _repository.getWalletBalance();
      if (res.statusCode == 200 || res.statusCode == 201) {
        _totalBalance =
            double.tryParse(res.data['data']['balance'].toString()) ?? 0.0;
      }
    } catch (e) {
      print('Error fetching wallet balance: $e');
    }
  }

  Future<void> _fetchHistory() async {
    try {
      final res = await _repository.getWalletHistory(page: 1, limit: 20);
      if (res.statusCode == 200 || res.statusCode == 201) {
        final List<dynamic> data =
            res.data['data']?['transactions'] ?? res.data['data'] ?? [];
        _allTransactions = data
            .map(
                (e) => WalletTransaction.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _filteredTransactions = _allTransactions;
      } else {
        _snackbar.showSnackbar(
            message: res.data['message'] ?? 'Failed to load transactions',
            duration: const Duration(seconds: 3));
      }
    } catch (e) {
      print('Error fetching wallet history: $e');
    }
  }

  void filterTransactions(String filter) {
    _currentFilter = filter;
    if (filter == 'All') {
      _filteredTransactions = _allTransactions;
    } else {
      _filteredTransactions = _allTransactions.where((t) {
        if (filter == 'Savings') return t.type == TransactionType.savings;
        if (filter == 'Installments')
          return t.type == TransactionType.installments;
        if (filter == 'Successful')
          return t.status == TransactionStatus.successful;
        if (filter == 'Failed') return t.status == TransactionStatus.failed;
        if (filter == 'Processing')
          return t.status == TransactionStatus.processing;
        return true;
      }).toList();
    }
    notifyListeners();
  }

  void navigateToSavings() {
    _navigationService.navigateTo(Routes.mySavingsView);
  }

  void navigateToInstallments() {
    _navigationService.navigateTo(Routes.myInstallmentsView);
  }

  void goBack() {
    _navigationService.back();
  }
}
