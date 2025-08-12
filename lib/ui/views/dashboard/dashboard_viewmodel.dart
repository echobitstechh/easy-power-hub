import 'dart:convert';
import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.logger.dart';
import 'package:easyph/core/data/models/product.dart';
import 'package:easyph/core/data/repositories/repository.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:easyph/core/utils/local_store_dir.dart';
import 'package:easyph/core/utils/local_stotage.dart';
import 'package:easyph/state.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../core/data/models/cart_item.dart';
import '../../../core/data/models/category.dart';
import '../../../core/network/interceptors.dart';
import '../../../core/data/models/tags.dart';

class DashboardViewModel extends BaseViewModel {
  final repo = locator<Repository>();
  int selectedIndex = 0;
  final log = getLogger("DashboardViewModel");
  List<Ads> adsList = [];
  List<Product> productList = [];
  List<Product> filteredProductList = [];
  List<Category> filteredCategories = [];
  List<String> brands = [];
  List<Category> filteredCategoriesList = [];
  List<Category> categories = [];
  double discountAmount = 0.0;
  bool freeDelivery = false;
  Set<String> loadingItems = {};
  

  // properties for tags
  List<Tag> _tags = [];
  Tag? _selectedTag;
  bool _isLoadingTags = false;
  bool _hasTagsError = false;
  String? _tagsError;

  //  getters for tags
  List<Tag> get tags => _tags;
  Tag? get selectedTag => _selectedTag;
  bool get isLoadingTags => _isLoadingTags;
  bool get hasTagsError => _hasTagsError;
  String? get tagsError => _tagsError;

  static const int allCategoriesId = 0;

  int selectedId = allCategoriesId;
  String selectedBrand = '';

  bool? onboarded;

  bool appBarLoading = false;
  final snackBar = locator<SnackbarService>();

  int currentPage = 1;
  bool isLastPage = false;
  bool isLoadingMore = false;
  final int pageLimit = 10;

  void setSelectedCategory(int id) {
    selectedId = id;
    selectedBrand = '';

    _applyCurrentFilters();

    if (id == allCategoriesId) {
      filteredProductList = productList;
    } else {
      print('id is: $id');
      filteredProductList = productList.where((product) {
        return product.categoryId == id;
      }).toList();
    }

    computeBrandsForCurrentState();

    notifyListeners();
  }

  void setSelectedBrand(String brand) {
    selectedBrand = brand;
    _applyCurrentFilters(); 
    List<Product> categoryFiltered;
    if (selectedId == allCategoriesId) {
      categoryFiltered = productList;
    } else {
      categoryFiltered = productList.where((product) {
        return product.categoryId == selectedId;
      }).toList();
    }

    if (brand.isEmpty) {
      filteredProductList = categoryFiltered;
    } else {
      filteredProductList = categoryFiltered.where((product) {
        return product.brandName == brand;
      }).toList();
    }

    notifyListeners();
  }

  void changeSelected(int i) {
    selectedIndex = i;
    rebuildUi();
  }

  // @override
  // void dispose() {
  //   // controller.dispose();
  //   super.dispose();
  // }


  void initialise() {
    print('called initialize');
    init();
  }

  Future<void> init() async {
    setBusy(true);
    notifyListeners();
    await loadProduct();
    await loadCategories();
    await fetchProductTags();
    rebuildUi();

    if (userLoggedIn.value == true) {
      initCart();
    }
    setBusy(false);
    notifyListeners();
  }

  bool isNewProduct(String createdAt) {
    final productDate = DateTime.parse(createdAt);
    final currentDate = DateTime.now();
    final difference = currentDate.difference(productDate).inDays;
    return difference <= 14;
  }

List<Product> _uniqueById(List<Product> products) {
  final Map<String, Product> map = {};
  for (final p in products) {
    final key = (p.id ?? '').toString();
    if (key.isEmpty) continue;
    // keep last occurrence so newProducts can override older items
    map[key] = p;
  }
  return map.values.toList();
}

  Future<void> loadProduct() async {
    print('loading products....');
    try {

      dynamic storedJsonProduct = await locator<LocalStorage>().fetch(LocalStorageDir.product);
      log.i("Loaded jsonProducts from storage: $storedJsonProduct");


      if (storedJsonProduct != null && storedJsonProduct.isNotEmpty) {
        List<dynamic> storedProducts = jsonDecode(storedJsonProduct);
        final loaded = storedProducts
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        // Ensure uniqueness (in case local json itself had duplicates)
        productList = _uniqueById(loaded);

        // set filtered and brands and compute other state
        filteredProductList = productList;
        computeBrandsForCurrentState();

        print('loaded products from local storage list ${productList.length}');
        
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

  void getResourceList() {
    getProducts();
    getCategories();

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

        final combined = <Product>[];
        combined.addAll(productList);
        combined.addAll(newProducts);
        productList = _uniqueById(combined);

        // Apply current filters to new products
        _applyCurrentFilters();

        computeBrandsForCurrentState();

        if (currentPage >= totalPages) {
          isLastPage = true;
        } else {
          currentPage++;
        }

        // Save current loaded pages to local storage
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
    List<Product> filtered = List.from(productList);

    // Apply category filter
    if (selectedId != allCategoriesId) {
      filtered = filtered.where((product) => product.categoryId == selectedId).toList();
      print('After category filter: ${filtered.length}');
    }

    // Apply brand filter
    if (selectedBrand.isNotEmpty) {
      filtered = filtered.where((product) => product.brandName == selectedBrand).toList();
      print('After brand filter: ${filtered.length}');
    }

    // Apply tag filter
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
  }

void computeBrandsForCurrentState() {
  // Start from full product list (we'll respect category and tag)
  Iterable<Product> scope = productList;

  // apply category scope
  if (selectedId != allCategoriesId) {
    scope = scope.where((p) => p.categoryId == selectedId);
  }

  // if a tag is selected, filter scope to products that contain the tag
  if (_selectedTag != null) {
    final tagId = _selectedTag!.id;
    scope = scope.where((p) {
      final tags = p.tags;
      if (tags == null || tags.isEmpty) return false;

      try {
        // Ensure we have a runtime List<dynamic> so analyzer doesn't assume an inner type
        final List<dynamic> items = List<dynamic>.from(tags);

        for (final dynamic tt in items) {
          // check common shapes defensively
          if (tt is Tag) {
            if (tt.id == tagId) return true;
          } else if (tt is Map) {
            final dynamic id = tt['id'];
            if (id != null && id == tagId) return true;
          } else if (tt is int) {
            if (tt == tagId) return true;
          } else if (tt is String) {
            if (tt == tagId.toString()) return true;
          }
        }
      } catch (_) {
        // If anything goes wrong (unexpected shape), don't include the product
        return false;
      }

      return false;
    });
  }

  // Map brands from remaining scope
  brands = scope.map((p) => p.brandName ?? '').toSet().toList();
  brands.removeWhere((b) => b.isEmpty);
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
    print('Error fetching product tags: $e');
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

void setSelectedTag(Tag? tag) {
  // toggle: tapping same tag again clears filter
  if (_selectedTag != null && tag != null && _selectedTag!.id == tag.id) {
    clearTagFilter();
    return;
  }

  _selectedTag = tag;
  selectedBrand = ''; // clear brand whenever tag changes

  // recompute brands according to the new tag/category state
  computeBrandsForCurrentState();

  // reuse unified filters so product list updates consistently
  _applyCurrentFilters();
  notifyListeners();
}

void clearTagFilter() {
  _selectedTag = null;
  selectedBrand = '';

  // recompute brands back to category/all-products
  computeBrandsForCurrentState();

  _applyCurrentFilters();
  notifyListeners();
}

// Add method to clear all filters (including tags)
void clearAllFilters() {
  selectedId = allCategoriesId;
  selectedBrand = '';
  _selectedTag = null;
  _applyCurrentFilters();
  notifyListeners();
}

// Add method to get current filter state
Map<String, dynamic> getCurrentFilters() {
  return {
    'category': selectedId != allCategoriesId ? selectedId : null,
    'brand': selectedBrand.isNotEmpty ? selectedBrand : null,
    'tag': _selectedTag?.name,
    'hasFilters': selectedId != allCategoriesId || 
                 selectedBrand.isNotEmpty || 
                 _selectedTag != null,
  };
}

Future<void> refreshTags() async {
  await fetchProductTags();
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

          globalCategories.value = categories;
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
        // Update categories list with only active ones
        categories = (res.data["categories"] as List)
            .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
            .where((category) => category.status == CategoryStatus.active) // Filter out inactive
            .toList();

        List<Map<String, dynamic>> storedCategories =
        categories.map((e) => e.toJson()).toList();
        await locator<LocalStorage>()
            .save(LocalStorageDir.donationsCategories, storedCategories);

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

  void addToRaffleCart(Product product) async {
    loadingItems.add(product.id!);
    notifyListeners();
    try {
      final existingIndex = cart.value.indexWhere(
            (raffleItem) => raffleItem.product?.id == product.id,
      );

      if (existingIndex != -1) {
        cart.value[existingIndex] = CartItem(
          product: cart.value[existingIndex].product,
          quantity: cart.value[existingIndex].quantity! + 1,
        );
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

      // **Calculate Discount & Free Delivery**
      final brandCount = <String, int>{};
      double eligibleProductTotal = 0.0;

      for (var item in cart.value) {
        if (["Hisense", "LG", "Maxi"].contains(item.product?.brandName)) {
          brandCount[item.product!.brandName!] = (brandCount[item.product!.brandName!] ?? 0) + item.quantity!;
          eligibleProductTotal += (double.tryParse(item.product?.salePrice ?? '0.0') ?? 0.0) * item.quantity!;
        }
      }

      freeDelivery = brandCount.values.any((count) => count >= 5);
      bool applyDiscount = brandCount.values.any((count) => count >= 3);

      discountAmount = applyDiscount ? eligibleProductTotal * 0.02 : 0.0;

      updateCartSummary();
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
          message: "Failed to add raffle to cart: $e",
          duration: const Duration(seconds: 2));
    } finally {
      loadingItems.remove(product.id);
      notifyListeners();
      cart.notifyListeners();
    }
  }

  void updateCartSummary() {
    double totalPrice = cart.value
        .map((item) => (double.tryParse(item.product?.salePrice ?? '0.0') ?? 0.0) * item.quantity!)
        .reduce((a, b) => a + b);

    totalPrice -= discountAmount; // Apply 2% discount correctly

    notifyListeners();

    print("Updated Cart Summary:");
    print("Total Price: \$${totalPrice.toStringAsFixed(2)}");
    print("Discount Applied: \$${discountAmount.toStringAsFixed(2)}");
    print("Free Delivery: $freeDelivery");
  }

  void onEnd() {
    print('onEnd');
    //TODO SEND USER NOTIFICATION OF AVAILABILITY OF PRODUCT
    notifyListeners();
  }
}

  void initCart() async {
    try {
      // Fetch stored data from local storage
      dynamic storedData = await locator<LocalStorage>().fetch(LocalStorageDir.raffleCart);

      if (storedData != null) {
        // Parse the stored JSON data into a list of CartItem
        List<CartItem> localCart = List<Map<String, dynamic>>.from(storedData)
            .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        // Update the cart with the retrieved items
        cart.value = localCart;
      }
    } catch (e) {
      // Handle any errors that might occur during fetching or parsing
      print('Failed to load cart from local storage: $e');
    }
  }


  Future<void> decreaseRaffleQuantity(CartItem item) async {
    try {
      if (item.quantity! > 1) {
        item.quantity = item.quantity! - 1;

        // Update online cart
        await repo.addToCart({
          "productId": item.product?.id,
          "quantity": item.quantity,
        });
      } else if (item.quantity! == 1) {
        // Remove from local cart
        cart.value
            .removeWhere((cartItem) => cartItem.product?.id == item.product?.id);

        // Remove from online cart
        await repo.deleteFromCart(item.product!.id!);
      }

      // Save to local storage
      List<Map<String, dynamic>> storedList =
          cart.value.map((e) => e.toJson()).toList();
      await locator<LocalStorage>()
          .save(LocalStorageDir.raffleCart, storedList);
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
          message: "Failed to decrease raffle quantity: $e",
          duration: const Duration(seconds: 2));
      print(e);
    }
  }

  Future<void> increaseRaffleQuantity(CartItem item) async {
    try {
      item.quantity = item.quantity! + 1;
      int index = cart.value
          .indexWhere((raffleItem) => raffleItem.product?.id == item.product?.id);
      if (index != -1) {
        cart.value[index] = item;
        cart.value = List.from(cart.value);

        // Update online cart
        await repo.addToCart({
          "productId": item.product?.id,
          "quantity": item.quantity,
        });

        // Save to local storage
        List<Map<String, dynamic>> storedList =
            cart.value.map((e) => e.toJson()).toList();
        await locator<LocalStorage>()
            .save(LocalStorageDir.raffleCart, storedList);
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
          message: "Failed to increase raffle quantity: $e",
          duration: const Duration(seconds: 2));
    } finally {
      cart.notifyListeners();
    }
  }

  String formatRemainingTime(DateTime drawDate) {
    final now = DateTime.now();
    final difference = drawDate.difference(now);
    // Format the Duration to your needs
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

