import 'dart:convert';
import 'dart:collection';
import 'dart:async';
import 'dart:developer';

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

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  factory DatabaseManager() => _instance;
  DatabaseManager._internal();

  final Queue<_Operation> _operationQueue = Queue();
  bool _isProcessing = false;
  final Map<String, Completer> _activeOperations = {};

  Future<T> executeOperation<T>(Future<T> Function() operation, {String? operationId}) async {
    final completer = Completer<T>();
    final id = operationId ?? DateTime.now().millisecondsSinceEpoch.toString();

    // Prevent duplicate operations
    if (_activeOperations.containsKey(id)) {
      return _activeOperations[id]!.future as Future<T>;
    }

    _activeOperations[id] = completer;

    final operationWrapper = _Operation(
      id: id,
      execute: () async {
        try {
          final result = await operation().timeout(
            const Duration(seconds: 30), // Prevent indefinite locks
            onTimeout: () => throw TimeoutException('Database operation timed out', const Duration(seconds: 30)),
          );
          completer.complete(result);
        } catch (e) {
          completer.completeError(e);
        } finally {
          _activeOperations.remove(id);
        }
      },
    );

    _operationQueue.add(operationWrapper);
    _processQueue();
    return completer.future;
  }

  void _processQueue() async {
    if (_isProcessing || _operationQueue.isEmpty) return;

    _isProcessing = true;
    while (_operationQueue.isNotEmpty) {
      final operation = _operationQueue.removeFirst();
      try {
        await operation.execute();
      } catch (e) {
        print('Database operation ${operation.id} failed: $e');
      }
    }
    _isProcessing = false;
  }

  void clearQueue() {
    _operationQueue.clear();
    for (final completer in _activeOperations.values) {
      if (!completer.isCompleted) {
        completer.completeError('Operation cancelled');
      }
    }
    _activeOperations.clear();
  }
}

class _Operation {
  final String id;
  final Future<void> Function() execute;

  _Operation({required this.id, required this.execute});
}

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

  Timer? _debounceTimer;
  bool _isInitializing = false;


  void resetFilters() {
    selectedId = allCategoriesId;
    selectedBrand = '';
    _selectedTag = null;

    Set<String> seenIds = {};
    List<Product> uniqueProducts = [];
    for (Product product in productList) {
      if (!seenIds.contains(product.id)) {
        uniqueProducts.add(product);
        seenIds.add(product.id!);
      }
    }

    filteredProductList = uniqueProducts;
    Set<String> uniqueBrands = {};
    for (Product product in filteredProductList) {
      if (product.brandName != null && product.brandName!.isNotEmpty) {
        uniqueBrands.add(product.brandName!);
      }
    }
    brands = uniqueBrands.toList();
    notifyListeners();
  }





  void clearAllFilters() {
    _selectedTag = null;
    selectedId = allCategoriesId;
    selectedBrand = '';
    final seenIds = <String>{};
    final uniqueProducts = <Product>[];
    for (final product in productList) {
      if (product.id != null && !seenIds.contains(product.id)) {
        uniqueProducts.add(product);
        seenIds.add(product.id!);
      }
    }
    filteredProductList = uniqueProducts;

    notifyListeners();
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
    _debounceTimer?.cancel();
    DatabaseManager().clearQueue();
    super.dispose();
  }

  Future<void> init() async {
    if (_isInitializing) return; // Prevent multiple init calls

    _isInitializing = true;
    setBusy(true);
    print("loading the initials");
    notifyListeners();

    try {

      if (userLoggedIn.value == true) {
        initCart();
      }
    } catch (e) {
      log.e("Error during initialization: $e");
    } finally {
      _isInitializing = false;
      setBusy(false);
      notifyListeners();
    }
  }


  Future<void> refreshData() async {
    setBusy(true);
    notifyListeners();
    setBusy(false);
    notifyListeners();
  }









  void initCart() async {
    try {
      await DatabaseManager().executeOperation(() async {
        dynamic storedData = await locator<LocalStorage>().fetch(LocalStorageDir.raffleCart);

        if (storedData != null) {
          List<CartItem> localCart = List<Map<String, dynamic>>.from(storedData)
              .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          cart.value = localCart;
        }
      }, operationId: 'init_cart');
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
}
