import 'dart:convert';

import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.logger.dart';
import 'package:easyph/core/data/models/cart_item.dart';
import 'package:easyph/core/data/models/product.dart';
import 'package:easyph/core/data/models/raffle_cart_item.dart';
import 'package:easyph/core/data/repositories/repository.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:easyph/core/utils/local_store_dir.dart';
import 'package:easyph/core/utils/local_stotage.dart';
import 'package:easyph/state.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/data/models/category.dart';
import '../../../core/data/models/project.dart';
import '../../../core/data/models/tags.dart';

class DashboardViewModel extends BaseViewModel {
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
  bool get isTagFilterActive => _selectedTag != null;

  List<Tag> _tags = [];
  Tag? _selectedTag;
  bool _isLoadingTags = false;
  bool _hasTagsError = false;
  String? _tagsError;

  int currentPage = 1;
  bool isLastPage = false;
  bool isLoadingMore = false;
  final int pageLimit = 10;

  List<Tag> get tags => _tags;
  List<String> get productTags => _tags.map((tag) => tag.name).toList();
  Tag? get selectedTag => _selectedTag;
  String? get selectedTagName => _selectedTag?.name;
  bool get isLoadingTags => _isLoadingTags;
  bool get hasTagsError => _hasTagsError;
  String? get tagsError => _tagsError;


  final snackBar = locator<SnackbarService>();

  Set<String> loadingItems = {};

  void _applyFilters() {
    final seenProductIds = <String>{};
    final filtered = <Product>[];

    for (final product in productList) {
      // skip duplicates
      final pid = product.id;
      if (pid == null || seenProductIds.contains(pid)) continue;

      bool matches = true;

      // category filter
      if (selectedId != allCategoriesId) {
        matches = matches && (product.categoryId == selectedId);
      }

      // brand filter
      if (selectedBrand.isNotEmpty) {
        matches = matches && (product.brandName == selectedBrand);
      }

      // tag filter
      if (_selectedTag != null) {
        final hasTag = (product.tags ?? []).any((t) => t.id == _selectedTag!.id);
        matches = matches && hasTag;
      }

      if (matches) {
        filtered.add(product);
        seenProductIds.add(pid);
      }
    }

    filteredProductList = filtered;
    notifyListeners();
  }

  void resetFilters() {
    selectedId = allCategoriesId;
    selectedBrand = '';
    _selectedTag = null;

    // Remove duplicates from productList before applying to filtered list
    final seenIds = <String>{};
    final uniqueProducts = <Product>[];
    for (final product in productList) {
      if (product.id != null && !seenIds.contains(product.id)) {
        uniqueProducts.add(product);
        seenIds.add(product.id!);
      }
    }

    filteredProductList = uniqueProducts;

    // Build brands from the FULL catalog (not filtered)
    final uniqueBrands = <String>{};
    for (final product in productList) {
      final b = product.brandName;
      if (b != null && b.isNotEmpty) uniqueBrands.add(b);
    }
    brands = uniqueBrands.toList()..sort();

    notifyListeners();
  }

  void setSelectedCategory(int id) {
    _selectedTag = null;
    selectedId = id;
    _applyFilters();
  }

  void setSelectedBrand(String brand) {
    _selectedTag = null;
    selectedBrand = brand;
    _applyFilters();
  }

  void setSelectedTag(Tag? tag) {
    _selectedTag = tag;
    selectedId = allCategoriesId;
    selectedBrand = '';
    _applyFilters();
    final uniqueBrands = <String>{};
    for (final product in filteredProductList) {
      final b = product.brandName;
      if (b != null && b.isNotEmpty) uniqueBrands.add(b);
    }
    brands = uniqueBrands.toList()..sort();
    notifyListeners();
  }

  void clearAllFilters() {
    selectedId = allCategoriesId;
    selectedBrand = '';
    _selectedTag = null;
    _applyFilters();
  }

  Map<String, dynamic> getCurrentFilters() {
    return {
      'category': selectedId != allCategoriesId ? selectedId : null,
      'brand': selectedBrand.isNotEmpty ? selectedBrand : null,
      'tag': _selectedTag?.name,
      'hasFilters': selectedId != allCategoriesId || selectedBrand.isNotEmpty || _selectedTag != null,
    };
  }

  bool showcaseShown = false;
  void setShowcaseShown(bool value) {
    showcaseShown = value;
    notifyListeners();
  }

  bool isNewProduct(String createdAt) {
    final productDate = DateTime.parse(createdAt);
    final currentDate = DateTime.now();
    final difference = currentDate.difference(productDate).inDays;
    return difference <= 14;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> init() async {
    setBusy(true);
    notifyListeners();
    await loadProduct();
    await loadCategories();
    await fetchProductTags();
    if (userLoggedIn.value == true) {
      initCart();
    }
    setBusy(false);
    notifyListeners();
  }

  Future<void> loadProduct() async {

    try {
      dynamic storedJsonProduct = await locator<LocalStorage>().fetch(LocalStorageDir.product);

      if (storedJsonProduct != null && storedJsonProduct.isNotEmpty) {
        List<dynamic> storedProducts = jsonDecode(storedJsonProduct);
        List<Product> loadedProducts = storedProducts
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        // Remove duplicates from loaded products
        final seenIds = <String>{};
        productList = [];
        for (final product in loadedProducts) {
          if (product.id != null && !seenIds.contains(product.id)) {
            productList.add(product);
            seenIds.add(product.id!);
          }
        }

        filteredProductList = List.from(productList);

        // Build brands from FULL productList (stable)
        final uniqueBrands = <String>{};
        for (final product in productList) {
          final b = product.brandName;
          if (b != null && b.isNotEmpty) uniqueBrands.add(b);
        }
        brands = uniqueBrands.toList()..sort();

        rebuildUi();
      } else {
        print('no value to load');
      }

      getProducts();
    } catch (e) {
      log.e("Error loading products: $e");
    }
  }

  Future<void> refreshData() async {
    setBusy(true);
    notifyListeners();
    getResourceList();
    setBusy(false);
    notifyListeners();
  }

  void getResourceList() {
    getProducts(isRefresh: true);
    getCategories();
    fetchProductTags();

    if (userLoggedIn.value == true) {
      initCart();
    }
  }

  Future<void> getProducts({bool isRefresh = false}) async {
    // If a tag is selected, don't load more products via pagination
    if (_selectedTag != null && !isRefresh) {
      print('Tag is selected, skipping pagination load');
      return;
    }

    if (isLoadingMore && !isRefresh) return;
    if (isLastPage && !isRefresh) return;

    print('Getting products - Page $currentPage');
    try {
      if (isRefresh) {
        // Clear everything and reset pagination
        productList.clear();
        filteredProductList.clear();
        currentPage = 1;
        isLastPage = false;
        // Clear tag selection on refresh
        _selectedTag = null;
      }

      isLoadingMore = true;
      notifyListeners();

      ApiResponse res = await repo.getProducts(
        page: currentPage,
        limit: pageLimit,
      );

      if (res.statusCode == 200) {
        List<Product> newProducts = (res.data["products"] as List)
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .where((product) => product.status?.toLowerCase() == 'active')
            .toList();

        final totalPages = res.data["pagination"]["totalPages"];

        // Add new products, avoiding duplicates
        final existingIds = productList.map((p) => p.id!).toSet();
        for (final newProduct in newProducts) {
          if (newProduct.id != null && !existingIds.contains(newProduct.id)) {
            productList.add(newProduct);
          }
        }

        // Apply current filters to all products
        _applyCurrentFilters();

        // Rebuild brands from FULL productList (stable)
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

        // Save unique products to storage
        final seenIds = <String>{};
        final uniqueProducts = <Product>[];
        for (final product in productList) {
          if (product.id != null && !seenIds.contains(product.id)) {
            uniqueProducts.add(product);
            seenIds.add(product.id!);
          }
        }

        List<Map<String, dynamic>> storedProducts = uniqueProducts.map((e) => e.toJson()).toList();
        await locator<LocalStorage>().save(LocalStorageDir.product, jsonEncode(storedProducts));

        rebuildUi();
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

  void _applyCurrentFilters() {
    // Create a Set to track unique product IDs and prevent duplicates
    final seenProductIds = <String>{};
    final filtered = <Product>[];

    for (final product in productList) {
      // Skip if we've already seen this product ID
      if (product.id != null && seenProductIds.contains(product.id)) {
        continue;
      }

      bool matchesFilters = true;

      // Apply category filter
      if (selectedId != allCategoriesId) {
        matchesFilters = matchesFilters && (product.categoryId == selectedId);
      }

      // Apply brand filter
      if (selectedBrand.isNotEmpty) {
        matchesFilters = matchesFilters && (product.brandName == selectedBrand);
      }

      // Apply tag filter
      if (_selectedTag != null) {
        bool hasMatchingTag = false;
        if (product.tags != null && product.tags!.isNotEmpty) {
          hasMatchingTag = product.tags!.any((tag) => tag.id == _selectedTag!.id);
        }
        matchesFilters = matchesFilters && hasMatchingTag;
      }

      // Add to filtered list if it matches all filters and hasn't been seen
      if (matchesFilters) {
        filtered.add(product);
        if (product.id != null) {
          seenProductIds.add(product.id!);
        }
      }
    }

    filteredProductList = filtered;
  }

  Future<void> loadCategories() async {
    try {
      await getCategories();
      if (categories.isEmpty) {
        dynamic storedDonations = await locator<LocalStorage>()
            .fetch(LocalStorageDir.donationsCategories);
        if (storedDonations != null) {
          categories = List<Map<String, dynamic>>.from(storedDonations)
              .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
              .where((category) => category.status == CategoryStatus.active)
              .toList();
        }
      }
      filteredCategories = [
        Category(id: 0, name: 'All', status: CategoryStatus.active),
        ...categories,
      ];
      notifyListeners();
    } catch (e) {
      log.e("Error loading categories: $e");
    }
  }

  Future<void> getCategories() async {
    setBusy(true);
    try {
      ApiResponse res = await repo.getCategories();
      if (res.statusCode == 200 && res.data != null && res.data["categories"] != null) {
        categories = (res.data["categories"] as List)
            .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
            .where((category) => category.status == CategoryStatus.active)
            .toList();
        List<Map<String, dynamic>> storedCategories =
        categories.map((e) => e.toJson()).toList();
        // await locator<LocalStorage>()
        //     .save(LocalStorageDir.donationsCategories, storedCategories);

        // Update filtered list
        filteredCategories = [
          Category(id: 0, name: 'All', status: CategoryStatus.active),
          ...categories,
        ];
      }
    } catch (e) {
      log.e("Error fetching categories: $e");
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> fetchProductTags() async {
    _isLoadingTags = true;
    _hasTagsError = false;
    _tagsError = null;
    notifyListeners();
    try {
      ApiResponse res = await repo.getProductTags();
      if (res.statusCode == 200) {
        List<dynamic> tagsData = res.data['tags'] ?? [];
        _tags = tagsData
            .map((tagJson) => Tag.fromJson(Map<String, dynamic>.from(tagJson)))
            .toList();
        _tags.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _hasTagsError = false;
        _tagsError = null;
        print("Loaded ${_tags.length} tags: ${_tags.map((t) => '${t.name} (${t.id})').toList()}");
      } else {
        throw Exception('Failed to fetch tags with status: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching product tags: $e');
      _hasTagsError = true;
      _tagsError = 'Failed to load tags. Please try again.';
      _tags = [];
      locator<SnackbarService>().showSnackbar(
          message: "Failed to load product tags",
          duration: const Duration(seconds: 2)
      );
    } finally {
      _isLoadingTags = false;
      notifyListeners();
    }
  }

  Future<void> refreshTags() async {
    await fetchProductTags();
  }

  void addToRaffleCart(Product product) async {
    print('adding to cart');

    loadingItems.add(product.id!);
    notifyListeners();

    try {
      final existingIndex = cart.value.indexWhere(
            (raffleItem) => raffleItem.product?.id == product.id,
      );

      if (existingIndex != -1) {
         CartItem(
          product: cart.value[existingIndex].product,
          quantity: cart.value[existingIndex].quantity! + 1,
        );
      } else {
        cart.value.add(CartItem(product: product, quantity: 1));
      }

      List<Map<String, dynamic>> storedList =
      cart.value.map((e) => e.toJson()).toList();
      // await locator<LocalStorage>().save(LocalStorageDir.raffleCart, storedList);

      final response = await repo.addToCart({
        "productId": product.id,
        "quantity": cart.value.firstWhere((item) => item.product?.id == product.id).quantity,
      });

      if (response.statusCode == 200) {
        locator<SnackbarService>().showSnackbar(
            message: "Product added to cart", duration: const Duration(seconds: 2));
      } else {
        locator<SnackbarService>().showSnackbar(
            message: response.data["message"], duration: const Duration(seconds: 2));
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
          message: "Failed to add product to cart: $e",
          duration: const Duration(seconds: 2));
    } finally {
      // Remove product ID from loading set
      loadingItems.remove(product.id!);
      notifyListeners();
    }
  }

  void initCart() async {
    try {
      dynamic storedData = await locator<LocalStorage>().fetch(LocalStorageDir.raffleCart);

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

  Future<void> decreaseRaffleQuantity(RaffleCartItem item) async {
    setBusy(true);
    try {
      if (item.quantity! > 1) {
        item.quantity = item.quantity! - 1;

        await repo.addToCart({
          "raffle": item.raffle?.id,
          "quantity": item.quantity,
        });
      } else if (item.quantity! == 1) {
        cart.value.removeWhere((cartItem) => cartItem.product?.id == item.raffle?.id);

        await repo.deleteFromCart(item.raffle!.id!);
      }

      // Save to local storage
      // List<Map<String, dynamic>> storedList =
      //     cart.value.map((e) => e.toJson()).toList();
      // await locator<LocalStorage>()
      //     .save(LocalStorageDir.raffleCart, storedList);
    } catch (e) {
      locator<SnackbarService>().showSnackbar(message: "Failed to decrease product quantity: $e", duration: const Duration(seconds: 2));
      log.e(e);
    } finally {
      setBusy(false);
      cart.notifyListeners();
    }
  }

  Future<void> increaseRaffleQuantity(CartItem item) async {
    setBusy(true);
    try {
      item.quantity = item.quantity! + 1;
      int index = cart.value.indexWhere((raffleItem) => raffleItem.product?.id == item.product?.id);
      if (index != -1) {
        cart.value[index] = item;
        cart.value = List.from(cart.value);

        await repo.addToCart({
          "productId": item.product?.id,
          "quantity": item.quantity,
        });

        // Save to local storage
        // List<Map<String, dynamic>> storedList =
        //     cart.value.map((e) => e.toJson()).toList();
        // await locator<LocalStorage>()
        //     .save(LocalStorageDir.raffleCart, storedList);
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(message: "Failed to increase product quantity: $e", duration: const Duration(seconds: 2));
      log.e(e);
    } finally {
      setBusy(false);
      cart.notifyListeners();
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
}
