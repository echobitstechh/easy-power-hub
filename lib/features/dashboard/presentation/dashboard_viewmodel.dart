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
import '../../../core/services/app_data_service.dart';
import '../../../core/services/update_service.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../state.dart';

class DashboardViewModel extends BaseViewModel {
  final _appData      = locator<AppDataService>();
  final _repo         = locator<Repository>();
  final _snackBar     = locator<SnackbarService>();
  final _localStorage = locator<LocalStorage>();
  final _updateService = locator<UpdateService>();
  final _log          = getLogger('DashboardViewModel');

  // ── Read-through to AppDataService ───────────────────────────────────────

  List<Product>  get productList       => _appData.products;
  List<Category> get filteredCategories => _appData.categories;
  List<String>   get brands             => _appData.brands;
  List<Tag>      get tags               => _appData.tags;

  // Mutable local list — callers (ShopView, ProductCard) can override this
  // to show a filtered subset without touching the service's master list.
  List<Product> filteredProductList = [];

  bool get isLoadingProducts   => _appData.isInitializing;
  bool get isLoadingCategories => _appData.isInitializing;
  bool get isLoadingTags       => _appData.isInitializing;
  bool get isLoadingMore       => _appData.isLoadingMore;

  // Tags error state (delegated; tags failures are silent after first load)
  bool   get hasTagsError => false;
  String? get tagsError   => null;

  // ── Local filter state ────────────────────────────────────────────────────

  String _selectedBrand     = '';
  Tag?   _selectedTag;
  int    _selectedCategoryId = 0;

  String get selectedBrand     => _selectedBrand;
  Tag?   get selectedTag       => _selectedTag;
  int    get selectedCategoryId => _selectedCategoryId;

  // ── Favourites ────────────────────────────────────────────────────────────

  List<FavoriteItem> _favorites = [];
  List<FavoriteItem> get favorites => _favorites;

  bool isProductFavorite(String productId) =>
      _favorites.any((f) => f.product.id == productId);

  // ── Search ────────────────────────────────────────────────────────────────

  List<Product> searchResults = [];
  bool isSearching      = false;
  bool isLoadingSearch  = false;
  String searchQuery    = '';

  Set<String> loadingItems = {};

  bool _isDisposed = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _isDisposed = true;
    _appData.removeListener(_onDataChanged);
    super.dispose();
  }

  Future<void> init() async {
    // Subscribe to service changes so the view rebuilds when data arrives.
    _appData.addListener(_onDataChanged);

    // Kick off a silent background refresh if data is stale. The UI already
    // shows whatever is in the service (cached or previously fetched).
    _appData.backgroundRefresh();

    if (userLoggedIn.value) {
      _loadCartFromLocal();
      fetchFavorites();
    }
    _checkForUpdateOncePerDay();
  }

  void _onDataChanged() => notifyListeners();

  // ── Refresh (pull-to-refresh) ─────────────────────────────────────────────

  Future<void> refresh() async {
    await _appData.refreshWithFilters(
      tag: _selectedTag?.name,
      brand: _selectedBrand,
      categoryId: _selectedCategoryId,
    );
  }

  // ── Pagination ────────────────────────────────────────────────────────────

  Future<void> getProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      await _appData.refreshWithFilters(
        tag: _selectedTag?.name,
        brand: _selectedBrand,
        categoryId: _selectedCategoryId,
      );
    } else {
      await _appData.loadMoreProducts(
        tag: _selectedTag?.name,
        brand: _selectedBrand,
        categoryId: _selectedCategoryId,
      );
    }
  }

  Future<void> fetchProductTags() => _appData.backgroundRefresh();

  // ── Filters ───────────────────────────────────────────────────────────────

  void setSelectedTag(Tag? tag) {
    _selectedTag       = tag;
    _selectedBrand     = '';
    _selectedCategoryId = 0;
    notifyListeners();
    _appData.refreshWithFilters(tag: tag?.name);
  }

  void setSelectedCategory(int categoryId) {
    _selectedCategoryId = categoryId;
    _selectedTag        = null;
    _selectedBrand      = '';
    notifyListeners();
    _appData.refreshWithFilters(categoryId: categoryId);
  }

  void filterProductsByBrand(String brand) {
    _selectedBrand = brand.toLowerCase() == 'all' ? '' : brand;
    notifyListeners();
    _appData.refreshWithFilters(brand: _selectedBrand);
  }

  Future<void> resetFilters() async {
    _selectedTag        = null;
    _selectedBrand      = '';
    _selectedCategoryId = 0;
    notifyListeners();
    await _appData.refreshWithFilters();
  }

  // ── Search ────────────────────────────────────────────────────────────────

  Future<void> performSearch(String query) async {
    searchQuery = query.trim();

    if (searchQuery.isEmpty) {
      searchResults  = [];
      isSearching    = false;
      isLoadingSearch = false;
      notifyListeners();
      return;
    }

    isSearching     = true;
    isLoadingSearch = true;
    notifyListeners();

    try {
      final res = await _repo.searchProducts(query: searchQuery);
      if (res.statusCode == 200 && res.data != null) {
        searchResults = (res.data['products'] as List)
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .where((p) => p.status?.toLowerCase() == 'active')
            .toList()
          ..sort((a, b) {
            final aOk = (a.availability ?? 0) >= 1;
            final bOk = (b.availability ?? 0) >= 1;
            if (aOk && !bOk) return -1;
            if (!aOk && bOk) return 1;
            return 0;
          });
      } else {
        searchResults = [];
      }
    } catch (e) {
      _log.e('Search error: $e');
      searchResults = [];
      _snackBar.showSnackbar(
        message: 'Search failed. Please try again.',
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoadingSearch = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    searchQuery     = '';
    searchResults   = [];
    isSearching     = false;
    isLoadingSearch = false;
    notifyListeners();
  }

  // ── Cart ──────────────────────────────────────────────────────────────────

  void _loadCartFromLocal() async {
    try {
      final stored = await _localStorage.fetch(LocalStorageDir.productCart);
      if (stored != null) {
        cart.value = (stored as List)
            .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      _log.e('Failed to load local cart: $e');
    }
  }

  void addProductToCart(Product product) async {
    loadingItems.add(product.id!);
    notifyListeners();

    // Optimistic local update first
    final idx = cart.value.indexWhere((i) => i.product?.id == product.id);
    if (idx == -1) {
      cart.value.add(CartItem(product: product, quantity: 1));
      cart.notifyListeners();
    }
    await _saveLocalCart();

    if (!userLoggedIn.value) {
      // Guest mode — local cart only; flag for sync after login
      await _localStorage.save(LocalStorageDir.cartNeedsSync, true);
      if (!_isDisposed) {
        _snackBar.showSnackbar(
            message: 'Added to cart', duration: const Duration(seconds: 2));
      }
      loadingItems.remove(product.id!);
      notifyListeners();
      return;
    }

    try {
      final response = await _repo.addToCart({
        'productId': product.id,
        'quantity': cart.value
            .firstWhere((i) => i.product?.id == product.id)
            .quantity,
      });

      if (!_isDisposed) {
        if (response.statusCode == 200) {
          _snackBar.showSnackbar(
              message: 'Added to cart', duration: const Duration(seconds: 2));
        } else {
          _snackBar.showSnackbar(
              message: response.data['message'],
              duration: const Duration(seconds: 2));
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        _snackBar.showSnackbar(
            message: 'Failed to add to cart',
            duration: const Duration(seconds: 2));
      }
    } finally {
      loadingItems.remove(product.id!);
      if (!_isDisposed) {
        cart.notifyListeners();
        notifyListeners();
      }
    }
  }

  void modifyCartQuantity(CartItem item, String action) async {
    // Local update first
    if (action == 'increment') {
      item.quantity = (item.quantity ?? 0) + 1;
    } else if (action == 'decrement' && (item.quantity ?? 1) > 1) {
      item.quantity = item.quantity! - 1;
    }
    cart.notifyListeners();
    await _saveLocalCart();

    if (!userLoggedIn.value) return;

    setBusy(true);
    try {
      await _repo.modifyCartItem(item.product!.id.toString(), action);
    } catch (e) {
      _log.e('Cart modify error: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> _saveLocalCart() async {
    try {
      await _localStorage.save(
        LocalStorageDir.productCart,
        cart.value.map((e) => e.toJson()).toList(),
      );
    } catch (e) {
      _log.e('Failed to save local cart: $e');
    }
  }

  // ── Favourites ────────────────────────────────────────────────────────────

  Future<void> fetchFavorites() async {
    if (!userLoggedIn.value) return;
    try {
      final res = await _repo.getFavourites();
      _favorites = (res as List).map((e) => FavoriteItem.fromJson(e)).toList();
      if (!_isDisposed) notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleFavorite(Product product) async {
    if (isProductFavorite(product.id!)) {
      final fav = _favorites.firstWhere((f) => f.product.id == product.id);
      await _repo.deleteFromFavourites(fav.id);
      _favorites.removeWhere((f) => f.id == fav.id);
    } else {
      await _repo.addToFavourites({'productId': product.id});
      await fetchFavorites();
    }
    notifyListeners();
  }

  // ── Reviews ───────────────────────────────────────────────────────────────

  Future<List<Review>> fetchProductReviews(Product product) async {
    try {
      final res = await _repo.getReviews(product.id!);
      if (res.statusCode == 200) {
        return (res.data['reviews'] as List)
            .map((r) => Review.fromJson(r))
            .toList();
      }
    } catch (e) {
      _log.e('fetchProductReviews error: $e');
    }
    return [];
  }

  // ── Misc ──────────────────────────────────────────────────────────────────

  bool isNewProduct(String createdAt) {
    try {
      return DateTime.now().difference(DateTime.parse(createdAt)).inDays <= 14;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkForUpdateOncePerDay() async {
    try {
      final lastCheck = await _localStorage.fetch(LocalStorageDir.lastUpdateCheck);
      final today     = DateTime.now().toIso8601String().split('T')[0];
      if (lastCheck != today) {
        await _updateService.checkForUpdate();
        await _localStorage.save(LocalStorageDir.lastUpdateCheck, today);
      }
    } catch (e) {
      _log.e('Update check error: $e');
    }
  }
}
