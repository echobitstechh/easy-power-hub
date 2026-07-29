import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../core/data/models/cart_item.dart';
import '../../../core/data/models/category.dart';
import '../../../core/data/models/favourite.dart';
import '../../../core/data/models/order_item.dart';
import '../../../core/data/models/product.dart';
import '../../../core/data/models/tags.dart';
import '../../../core/data/repositories/repository.dart';
import '../../../core/services/app_data_service.dart';
import '../../../core/services/update_service.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../core/utils/paystack_util.dart';
import '../../../state.dart' as appState;
import '../../../state.dart' show userLoggedIn, profile, cart, uiMode, appLoading, isLoginByEmail, isOtpRequestedByEmail, globalCategories, isFirstLaunch, unreadCount;

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

  static const _searchLimit = 20;

  List<Product> searchResults = [];
  List<Product> relatedSearchResults = [];
  bool isSearching      = false;
  bool isLoadingSearch  = false;
  String searchQuery    = '';

  int  _searchPage        = 1;
  bool _searchIsLastPage  = false;
  bool _searchLoadingMore = false;
  bool get isLoadingMoreSearch => _searchLoadingMore;
  bool get hasMoreSearchResults => !_searchIsLastPage;

  List<String> _recentSearches = [];
  List<String> get recentSearches => _recentSearches;

  Set<String> loadingItems = {};

  bool _isDisposed = false;
  bool _isSubscribed = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  void _subscribe() {
    if (_isSubscribed) return;
    _appData.addListener(_onDataChanged);
    _isSubscribed = true;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _appData.removeListener(_onDataChanged);
    super.dispose();
  }

  Future<void> init() async {
    // Subscribe to service changes so the view rebuilds when data arrives.
    _subscribe();

    // Kick off a silent background refresh if data is stale. The UI already
    // shows whatever is in the service (cached or previously fetched).
    _appData.backgroundRefresh();

    if (userLoggedIn.value) {
      _loadCartFromLocal();
      fetchFavorites();
      fetchPayNowOrder();
    }
    _checkForUpdateOncePerDay();
    checkHomePopups();
  }

  void _onDataChanged() => notifyListeners();

  // ── Home popups (welcome offer / new arrivals) ───────────────────────────
  // Mirrors web's localStorage-driven, one-time welcome popup and "new since
  // last visit" arrivals popup — no backend flag involved on either side.

  bool _welcomePopupPending = false;
  bool get welcomePopupPending => _welcomePopupPending;

  List<Product> _newArrivals = [];
  List<Product> get newArrivals => _newArrivals;
  bool get newArrivalsPending => _newArrivals.isNotEmpty;

  Future<void> checkHomePopups() async {
    try {
      final shown = await _localStorage.fetch(LocalStorageDir.welcomePopupShown);
      _welcomePopupPending = shown != true;
    } catch (e) {
      _log.e('checkHomePopups welcome error: $e');
    }

    try {
      if (productList.isNotEmpty) {
        final lastSeenRaw =
            await _localStorage.fetch(LocalStorageDir.lastSeenProductTime);
        if (lastSeenRaw == null) {
          // First time ever — establish a baseline; nothing is "new" yet.
          await _saveLatestProductTimestamp();
        } else {
          final lastSeen = DateTime.tryParse(lastSeenRaw);
          if (lastSeen != null) {
            _newArrivals = productList.where((p) {
              final created = DateTime.tryParse(p.createdAt ?? '');
              return created != null && created.isAfter(lastSeen);
            }).take(3).toList();
          }
        }
      }
    } catch (e) {
      _log.e('checkHomePopups new-arrivals error: $e');
    }

    if (!_isDisposed) notifyListeners();
  }

  Future<void> _saveLatestProductTimestamp() async {
    final latest = productList
        .map((p) => DateTime.tryParse(p.createdAt ?? ''))
        .whereType<DateTime>()
        .fold<DateTime?>(
            null, (max, d) => (max == null || d.isAfter(max)) ? d : max);
    if (latest != null) {
      await _localStorage.save(
          LocalStorageDir.lastSeenProductTime, latest.toIso8601String());
    }
  }

  Future<void> dismissWelcomePopup() async {
    _welcomePopupPending = false;
    notifyListeners();
    await _localStorage.save(LocalStorageDir.welcomePopupShown, true);
  }

  Future<void> dismissNewArrivalsPopup() async {
    _newArrivals = [];
    notifyListeners();
    await _saveLatestProductTimestamp();
  }

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
    _subscribe();
    _selectedTag       = tag;
    _selectedBrand     = '';
    _selectedCategoryId = 0;
    notifyListeners();
    _appData.refreshWithFilters(tag: tag?.name);
  }

  void setSelectedCategory(int categoryId) {
    _subscribe();
    _selectedCategoryId = categoryId;
    _selectedTag        = null;
    _selectedBrand      = '';
    notifyListeners();
    _appData.refreshWithFilters(categoryId: categoryId);
  }

  void filterProductsByBrand(String brand) {
    _subscribe();
    _selectedBrand = brand.toLowerCase() == 'all' ? '' : brand;
    _selectedTag        = null;
    _selectedCategoryId = 0;
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
      relatedSearchResults = [];
      isSearching    = false;
      isLoadingSearch = false;
      _searchPage = 1;
      _searchIsLastPage = false;
      notifyListeners();
      return;
    }

    isSearching     = true;
    isLoadingSearch = true;
    _searchPage       = 1;
    _searchIsLastPage = false;
    relatedSearchResults = [];
    notifyListeners();

    try {
      final res = await _repo.searchProducts(
          query: searchQuery, page: 1, limit: _searchLimit);
      if (res.statusCode == 200 && res.data != null) {
        final items = (res.data['products'] as List)
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .where((p) => p.status?.toLowerCase() == 'active')
            .toList();
        _sortSearchResults(items);
        searchResults = items;
        _searchIsLastPage = items.length < _searchLimit;
        if (searchResults.isNotEmpty) {
          _saveRecentSearch(searchQuery);
          _loadRelatedSearchResults();
        }
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

  Future<void> loadMoreSearchResults() async {
    if (_searchIsLastPage || _searchLoadingMore || searchQuery.isEmpty) return;
    _searchLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _searchPage + 1;
      final res = await _repo.searchProducts(
          query: searchQuery, page: nextPage, limit: _searchLimit);
      if (res.statusCode == 200 && res.data != null) {
        final items = (res.data['products'] as List)
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .where((p) => p.status?.toLowerCase() == 'active')
            .toList();
        final existingIds = searchResults.map((p) => p.id).toSet();
        searchResults.addAll(items.where((p) => !existingIds.contains(p.id)));
        _sortSearchResults(searchResults);
        if (items.length < _searchLimit) {
          _searchIsLastPage = true;
        } else {
          _searchPage = nextPage;
        }
      }
    } catch (e) {
      _log.e('loadMoreSearchResults error: $e');
    } finally {
      _searchLoadingMore = false;
      notifyListeners();
    }
  }

  void _sortSearchResults(List<Product> items) {
    items.sort((a, b) {
      final aOk = (a.availability ?? 0) >= 1;
      final bOk = (b.availability ?? 0) >= 1;
      if (aOk && !bOk) return -1;
      if (!aOk && bOk) return 1;
      return 0;
    });
  }

  Future<void> _loadRelatedSearchResults() async {
    try {
      final categoryCounts = <int, int>{};
      for (final p in searchResults) {
        if (p.categoryId != null) {
          categoryCounts[p.categoryId!] = (categoryCounts[p.categoryId!] ?? 0) + 1;
        }
      }
      if (categoryCounts.isEmpty) {
        relatedSearchResults = [];
        notifyListeners();
        return;
      }
      final topCategoryId = categoryCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      final matchedIds = searchResults.map((p) => p.id).toSet();
      final res = await _repo.getProducts(
        page: 1,
        limit: 12,
        categoryId: topCategoryId.toString(),
      );
      if (res.statusCode == 200) {
        relatedSearchResults = (res.data['products'] as List)
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .where((p) =>
                p.status?.toLowerCase() == 'active' &&
                !matchedIds.contains(p.id))
            .take(8)
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _log.e('_loadRelatedSearchResults error: $e');
    }
  }

  void clearSearch() {
    searchQuery     = '';
    searchResults   = [];
    relatedSearchResults = [];
    isSearching     = false;
    isLoadingSearch = false;
    _searchPage = 1;
    _searchIsLastPage = false;
    notifyListeners();
  }

  // ── Recent searches ───────────────────────────────────────────────────────

  Future<void> loadRecentSearches() async {
    try {
      final stored = await _localStorage.fetch(LocalStorageDir.recentSearches);
      if (stored != null) {
        _recentSearches = (stored as List).map((e) => e.toString()).toList();
        if (!_isDisposed) notifyListeners();
      }
    } catch (e) {
      _log.e('loadRecentSearches error: $e');
    }
  }

  Future<void> _saveRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _recentSearches.removeWhere((q) => q.toLowerCase() == trimmed.toLowerCase());
    _recentSearches.insert(0, trimmed);
    if (_recentSearches.length > 6) {
      _recentSearches = _recentSearches.sublist(0, 6);
    }
    try {
      await _localStorage.save(LocalStorageDir.recentSearches, _recentSearches);
    } catch (e) {
      _log.e('_saveRecentSearch error: $e');
    }
  }

  Future<void> removeRecentSearch(String query) async {
    _recentSearches.removeWhere((q) => q == query);
    notifyListeners();
    try {
      await _localStorage.save(LocalStorageDir.recentSearches, _recentSearches);
    } catch (e) {
      _log.e('removeRecentSearch error: $e');
    }
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

  void addProductToCart(Product product, {bool isUnavailable = false}) async {
    loadingItems.add(product.id!);
    notifyListeners();

    // Optimistic local update first
    final idx = cart.value.indexWhere((i) => i.product?.id == product.id);
    if (idx == -1) {
      cart.value.add(CartItem(product: product, quantity: 1, isUnavailable: isUnavailable));
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
        'isUnavailable': isUnavailable,
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
    if (!userLoggedIn.value) return;
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

  // ── Pay Now reminder ──────────────────────────────────────────────────────
  // Mirrors web's home-page banner: the most recent Processing order that's
  // InstantPayment and still unpaid gets a dismissible "Pay Now" prompt.

  Order? _payNowOrder;
  Order? get payNowOrder => _payNowOrder ?? appState.payNowOrder.value;

  String? _dismissedPayNowOrderId;

  bool get showPayNowBanner {
    final order = payNowOrder;
    if (order == null) return false;
    final dismissedId = appState.dismissedPayNowId.value ?? _dismissedPayNowOrderId;
    return order.id != dismissedId;
  }

  Future<void> fetchPayNowOrder() async {
    if (!userLoggedIn.value) return;
    try {
      final res = await _repo.getOrderList();
      if (res.statusCode == 200) {
        final candidates = (res.data['orders'] as List)
            .map((o) => Order.fromJson(Map<String, dynamic>.from(o)))
            .where((o) =>
                o.status == 'Processing' &&
                o.orderType == 'InstantPayment' &&
                !o.isPaid)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _payNowOrder = candidates.isNotEmpty ? candidates.first : null;
        // Push to global notifier so floating banner reacts app-wide
        appState.payNowOrder.value = _payNowOrder;
        if (!_isDisposed) notifyListeners();
      }
    } catch (e) {
      _log.e('fetchPayNowOrder error: $e');
    }
  }

  void dismissPayNowBanner() {
    final order = payNowOrder;
    if (order != null) {
      _dismissedPayNowOrderId = order.id;
      // Sync global notifier so the floating banner dismisses everywhere
      appState.dismissedPayNowId.value = order.id;
    }
    notifyListeners();
  }

  Future<void> payNowForBannerOrder(BuildContext context) async {
    final order = _payNowOrder;
    if (order == null) return;
    try {
      final response = await _repo.initializePayment({
        'paymentMethod': 'CreditCard',
        'paymentType': 'Paystack',
        'orderId': order.id,
      });
      if (!context.mounted) return;
      if (response.statusCode == 200) {
        await PaystackUtil.processPayment(
          context: context,
          ref: response.data['data']['reference'],
          accessCode: response.data['data']['access_code'],
          url: response.data['data']['authorization_url'],
          amountInNaira: order.totalPrice,
          email: profile.value.email!,
          cartItems: order.products
              .map((p) => CartItem(
                    product: p,
                    quantity: 1,
                    price: double.tryParse(p.salePrice ?? '0.0') ?? 0.0,
                  ))
              .toList(),
        );
      } else {
        _snackBar.showSnackbar(
          message: "Payment initialization failed.",
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _log.e('payNowForBannerOrder error: $e');
      _snackBar.showSnackbar(
        message: "An error occurred during payment.",
        duration: const Duration(seconds: 2),
      );
    }
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
