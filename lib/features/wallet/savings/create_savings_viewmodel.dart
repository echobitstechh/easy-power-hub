import 'package:easy_ph/core/data/models/product.dart';
import 'package:easy_ph/core/data/repositories/repository.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import 'package:easy_ph/core/network/api_response.dart';

class CreateSavingsViewModel extends BaseViewModel {
  final _repo = locator<Repository>();
  final _navigationService = locator<NavigationService>();
  final _snackBar = locator<SnackbarService>();

  List<Product> _products = [];
  List<Product> get products => _products;

  Product? _selectedProduct;
  Product? get selectedProduct => _selectedProduct;

  double get goalAmount =>
      double.tryParse(_selectedProduct?.price ?? '0') ?? 0.0;

  int _currentPage = 1;
  bool _isLastPage = false;
  final int _pageLimit = 20;

  String _searchQuery = '';
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  double _initialPayment = 0.0;
  double get initialPayment => _initialPayment;

  void init() {
    fetchProducts(isRefresh: true);
  }

  void setInitialPayment(String val) {
    _initialPayment = double.tryParse(val) ?? 0.0;
    notifyListeners();
  }

  Future<void> fetchProducts({bool isRefresh = false}) async {
    if (_isLastPage && !isRefresh) return;
    if (_isLoadingMore) return;

    if (isRefresh) {
      _products.clear();
      _currentPage = 1;
      _isLastPage = false;
      setBusy(true);
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      ApiResponse res;
      if (_searchQuery.isEmpty) {
        res = await _repo.getProducts(page: _currentPage, limit: _pageLimit);
      } else {
        res = await _repo.searchProducts(
            query: _searchQuery, page: _currentPage, limit: _pageLimit);
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        final List<dynamic> productsData = res.data["products"] ?? [];
        final newProducts = productsData
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        _products.addAll(newProducts);

        if (newProducts.length < _pageLimit) {
          _isLastPage = true;
        } else {
          _currentPage++;
        }
      }
    } catch (e) {
      _snackBar.showSnackbar(
        message: "Error fetching products",
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void performSearch(String query) {
    _searchQuery = query;
    fetchProducts(isRefresh: true);
  }

  void setSelectedProduct(Product product) {
    _selectedProduct = product;
    notifyListeners();
  }

  Future<void> createPlan() async {
    if (_selectedProduct == null) {
      _snackBar.showSnackbar(
        message: "Please select a product first",
        duration: const Duration(seconds: 3),
      );
      return;
    }
    if (_initialPayment <= 0) {
      _snackBar.showSnackbar(
        message: "Please enter a valid payment amount",
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Disclaimer Dialog
    final dialogService = locator<DialogService>();
    final confirmation = await dialogService.showConfirmationDialog(
      title: "Price Update Disclaimer",
      description:
          "Please note that if the price of this item increases while you are saving, your savings plan goal will be updated to reflect the new price.",
      confirmationTitle: "I Understand",
      cancelTitle: "Cancel",
    );

    if (confirmation == null || !confirmation.confirmed) {
      return;
    }

    setBusy(true);
    try {
      final res = await _repo.createSavings({
        "productId": _selectedProduct!.id,
        "amount": _initialPayment,
      });

      if (res.statusCode == 201 || res.statusCode == 200) {
        _navigationService.clearStackAndShow(Routes.savingsSuccessView);
      } else {
        _snackBar.showSnackbar(
          message: res.data["message"] ?? "Failed to create saving plan",
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _snackBar.showSnackbar(
        message: "An error occurred during plan creation",
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  void goBack() {
    _navigationService.back();
  }
}
