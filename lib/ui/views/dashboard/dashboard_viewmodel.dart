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

  static const int allCategoriesId = 0;

  int selectedId = allCategoriesId;
  String selectedBrand = '';

  bool? onboarded;

  bool appBarLoading = false;
  final snackBar = locator<SnackbarService>();

  void setSelectedCategory(int id) {
    selectedId = id;

    if (id == allCategoriesId) {
      filteredProductList = productList;
      brands = filteredProductList.map((product) => product.brandName ?? '').toSet().toList();
    } else {
      print('id is: $id');
      filteredProductList = productList.where((product) {
        return product.categoryId == id;
      }).toList();
      brands = filteredProductList.map((product) => product.brandName ?? '').toSet().toList();
    }

    notifyListeners();
  }

  void setSelectedBrand(String brand) {
    selectedBrand = brand;

    if (brand.isEmpty) {
      filteredProductList = productList;
    } else {
      filteredProductList = productList.where((product) {
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
    return difference <= 14;  // 14 days = 2 weeks
  }


  Future<void> loadProduct() async {
    print('loading products....');
    try {

      dynamic storedJsonProduct = await locator<LocalStorage>().fetch(LocalStorageDir.product);
      log.i("Loaded jsonProducts from storage: $storedJsonProduct");


      if ( storedJsonProduct != null && storedJsonProduct.isNotEmpty) {
        List<dynamic> storedProducts = jsonDecode(storedJsonProduct);
        print('Decoded JSON: $storedProducts');
        // Populate productList and filteredProductList
        productList = storedProducts
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        filteredProductList = productList;
        brands = filteredProductList.map((product) => product.brandName ?? '').toSet().toList();

        print('loaded products from local storage list ${productList.length}');
        print('loaded products from local storage ${productList.map((e) => e.salePrice)}');
        rebuildUi();
      }else{
        print('no value to load');
      }

      // Make API call in the background
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

  Future<void> getProducts() async {
    print('getting online products');
    try {
      ApiResponse res = await repo.getProducts();

      if (res.statusCode == 200) {
        // Fetch updated products from API
        List<Product> updatedProductList = (res.data["products"] as List)
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .where((product) => product.status?.toLowerCase() == 'active') // Filter out inactive
            .toList();

        // Update the product list
        productList = updatedProductList;
        filteredProductList = productList;
        brands = filteredProductList.map((product) => product.brandName ?? '').toSet().toList();

        // Save updated data to local storage
        List<Map<String, dynamic>> storedProducts =
        productList.map((e) => e.toJson()).toList();
        await locator<LocalStorage>().save(LocalStorageDir.product, jsonEncode(storedProducts));
        rebuildUi();
      } else {
        log.e("API Error: ${res.data["message"]}");
      }
    } catch (e) {
      log.e("Error fetching products: $e");
    }
  }

  Future<void> loadCategories() async {
    try {
      // First try to load from API
      await getCategories();

      // If API fails, fall back to local storage
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

      // Always include "All" option and update filtered list
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

        // Save the active categories locally
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
