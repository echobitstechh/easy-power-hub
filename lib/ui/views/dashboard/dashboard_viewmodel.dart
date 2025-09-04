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
    //await loadProduct();
    if (userLoggedIn.value == true) {
      initCart();
    }
    setBusy(false);
    notifyListeners();
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