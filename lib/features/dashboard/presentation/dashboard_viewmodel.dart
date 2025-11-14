import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../core/data/models/cart_item.dart';
import '../../../core/data/models/category.dart';
import '../../../core/data/models/favourite.dart';
import '../../../core/data/models/product.dart';
import '../../../core/data/models/tags.dart';
import '../../../core/data/repositories/repository.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../core/services/remote_config_service.dart';
import '../../../core/services/update_service.dart';
import '../../../state.dart';

class DashboardViewModel extends BaseViewModel {
  final _repo = locator<Repository>();
  final _log = getLogger("DashboardViewModel");
  final _snackBar = locator<SnackbarService>();
  final _localStorage = locator<LocalStorage>();
  final _remoteConfig = locator<RemoteConfigService>();
  final _updateService = locator<UpdateService>();

  List<Product> productList = [];
  List<String> brands = [];
  List<Product> filteredProductList = [];
  List<Category> categories = [];
  List<Category> filteredCategories = [];
  List<FavoriteItem> _favorites = [];
  List<FavoriteItem> get favorites => _favorites;
  List<Product> searchResults = [];
  bool isSearching = false;

  bool isLoadingSearch = false;
  String searchQuery = '';

  bool _isLoadingCategories = false;
  bool _isLoadingProducts = false;
  bool _isLoadingAds = false;

  bool isProductFavorite(String productId) {
    return _favorites.any((f) => f.product.id == productId);
  }



  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingAds => _isLoadingAds;

  Set<String> loadingItems = {};
  static const int allCategoriesId = 0;

  // The state variables for filters
  String _selectedBrand = '';
  String get selectedBrand => _selectedBrand;
  Tag? _selectedTag;
  Tag? get selectedTag => _selectedTag;
  int _selectedCategoryId = allCategoriesId; // New state variable
  int get selectedCategoryId => _selectedCategoryId;

  int currentPage = 1;
  bool isLastPage = false;
  final int pageLimit = 10;

  List<Tag> _tags = [];
  List<Tag> get tags => _tags;
  bool _isLoadingTags = false;
  bool get isLoadingTags => _isLoadingTags;
  bool _hasTagsError = false;
  bool get hasTagsError => _hasTagsError;
  String? _tagsError;
  String? get tagsError => _tagsError;

  bool isNewProduct(String createdAt) {
    try {
      final productDate = DateTime.parse(createdAt);
      final currentDate = DateTime.now();
      final difference = currentDate.difference(productDate).inDays;
      return difference <= 14;
    } catch (e) {
      _log.e("Error parsing product creation date: $e");
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> init() async {
    // await runBusyFuture(_loadData());
    _loadData();
    if (userLoggedIn.value == true) {
      initCart();
      fetchFavorites();
    }
    await _checkForUpdateOncePerDay();
  }

  Future<void> _loadData() async {
    // await Future.wait([
      getProducts(isRefresh: true);
      getCategories();
      fetchProductTags();
    // ]);
  }

  void initCart() async {
    try {
      final storedData = await _localStorage.fetch(LocalStorageDir.productCart);
      if (storedData != null) {
        final localCart = (storedData as List)
            .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        cart.value = localCart;
      }
    } catch (e) {
      _log.e('Failed to load cart from local storage: $e');
    }
  }

  void onEnd() {
    _log.i('Countdown timer ended.');
    notifyListeners();
  }

  Future<void> getProducts({bool isRefresh = false}) async {
    if (isLastPage && !isRefresh) return;
    if (_isLoadingMore) return;

    if (isRefresh) {
      productList.clear();
      currentPage = 1;
      isLastPage = false;
      _isLoadingProducts = true;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final res = await _repo.getProducts(
        page: currentPage,
        limit: pageLimit,
        tag: _selectedTag?.name,
        brand: _selectedBrand.isNotEmpty ? _selectedBrand : null,
        categoryId: _selectedCategoryId != allCategoriesId
            ? _selectedCategoryId.toString()
            : null,
      );

      if (res.statusCode == 200) {
        final newProducts = (res.data["products"] as List)
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .where((product) => product.status?.toLowerCase() == 'active')
            .toList();

        if (newProducts.isEmpty && isRefresh) {

          _snackBar.showSnackbar(
              message: "No products found for the selected filter.",
              duration: const Duration(seconds: 3));
          await resetFilters();
          return;
        }


        final existingIds = productList.map((p) => p.id!).toSet();
        for (final newProduct in newProducts) {
          if (newProduct.id != null && !existingIds.contains(newProduct.id)) {
            productList.add(newProduct);
          }
        }

        productList.sort((a, b) {
          final aAvailable = (a.availability ?? 0) >= 1;
          final bAvailable = (b.availability ?? 0) >= 1;

          if (aAvailable && !bAvailable) return -1;
          if (!aAvailable && bAvailable) return 1;
          return 0; // Maintain original order if availability is the same
        });

        if (isRefresh) {
          brands = (res.data["brands"] as List).map((b) => b.toString()).toList();
        }
        filteredProductList = List.from(productList);

        if (newProducts.length < pageLimit) {
          isLastPage = true;
        } else {
          currentPage++;
        }
      } else {
        _log.e("API Error: ${res.data["message"]}");
        _snackBar.showSnackbar(
            message: res.data["message"] ?? "Failed to fetch products.",
            duration: Duration(seconds: 3));
      }
    } catch (e) {
      _log.e("Error fetching products: $e");
      _snackBar.showSnackbar(
          message: "An error occurred while fetching products.",
          duration: Duration(seconds: 3));
    } finally {
      _isLoadingMore = false;
      _isLoadingProducts = false;
      notifyListeners();
      // setBusy(false);
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final res = await _repo.searchProducts(query: query);

      if (res.statusCode == 200 && res.data != null) {
        final products = (res.data["products"] as List)
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .where((product) => product.status?.toLowerCase() == 'active')
            .toList();

        products.sort((a, b) {
          final aAvailable = (a.availability ?? 0) >= 1;
          final bAvailable = (b.availability ?? 0) >= 1;
          if (aAvailable && !bAvailable) return -1;
          if (!aAvailable && bAvailable) return 1;
          return 0;
        });

        return products;
      } else {
        _log.e("Search API Error: ${res.data?["message"] ?? 'Unknown error'}");
        return [];
      }
    } catch (e) {
      _log.e("Error searching products: $e");
      return [];
    }
  }

  Future<void> performSearch(String query) async {
    searchQuery = query.trim();

    if (searchQuery.isEmpty) {
      searchResults = [];
      isSearching = false;
      isLoadingSearch = false;
      notifyListeners();
      return;
    }

    isSearching = true;
    isLoadingSearch = true;
    notifyListeners();

    try {
      final res = await _repo.searchProducts(query: searchQuery);

      if (res.statusCode == 200 && res.data != null) {
        searchResults = (res.data["products"] as List)
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .where((product) => product.status?.toLowerCase() == 'active')
            .toList();

        // Sort by availability (in stock first)
        searchResults.sort((a, b) {
          final aAvailable = (a.availability ?? 0) >= 1;
          final bAvailable = (b.availability ?? 0) >= 1;
          if (aAvailable && !bAvailable) return -1;
          if (!aAvailable && bAvailable) return 1;
          return 0;
        });
      } else {
        _log.e("Search API Error: ${res.data?["message"] ?? 'Unknown error'}");
        searchResults = [];
      }
    } catch (e) {
      _log.e("Error searching products: $e");
      searchResults = [];
      _snackBar.showSnackbar(
        message: "Search failed. Please try again.",
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoadingSearch = false;
      notifyListeners();
    }
  }

  // Clear search
  void clearSearch() {
    searchQuery = '';
    searchResults = [];
    isSearching = false;
    isLoadingSearch = false;
    notifyListeners();
  }
  
  void setSelectedTag(Tag? tag) {
    _selectedTag = tag;
    _selectedBrand = '';
    _selectedCategoryId = allCategoriesId;
    getProducts(isRefresh: true);
  }

  void setSelectedCategory(int categoryId) {
    _selectedCategoryId = categoryId;
    _selectedTag = null;
    _selectedBrand = '';
    getProducts(isRefresh: true);
    fetchProductTags(categoryId: categoryId);
  }

  void filterProductsByBrand(String brand) {
    _selectedBrand = brand.toLowerCase() == "all" ? '' : brand;
    getProducts(isRefresh: true);
  }

  Future<void> resetFilters() async {
    _selectedTag = null;
    _selectedBrand = '';
    _selectedCategoryId = allCategoriesId;
    getProducts(isRefresh: true);
    print('tried to reset filters');
  }

  Future<void> getCategories() async {
    _isLoadingCategories = true;
    notifyListeners();
    try {
      final res = await _repo.getCategories();
      if (res.statusCode == 200 &&
          res.data != null &&
          res.data["categories"] != null) {
        categories = (res.data["categories"] as List)
            .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
            .where((category) => category.status == CategoryStatus.active)
            .toList();
        await _localStorage.save(LocalStorageDir.category,
            categories.map((e) => e.toJson()).toList());
        filteredCategories = [
          Category(id: 0, name: 'All', status: CategoryStatus.active),
          ...categories,
        ];
      }
    } catch (e) {
      _log.e("Error fetching categories: $e");
      _snackBar.showSnackbar(
          message: "An error occurred while fetching categories.",
          duration: Duration(seconds: 3));
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductTags({int? categoryId}) async {
    _isLoadingTags = true;
    _hasTagsError = false;
    _tagsError = null;
    notifyListeners();
    try {
      final res = await _repo.getProductTags(categoryId: categoryId);
      if (res.statusCode == 200) {
        final List<dynamic> tagsData = res.data['tags'] ?? [];
        _tags = tagsData
            .map((tagJson) => Tag.fromJson(Map<String, dynamic>.from(tagJson)))
            .toList();
        _tags.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _log.i("Loaded ${_tags.length} tags.");
      } else {
        _log.e("API Error fetching tags: ${res.data['message']}");
        _tagsError = res.data['message'] ?? 'Failed to load tags.';
        _hasTagsError = true;
      }
    } catch (e) {
      _log.e('Error fetching product tags: $e');
      _tagsError = 'Network error. Please try again.';
      _hasTagsError = true;
    } finally {
      _isLoadingTags = false;
      setBusy(false);
      notifyListeners();
    }
  }

  void addProductToCart(Product product) async {
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
        cart.notifyListeners();
      }

      List<Map<String, dynamic>> storedList =
          cart.value.map((e) => e.toJson()).toList();
      // await locator<LocalStorage>().save(LocalStorageDir.raffleCart, storedList);

      final response = await _repo.addToCart({
        "productId": product.id,
        "quantity": cart.value
            .firstWhere((item) => item.product?.id == product.id)
            .quantity,
      });

      if (response.statusCode == 200) {
        locator<SnackbarService>().showSnackbar(
            message: "Product added to cart",
            duration: const Duration(seconds: 2));
      } else {
        locator<SnackbarService>().showSnackbar(
            message: response.data["message"],
            duration: const Duration(seconds: 2));
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
          message: "Failed to add product to cart: $e",
          duration: const Duration(seconds: 2));
    } finally {
      // Remove product ID from loading set
      loadingItems.remove(product.id!);
      cart.notifyListeners();
      notifyListeners();
    }
  }

  void modifyCartQuantity(CartItem item, String action) async {
    setBusy(true);
    try {
      final res = await _repo.modifyCartItem(item.product!.id.toString(), action);

      if (res.statusCode == 200) {
        if (action == "increment") {
          item.quantity = item.quantity! + 1;
        } else if (action == "decrement" && item.quantity! > 1) {
          item.quantity = item.quantity! - 1;
        }

        cart.notifyListeners();
      } else {
        _snackBar.showSnackbar(message: "Failed to update cart: ${res.data['message']}", duration: Duration(seconds: 2));
      }
    } catch (e) {
      _log.e("Cart modification error: $e");
      _snackBar.showSnackbar(message: "An error occurred while updating the cart", duration: Duration(seconds: 2));
    } finally {
      setBusy(false);
    }
  }

  Future<List<Review>> fetchProductReviews(Product product) async {
    try {
      final response = await _repo.getReviews(product.id!);

      if (response.statusCode == 200) {
        final List<dynamic> reviewJson = response.data["reviews"];
        return reviewJson.map((r) => Review.fromJson(r)).toList();
      }
      return[];
    } catch (e) {
      print("Failed to load reviews: $e");
      return [];
    }
  }

  Future<void> toggleFavorite(Product product) async {
    final isFavorite = isProductFavorite(product.id!);

    if (isFavorite) {
      final favoriteItem = _favorites.firstWhere((f) => f.product.id == product.id);
      await removeFavorite(favoriteItem.id);
    } else {
      await addToFavorites(product.id!);
    }
  }

  Future<void> fetchFavorites() async {
    print('fetch favs');
    setBusy(true);
    try {
      final res = await _repo.getFavourites();
      _favorites = (res as List).map((e) => FavoriteItem.fromJson(e)).toList();
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> addToFavorites(String productId) async {
    final response = await _repo.addToFavourites({"productId": productId});
    if (response.statusCode == 201) {
      _snackBar.showSnackbar(message: 'Product added to favorites', duration: Duration(seconds: 2));
      await fetchFavorites();
    }

  }

  Future<void> removeFavorite(String favoriteId) async {
    await _repo.deleteFromFavourites(favoriteId);
    _favorites.removeWhere((f) => f.id == favoriteId);
    notifyListeners();
  }

  Future<void> _checkForUpdateOncePerDay() async {
    try {
      final lastCheckDate = await _localStorage.fetch(LocalStorageDir.lastUpdateCheck);
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      if (lastCheckDate != today) {
        await _updateService.checkForUpdate();
        await _localStorage.save(LocalStorageDir.lastUpdateCheck, today);
      } else {
        _log.i('Already checked for updates today');
      }
    } catch (e) {
      _log.e('Error checking update frequency: $e');
      
      await _updateService.checkForUpdate();
    }
  }

}
