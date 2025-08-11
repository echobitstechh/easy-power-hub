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

class ShopViewModel extends BaseViewModel {
  final repo = locator<Repository>();
  int selectedIndex = 0;
  final log = getLogger("DashboardViewModel");
  List<Raffle> raffleList = [];
  List<Project> projects = [];
  List<Ads> adsList = [];
  List<ProjectResource> projectResources = [];
  List<Raffle> featuredRaffle = [];
  List<Product> productList = [];
  List<Product> filteredProductList = [];
  List<Category> filteredCategories = [];
  List<Category> categories = [];
  List<String> _brandsForSelectedTag = [];  // new by yehhmii
  
  static const int allCategoriesId = 0;

  int selectedId = allCategoriesId;
  String selectedBrand = '';

  bool? onboarded;

  bool showDialog = true;
  bool modalShown = false;
  bool appBarLoading = false;
  bool shouldShowShowcase = true;
  bool _showingTagBrands = false;   // new by yehhmii

  List<Tag> _tags = [];
  Tag? _selectedTag;
  bool _isLoadingTags = false;
  bool _hasTagsError = false;
  String? _tagsError;

  // Pagination variables
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
  List<String> get brandsForSelectedTag => _brandsForSelectedTag; // new by yehhmii
  bool get showingTagBrands => _showingTagBrands; // new by yehhmii

  final snackBar = locator<SnackbarService>();

  @override
  void initialise() {
    init();
  }

  void _applyFilters() {
    List<Product> filtered = List.from(productList);

    // Apply category filter
    if (selectedId != allCategoriesId) {
      filtered = filtered.where((p) => p.categoryId == selectedId).toList();
      print('After category filter: ${filtered.length}');
    }

    // Apply brand filter
    if (selectedBrand.isNotEmpty) {
      filtered = filtered.where((p) => p.brandName == selectedBrand).toList();
      print('After brand filter: ${filtered.length}');
    }
    if (_selectedTag != null) {
      filtered = filtered.where((product) {
        if (product.tags != null && product.tags!.isNotEmpty) {
          return product.tags!.any((tag) => tag.id == _selectedTag!.id);
        }

        return false;
      }).toList();
      print('After tag filter: ${filtered.length}');
    }

    filteredProductList = filtered;
    print('Final filtered count: ${filteredProductList.length}');
    notifyListeners();
  }

  void resetFilters() {
    selectedId = allCategoriesId;
    selectedBrand = '';
    _selectedTag = null;
    filteredProductList = List.from(productList);
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

  if (tag != null) {   // this if by yehhmii
    _brandsForSelectedTag = _getBrandsForTag(tag);
    _showingTagBrands = true;
    selectedId = allCategoriesId;
    selectedBrand = '';
  } else {
    _brandsForSelectedTag = [];
    _showingTagBrands = false;
  }

    _applyFilters();
  }

  void setSelectedTagBrand(String brand) {  // new by yehhmii
    selectedBrand = brand;
    _applyFilters();
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

  void changeSelected(int i) {
    selectedIndex = i;
    rebuildUi();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> init() async {
    setBusy(true);
    print("loading the initials" );
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
    print('loading products....');
    try {
      dynamic storedJsonProduct = await locator<LocalStorage>().fetch(LocalStorageDir.product);
      log.i("Loaded jsonProducts from storage: $storedJsonProduct");

      if ( storedJsonProduct != null && storedJsonProduct.isNotEmpty) {
        List<dynamic> storedProducts = jsonDecode(storedJsonProduct);
        productList = storedProducts
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        filteredProductList = productList;
        print('loaded products from local storage list ${productList.length}');
        rebuildUi();
      }else{
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

  void getResourceList(){
    getProducts(isRefresh: true);
    getCategories();
    fetchProductTags();

    if (userLoggedIn.value == true) {
      initCart();
    }
  }

  Future<void> getProducts({bool isRefresh = false}) async {
    if (isLoadingMore && !isRefresh) return;
    if (isLastPage && !isRefresh) return;

    print('Getting products - Page $currentPage');
    try {
      if (isRefresh) {
        productList.clear();
        filteredProductList.clear();
        currentPage = 1;
        isLastPage = false;
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

        productList.addAll(newProducts);

        // Apply current filters to new products
        _applyCurrentFilters();

        if (currentPage >= totalPages) {
          isLastPage = true;
        } else {
          currentPage++;
        }
        List<Map<String, dynamic>> storedProducts =
        productList.map((e) => e.toJson()).toList();
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
    List<Product> filtered = productList;

    if (selectedId != allCategoriesId) {
      filtered = filtered.where((product) => product.categoryId == selectedId).toList();
    }

    if (selectedBrand.isNotEmpty) {
      filtered = filtered.where((product) => product.brandName == selectedBrand).toList();
    }

    if (_selectedTag != null) {
      filtered = filtered.where((product) {
        if (product.tags != null && product.tags!.isNotEmpty) {
          return product.tags!.any((tag) => tag.id == _selectedTag!.id);
        }
        return false;
      }).toList();
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
              .where((category) => category.status == CategoryStatus.active) // Filter out inactive
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
            .where((category) => category.status == CategoryStatus.active) // Filter out inactive
            .toList();
        List<Map<String, dynamic>> storedCategories =
        categories.map((e) => e.toJson()).toList();
        await locator<LocalStorage>()
            .save(LocalStorageDir.donationsCategories, storedCategories);
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

  // new by yehhmii
  List<String> _getBrandsForTag(Tag tag) {
    // Get products that have this tag
    final productsWithTag = productList.where((product) {
      if (product.tags != null && product.tags!.isNotEmpty) {
        return product.tags!.any((productTag) => productTag.id == tag.id);
      }
      return false;
    }).toList();
    
    // Extract unique brand names
    final brands = productsWithTag
        .map((product) => product.brandName ?? "")
        .where((brand) => brand.isNotEmpty)
        .toSet()
        .toList();
    
    brands.sort(); // Sort alphabetically
    return brands;
  }

  void addToRaffleCart(Product product) async {
    print('adding to cart');
    try {
      final existingIndex = cart.value.indexWhere(
            (raffleItem) => raffleItem.product?.id == product.id,
      );

      if (existingIndex != -1) {
        final updatedItem = CartItem(
          product: cart.value[existingIndex].product,
          quantity: cart.value[existingIndex].quantity! + 1,
        );

        cart.value[existingIndex] = updatedItem;
      } else {
        cart.value.add(CartItem(product: product, quantity: 1));
      }

      List<Map<String, dynamic>> storedList =
      cart.value.map((e) => e.toJson()).toList();
      await locator<LocalStorage>().save(LocalStorageDir.raffleCart, storedList);

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
          message: "Failed to add raffle to cart: $e",
          duration: const Duration(seconds: 2));
    } finally {
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

      List<Map<String, dynamic>> storedList = cart.value.map((e) => e.toJson()).toList();
      await locator<LocalStorage>().save(LocalStorageDir.raffleCart, storedList);
    } catch (e) {
      locator<SnackbarService>().showSnackbar(message: "Failed to decrease raffle quantity: $e", duration: const Duration(seconds: 2));
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

        // Update online cart
        await repo.addToCart({
          "raffle": item.product?.id,
          "quantity": item.quantity,
        });

        // Save to local storage
        List<Map<String, dynamic>> storedList = cart.value.map((e) => e.toJson()).toList();
        await locator<LocalStorage>().save(LocalStorageDir.raffleCart, storedList);
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(message: "Failed to increase raffle quantity: $e", duration: const Duration(seconds: 2));
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