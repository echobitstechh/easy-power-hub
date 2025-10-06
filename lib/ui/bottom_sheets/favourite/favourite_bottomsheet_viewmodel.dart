
import 'package:easy_ph/app/app.locator.dart';
import 'package:easy_ph/core/data/models/favourite.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/data/models/cart_item.dart';
import '../../../core/data/models/product.dart';
import '../../../core/data/repositories/repository.dart';
import '../../../state.dart';

class FavoritesBottomSheetModel extends BaseViewModel {
  final _repo = locator<Repository>();
  final _snackBar = locator<SnackbarService>();

  List<FavoriteItem> _favorites = [];
  List<FavoriteItem> get favorites => _favorites;


  bool isProductFavorite(String productId) {
    return _favorites.any((f) => f.product.id == productId);
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
      if (res.statusCode == 200) {
        final favoritesData = res.data["data"] as List;
        _favorites = favoritesData.map((e) => FavoriteItem.fromJson(Map<String, dynamic>.from(e))).toList();
        print('favorites first price: ${_favorites.first.product.salePrice}');
      } else {
        _snackBar.showSnackbar(message: res.data["message"] ?? "Failed to fetch favorites.", duration: const Duration(seconds: 2));
      }
    } catch (e) {
      print('Error fetching favorites: $e');
      _snackBar.showSnackbar(message: "Error fetching favorites: $e", duration: const Duration(seconds: 2));
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> addToFavorites(String productId) async {
    await _repo.addToFavourites({"productId": productId});
    await fetchFavorites();
  }

  Future<void> removeFavorite(String favoriteId) async {
    await _repo.deleteFromFavourites(favoriteId);
    _favorites.removeWhere((f) => f.id == favoriteId);
    notifyListeners();
  }

  void addProductToCart(Product product) async {


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
      cart.notifyListeners();
      notifyListeners();
    }
  }
}