import 'package:stacked/stacked.dart';

import '../../app/app.locator.dart';
import '../../app/app.logger.dart';
import '../data/models/ad_media.dart';
import '../data/models/category.dart';
import '../data/models/product.dart';
import '../data/models/tags.dart';
import '../data/repositories/repository.dart';
import '../utils/local_store_dir.dart';
import '../utils/local_stotage.dart';

/// Single source of truth for all remote data that is shared across features.
///
/// Call [prefetch] once at startup. It serves cached data immediately while
/// a network refresh runs in the background. Every subsequent [backgroundRefresh]
/// is silent — no loading flag is ever set after the first load.
class AppDataService with ListenableServiceMixin {
  final _repo = locator<Repository>();
  final _storage = locator<LocalStorage>();
  final _log = getLogger('AppDataService');

  static const _staleAfter = Duration(minutes: 10);
  static const _pageLimit  = 12;

  // ── Public data ──────────────────────────────────────────────────────────

  List<Product>  products   = [];
  List<Category> categories = [];
  List<Tag>      tags       = [];
  List<String>   brands     = [];
  List<AdMedia>  adMedias   = [];

  // Pagination
  int  _currentPage = 1;
  bool _isLastPage  = false;
  bool _loadingMore = false;
  bool get isLoadingMore => _loadingMore;
  bool get isLastPage    => _isLastPage;

  // True only during the very first fetch when lists are still empty.
  bool _initializing = false;
  bool get isInitializing => _initializing;

  bool get hasData => products.isNotEmpty;

  DateTime? _lastFetched;
  bool get _isStale =>
      _lastFetched == null ||
      DateTime.now().difference(_lastFetched!) > _staleAfter;

  AppDataService() {
    listenToReactiveValues([]);
  }

  // ── Startup prefetch ──────────────────────────────────────────────────────

  /// Called once from [StartupViewModel]. Loads cache first so the UI shows
  /// data instantly, then kicks a silent network refresh.
  Future<void> prefetch() async {
    await _loadFromCache();

    if (products.isEmpty) {
      // First ever open — show loading state while fetching.
      _initializing = true;
      notifyListeners();
    }

    await _networkRefresh();

    _initializing = false;
    notifyListeners();
  }

  // ── Background refresh (called by ViewModels) ─────────────────────────────

  /// Silently refreshes if data is stale. Never triggers a loading indicator.
  Future<void> backgroundRefresh() async {
    if (!_isStale) return;
    await _networkRefresh();
    notifyListeners();
  }

  // ── Pagination (load-more for products) ───────────────────────────────────

  Future<void> loadMoreProducts({
    String? tag,
    String? brand,
    int? categoryId,
  }) async {
    if (_isLastPage || _loadingMore) return;
    _loadingMore = true;
    notifyListeners();

    try {
      final res = await _repo.getProducts(
        page: _currentPage,
        limit: _pageLimit,
        tag: tag,
        brand: brand?.isNotEmpty == true ? brand : null,
        categoryId: categoryId != null && categoryId != 0
            ? categoryId.toString()
            : null,
      );

      if (res.statusCode == 200) {
        final newItems = _parseProducts(res.data);
        _mergeProducts(newItems);

        if (newItems.length < _pageLimit) {
          _isLastPage = true;
        } else {
          _currentPage++;
        }
      }
    } catch (e) {
      _log.e('loadMoreProducts error: $e');
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  // ── Filter-aware refresh ──────────────────────────────────────────────────

  Future<void> refreshWithFilters({
    String? tag,
    String? brand,
    int? categoryId,
  }) async {
    _resetPagination();
    _initializing = products.isEmpty;
    notifyListeners();

    try {
      final hasCategoryFilter = categoryId != null && categoryId != 0;

      final futures = <Future>[
        _repo.getProducts(
          page: 1,
          limit: _pageLimit,
          tag: tag,
          brand: brand?.isNotEmpty == true ? brand : null,
          categoryId: hasCategoryFilter ? categoryId.toString() : null,
        ),
        // Re-fetch tags scoped to the active category (or all tags when none).
        _repo.getProductTags(categoryId: hasCategoryFilter ? categoryId : null),
      ];

      final results = await Future.wait(futures);
      final productsRes = results[0] as dynamic;
      final tagsRes     = results[1] as dynamic;

      if (productsRes.statusCode == 200) {
        products = _parseProducts(productsRes.data);
        _sortProducts();
        if ((productsRes.data['brands'] as List?)?.isNotEmpty == true) {
          brands = (productsRes.data['brands'] as List).map((b) => b.toString()).toList();
        }
        _currentPage = products.length >= _pageLimit ? 2 : 1;
        _isLastPage  = products.length < _pageLimit;
      }

      if (tagsRes.statusCode == 200) {
        tags = (tagsRes.data['tags'] as List? ?? [])
            .map((t) => Tag.fromJson(Map<String, dynamic>.from(t)))
            .toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      }
    } catch (e) {
      _log.e('refreshWithFilters error: $e');
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _networkRefresh() async {
    try {
      await Future.wait([
        _fetchProducts(),
        _fetchCategories(),
        _fetchTags(),
        _fetchAdMedias(),
      ]);
      _lastFetched = DateTime.now();
      await _saveToCache();
    } catch (e) {
      _log.e('_networkRefresh error: $e');
    }
  }

  Future<void> _fetchProducts() async {
    try {
      _resetPagination();
      final res = await _repo.getProducts(page: 1, limit: _pageLimit);
      if (res.statusCode == 200) {
        products = _parseProducts(res.data);
        _sortProducts();
        brands = (res.data['brands'] as List? ?? [])
            .map((b) => b.toString())
            .toList();
        _currentPage = products.length >= _pageLimit ? 2 : 1;
        _isLastPage  = products.length < _pageLimit;
      }
    } catch (e) {
      _log.e('_fetchProducts error: $e');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final res = await _repo.getCategories();
      if (res.statusCode == 200 && res.data?['categories'] != null) {
        final fetched = (res.data['categories'] as List)
            .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
            .where((c) => c.status == CategoryStatus.active)
            .toList();
        categories = [
          Category(id: 0, name: 'All', status: CategoryStatus.active),
          ...fetched,
        ];
        // Keep global categories in sync.
        await _storage.save(
          LocalStorageDir.cachedCategories,
          fetched.map((c) => c.toJson()).toList(),
        );
      }
    } catch (e) {
      _log.e('_fetchCategories error: $e');
    }
  }

  Future<void> _fetchTags() async {
    try {
      final res = await _repo.getProductTags();
      if (res.statusCode == 200) {
        tags = (res.data['tags'] as List? ?? [])
            .map((t) => Tag.fromJson(Map<String, dynamic>.from(t)))
            .toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      }
    } catch (e) {
      _log.e('_fetchTags error: $e');
    }
  }

  Future<void> _fetchAdMedias() async {
    try {
      final res = await _repo.getAdMedias();
      if (res.statusCode == 200) {
        adMedias = (res.data['adMedias'] as List? ?? [])
            .map((m) => AdMedia.fromJson(Map<String, dynamic>.from(m)))
            .where((m) => m.active)
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
      }
    } catch (e) {
      _log.e('_fetchAdMedias error: $e');
    }
  }

  // ── Cache helpers ─────────────────────────────────────────────────────────

  Future<void> _loadFromCache() async {
    try {
      final rawProducts = await _storage.fetch(LocalStorageDir.cachedProducts);
      if (rawProducts != null) {
        products = (rawProducts as List)
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      final rawCategories =
          await _storage.fetch(LocalStorageDir.cachedCategories);
      if (rawCategories != null) {
        final cached = (rawCategories as List)
            .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        categories = [
          Category(id: 0, name: 'All', status: CategoryStatus.active),
          ...cached,
        ];
      }

      final rawTags = await _storage.fetch(LocalStorageDir.cachedTags);
      if (rawTags != null) {
        tags = (rawTags as List)
            .map((e) => Tag.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      final rawBrands = await _storage.fetch(LocalStorageDir.cachedBrands);
      if (rawBrands != null) {
        brands = (rawBrands as List).map((b) => b.toString()).toList();
      }

      final ts = await _storage.fetch(LocalStorageDir.cacheTimestamp);
      if (ts != null) {
        _lastFetched = DateTime.tryParse(ts);
      }

      if (products.isNotEmpty) notifyListeners();
    } catch (e) {
      _log.e('_loadFromCache error: $e');
    }
  }

  Future<void> _saveToCache() async {
    try {
      await Future.wait([
        _storage.save(LocalStorageDir.cachedProducts,
            products.map((p) => p.toJson()).toList()),
        _storage.save(LocalStorageDir.cachedBrands, brands),
        _storage.save(LocalStorageDir.cacheTimestamp,
            DateTime.now().toIso8601String()),
      ]);
    } catch (e) {
      _log.e('_saveToCache error: $e');
    }
  }

  // ── Utils ─────────────────────────────────────────────────────────────────

  List<Product> _parseProducts(dynamic data) {
    return (data['products'] as List)
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
        .where((p) => p.status?.toLowerCase() == 'active')
        .toList();
  }

  void _sortProducts() {
    products.sort((a, b) {
      final aOk = (a.availability ?? 0) >= 1;
      final bOk = (b.availability ?? 0) >= 1;
      if (aOk && !bOk) return -1;
      if (!aOk && bOk) return 1;
      return 0;
    });
  }

  void _mergeProducts(List<Product> newItems) {
    final existingIds = products.map((p) => p.id!).toSet();
    for (final p in newItems) {
      if (p.id != null && !existingIds.contains(p.id)) {
        products.add(p);
      }
    }
    _sortProducts();
  }

  void _resetPagination() {
    _currentPage = 1;
    _isLastPage  = false;
  }
}
