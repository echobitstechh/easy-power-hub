import 'dart:convert';

import 'package:afriprize/app/app.locator.dart';
import 'package:afriprize/app/app.logger.dart';
import 'package:afriprize/core/data/models/cart_item.dart';
import 'package:afriprize/core/data/models/product.dart';
import 'package:afriprize/core/data/models/raffle_cart_item.dart';
import 'package:afriprize/core/data/repositories/repository.dart';
import 'package:afriprize/core/network/api_response.dart';
import 'package:afriprize/core/utils/local_store_dir.dart';
import 'package:afriprize/core/utils/local_stotage.dart';
import 'package:afriprize/state.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:video_player/video_player.dart';

import '../../../core/data/models/app_notification.dart';
import '../../../core/data/models/category.dart';
import '../../../core/data/models/profile.dart';
import '../../../core/data/models/project.dart';

class ShopViewModel extends BaseViewModel {
  final repo = locator<Repository>();
  final bool _isDataLoaded = false;
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

  static const int allCategoriesId = 0;

  int selectedId = allCategoriesId;

  bool? onboarded;

  bool showDialog = true;  // Controls when to show the modal
  bool modalShown = false; // Flag to track if the modal was shown
  bool appBarLoading = false;
  bool shouldShowShowcase = true;  // Controls when to show showcase

  final snackBar = locator<SnackbarService>();

  @override
  void initialise() {
    init();
  }


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

  bool showcaseShown = false; // Track whether the showcase has been shown
  void setShowcaseShown(bool value) {
    showcaseShown = value;
    notifyListeners();
  }

  bool isNewProduct(String createdAt) {
    final productDate = DateTime.parse(createdAt);
    final currentDate = DateTime.now();
    final difference = currentDate.difference(productDate).inDays;
    return difference <= 14;  // 14 days = 2 weeks
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


  Future<void> init() async {
    setBusy(true);
    print("loading the initials" );
    notifyListeners();
    await loadProduct();
    await loadCategories();
    if (userLoggedIn.value == true) {
      initCart();
      // await getNotifications();
      // await getProfile();
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
        log.i("Loaded decoded jsonProducts from storage: ${jsonDecode(storedJsonProduct)}");
        List<dynamic> storedProducts = jsonDecode(storedJsonProduct);
        log.i("Loaded Products from storage: $storedProducts");
        // Populate productList and filteredProductList
        productList = storedProducts
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        filteredProductList = productList;

        // Immediately notify UI to display data
        notifyListeners();
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

  void getResourceList(){
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

        log.i("Updated Products from API saved to storage.");

        // Notify UI about updated data
        notifyListeners();
      } else {
        log.e("API Error: ${res.data["message"]}");
      }
    } catch (e) {
      log.e("Error fetching products: $e");
    }
  }

  Future<void> loadCategories() async {
    dynamic storedCategories = await locator<LocalStorage>().fetch(LocalStorageDir.donationsCategories);
    if (storedCategories != null) {
      categories = List<Map<String, dynamic>>.from(storedCategories)
          .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      print('There are categories: ${categories.map((element) => element.name).join(', ')}');

      // Add the "All Categories" option
      filteredCategories = [
        Category(id: 0, name: 'All', status: CategoryStatus.active),
        ...categories,
      ];
      notifyListeners();
    }
    await getCategories();
    notifyListeners();
  }



  Future<void> getCategories() async {
    setBusy(true);
    notifyListeners();
    try {
      ApiResponse res = await repo.getCategories();
      if (res.statusCode == 200) {
        if (res.data != null && res.data["categories"] != null) {

          categories = (res.data["categories"] as List)
              .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          // Save the categories locally
          List<Map<String, dynamic>> storedCategories = categories.map((e) => e.toJson()).toList();
          locator<LocalStorage>().save(LocalStorageDir.donationsCategories, storedCategories);

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





  void addToRaffleCart(Product raffle) async {
    // setBusy(true);
    // notifyListeners();
    try {
      final existingItem = cart.value.firstWhere(
            (raffleItem) => raffleItem.product?.id == raffle.id,
        orElse: () => CartItem(product: raffle, quantity: 0),
      );

      if (existingItem.quantity != null && existingItem.quantity! > 0 && existingItem.product != null) {
        existingItem.quantity = (existingItem.quantity! + 1);
      } else {
        existingItem.quantity = 1;
        cart.value.add(existingItem);
      }

      // Save to local storage
      List<Map<String, dynamic>> storedList = cart.value.map((e) => e.toJson()).toList();
      await locator<LocalStorage>().save(LocalStorageDir.raffleCart, storedList);

      // Save to online cart using API
      // final response = await repo.addToCart({
      //   "raffle": raffle.id,
      //   "quantity": existingItem.quantity,
      // });

      // if (response.statusCode == 201) {
      //   locator<SnackbarService>().showSnackbar(message: "Raffle added to cart", duration: Duration(seconds: 2));
      // } else {
      //   locator<SnackbarService>().showSnackbar(message: response.data["message"], duration: Duration(seconds: 2));
      // }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(message: "Failed to add raffle to cart: $e", duration: Duration(seconds: 2));
      log.e(e);
    } finally {
      setBusy(false);
      cart.notifyListeners();
    }
  }
  
  void initCart() async {
    dynamic raffle = await locator<LocalStorage>().fetch(LocalStorageDir.cart);
    dynamic store = await locator<LocalStorage>().fetch(LocalStorageDir.cart);
    List<CartItem> localRaffleCart = List<Map<String, dynamic>>.from(raffle)
        .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    cart.value = localRaffleCart;
    cart.notifyListeners();
  }
  
  Future<void> decreaseRaffleQuantity(RaffleCartItem item) async {
    setBusy(true);
    try {
      if (item.quantity! > 1) {
        item.quantity = item.quantity! - 1;

        // Update online cart
        await repo.addToCart({
          "raffle": item.raffle?.id,
          "quantity": item.quantity,
        });
      } else if (item.quantity! == 1) {
        // Remove from local cart
        cart.value.removeWhere((cartItem) => cartItem.product?.id == item.raffle?.id);

        // Remove from online cart
        await repo.deleteFromCart(item.raffle!.id!);
      }

      // Save to local storage
      List<Map<String, dynamic>> storedList = cart.value.map((e) => e.toJson()).toList();
      await locator<LocalStorage>().save(LocalStorageDir.raffleCart, storedList);
    } catch (e) {
      locator<SnackbarService>().showSnackbar(message: "Failed to decrease raffle quantity: $e", duration: Duration(seconds: 2));
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
      locator<SnackbarService>().showSnackbar(message: "Failed to increase raffle quantity: $e", duration: Duration(seconds: 2));
      log.e(e);
    } finally {
      setBusy(false);
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
