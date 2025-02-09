import 'dart:convert';

import 'package:afriprize/app/app.locator.dart';
import 'package:afriprize/app/app.logger.dart';
import 'package:afriprize/core/data/models/product.dart';
import 'package:afriprize/core/data/models/raffle_cart_item.dart';
import 'package:afriprize/core/data/repositories/repository.dart';
import 'package:afriprize/core/network/api_response.dart';
import 'package:afriprize/core/utils/local_store_dir.dart';
import 'package:afriprize/core/utils/local_stotage.dart';
import 'package:afriprize/state.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../core/data/models/cart_item.dart';
import '../../../core/data/models/category.dart';
import '../../../core/data/models/project.dart';

class DashboardViewModel extends BaseViewModel {
  final repo = locator<Repository>();
  int selectedIndex = 0;
  final log = getLogger("DashboardViewModel");
  List<Ads> adsList = [];
  List<Product> productList = [];
  List<Product> filteredProductList = [];
  List<Category> filteredCategories = [];
  List<Category> filteredCategoriesList = [];
  List<Category> categories = [];

  static const int allCategoriesId = 0;

  int selectedId = allCategoriesId;

  bool? onboarded;

  bool appBarLoading = false;
  final snackBar = locator<SnackbarService>();

  void setSelectedCategory(int id) {
    selectedId = id;

    if (id == allCategoriesId) {
      filteredProductList = productList;
    } else {
      print('id is: $id');
      filteredProductList = productList.where((product) {
        return product.categoryId == id;
      }).toList();
    }

    notifyListeners();
  }

  void changeSelected(int i) {
    selectedIndex = i;
    rebuildUi();
  }

  @override
  void dispose() {
    // controller.dispose();
    super.dispose();
  }


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



  Future<void> loadProduct() async {
    print('loading products....');
    try {

      dynamic storedJsonProduct = await locator<LocalStorage>().fetch(LocalStorageDir.product);
      log.i("Loaded jsonProducts from storage: $storedJsonProduct");


      if ( storedJsonProduct != null && storedJsonProduct.isNotEmpty) {
        List<dynamic> storedProducts = jsonDecode(storedJsonProduct);
        // Populate productList and filteredProductList
        productList = storedProducts
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        filteredProductList = productList;
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
            .toList();

        // Update the product list
        productList = updatedProductList;
        filteredProductList = productList;

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
    dynamic storedDonations = await locator<LocalStorage>()
        .fetch(LocalStorageDir.donationsCategories);
    if (storedDonations != null) {
      categories = List<Map<String, dynamic>>.from(storedDonations)
          .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // Add the "All Categories" option
      filteredCategories = [
        Category(id: 0, name: 'All', status: CategoryStatus.active),
        ...categories,
      ];
      notifyListeners();
    }
    getCategories();
    notifyListeners();
  }

  Future<void> getCategories() async {
    setBusy(true);
    notifyListeners();
    try {
      ApiResponse res = await repo.getCategories();
      if (res.statusCode == 200) {
        if (res.data != null && res.data["categories"] != null) {
          // Extract categories from the response
          categories = (res.data["categories"] as List)
              .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          // Save the categories locally
          List<Map<String, dynamic>> storedCategories =
              categories.map((e) => e.toJson()).toList();
          locator<LocalStorage>()
              .save(LocalStorageDir.donationsCategories, storedCategories);

          // Apply any filtering logic if needed
          filteredCategories = [
            Category(id: 0, name: 'All', status: CategoryStatus.active),
            ...categories,
          ];
        }
        rebuildUi();
      }
    } catch (e) {
      print(e);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void addToRaffleCart(Product product) async {
    try {
      final existingIndex = cart.value.indexWhere(
            (raffleItem) => raffleItem.product?.id == product.id,
      );

      if (existingIndex != -1) {
        // Product already exists, create a new instance to avoid modifying the original reference
        final updatedItem = CartItem(
          product: cart.value[existingIndex].product,
          quantity: cart.value[existingIndex].quantity! + 1,
        );

        // Replace the existing item in the cart list
        cart.value[existingIndex] = updatedItem;
      } else {
        // Product does not exist, add a new one
        cart.value.add(CartItem(product: product, quantity: 1));
      }

      // Save to local storage
      List<Map<String, dynamic>> storedList =
      cart.value.map((e) => e.toJson()).toList();
      await locator<LocalStorage>().save(LocalStorageDir.raffleCart, storedList);

      // Save to online cart using API
      final response = await repo.addToCart({
        "productId": product.id,
        "quantity": cart.value.firstWhere((item) => item.product?.id == product.id).quantity,
      });

      if (response.statusCode == 200) {
        locator<SnackbarService>().showSnackbar(
            message: "Product added to cart", duration: Duration(seconds: 2));
      } else {
        locator<SnackbarService>().showSnackbar(
            message: response.data["message"], duration: Duration(seconds: 2));
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
          message: "Failed to add raffle to cart: $e",
          duration: Duration(seconds: 2));
    } finally {
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
          duration: Duration(seconds: 2));
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
          duration: Duration(seconds: 2));
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

  void onEnd() {
    print('onEnd');
    //TODO SEND USER NOTIFICATION OF AVAILABILITY OF PRODUCT
    notifyListeners();
  }
}
