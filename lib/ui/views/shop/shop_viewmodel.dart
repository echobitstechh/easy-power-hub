import 'dart:async';
import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.logger.dart';
import 'package:easyph/core/data/models/cart_item.dart';
import 'package:easyph/core/data/models/product.dart';
import 'package:easyph/core/data/repositories/repository.dart';
import 'package:easyph/core/utils/local_store_dir.dart';
import 'package:easyph/core/utils/local_stotage.dart';
import 'package:easyph/state.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../core/data/models/category.dart';

class ShopViewModel extends BaseViewModel {
  final repo = locator<Repository>();
  final log = getLogger("DashboardViewModel");
  List<Ads> adsList = [];
  List<Product> productList = [];
  List<String> brands = [];
  List<Product> filteredProductList = [];
  List<Category> filteredCategories = [];
  List<Category> categories = [];

  static const int allCategoriesId = 0;

  int selectedId = allCategoriesId;
  String selectedBrand = '';

  bool? onboarded;

  bool showDialog = true;
  bool modalShown = false;
  bool appBarLoading = false;
  bool shouldShowShowcase = true;

  Set<String> loadingItems = {};


  int currentPage = 1;
  bool isLastPage = false;
  bool isLoadingMore = false;
  final int pageLimit = 10;


  final snackBar = locator<SnackbarService>();

  Timer? _debounceTimer;
  bool _isInitializing = false;

  bool isNewProduct(String createdAt) {
    final productDate = DateTime.parse(createdAt);
    final currentDate = DateTime.now();
    final difference = currentDate.difference(productDate).inDays;
    return difference <= 14;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> init() async {
    setBusy(true);
    notifyListeners();
    await getProducts();
    setBusy(false);
    notifyListeners();
  }

  Future<void> refreshData() async {
    setBusy(true);
    notifyListeners();
    setBusy(false);
    notifyListeners();
  }

  void initCart() async {
    try {
      dynamic storedData =
          await locator<LocalStorage>().fetch(LocalStorageDir.raffleCart);

      if (storedData != null) {
        List<CartItem> localCart = List<Map<String, dynamic>>.from(storedData)
            .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        cart.value = localCart;
      }
    } catch (e) {
      print('Failed to load cart from local storage: $e');
    }
  }

  String formatRemainingTime(DateTime drawDate) {
    final now = DateTime.now();
    final difference = drawDate.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void onEnd() {
    print('onEnd');
    notifyListeners();
  }

  Future<void> getProducts({bool isRefresh = false}) async {
    if (isLoadingMore && !isRefresh) return;
    if (isLastPage && !isRefresh) return;

    try {
      if (isRefresh) {
        productList.clear();
        currentPage = 1;
        isLastPage = false;
      }

      isLoadingMore = true;
      notifyListeners();

      final res = await repo.getProducts(
        page: currentPage,
        limit: pageLimit,
      );

      if (res.statusCode == 200) {
        final newProducts = (res.data["products"] as List)
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .where((product) => product.status?.toLowerCase() == 'active')
            .toList();

        final totalPages = res.data["pagination"]["totalPages"];

        final existingIds = productList.map((p) => p.id!).toSet();
        for (final newProduct in newProducts) {
          if (newProduct.id != null && !existingIds.contains(newProduct.id)) {
            productList.add(newProduct);
          }
        }

        final uniqueBrands = <String>{};
        for (final product in productList) {
          final b = product.brandName;
          if (b != null && b.isNotEmpty) uniqueBrands.add(b);
        }
        brands = uniqueBrands.toList()..sort();

        if (currentPage >= totalPages) {
          isLastPage = true;
        } else {
          currentPage++;
        }
        if (selectedBrand.isNotEmpty) {
          filteredProductList = productList
              .where((product) => product.brandName?.toLowerCase() == selectedBrand.toLowerCase())
              .toList();
        } else {
          filteredProductList = List.from(productList);
        }
        notifyListeners();

      } else {
        log.e("API Error: ${res.data["message"]}");
      }
    } catch (e) {
      log.e("Error fetching products: $e");
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  void filterProductsByBrand(String brand) {
    if (brand == "All" || brand.trim().isEmpty) {
      selectedBrand = '';
      filteredProductList = List.from(productList);
    } else {
      selectedBrand = brand;
      filteredProductList = productList
          .where((product) => product.brandName?.toLowerCase() == brand.toLowerCase())
          .toList();
    }
    notifyListeners();
  }


}
