
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app/app.locator.dart';
import '../../app/app.logger.dart';
import '../../core/data/models/cart_item.dart';
import '../../core/data/models/product.dart';
import '../../core/data/repositories/repository.dart';
import '../../core/utils/local_store_dir.dart';
import '../../core/utils/local_stotage.dart';
import '../../state.dart';

class CartViewModel extends BaseViewModel {
  final _repo = locator<Repository>();
  final _snackBar = locator<SnackbarService>();
  final _log = getLogger("CartViewModel");
  final _localStorage = locator<LocalStorage>();


  int _cartSubtotal = 0;
  int _cartDiscount = 0;
  int _cartFinalTotal = 0;
  bool _isLoading = false;
  bool _animationShown = false;

  bool shouldShowAnimation() {
    return !_animationShown;
  }

  void setAnimationShown() {
    _animationShown = true;
  }

  final refferalCode = TextEditingController();

  ValueNotifier<PaymentMethod> selectedPaymentMethod = ValueNotifier(PaymentMethod.paystack);
  ValueNotifier<bool> isPaymentProcessing = ValueNotifier(false);

  int get cartSubtotal => _cartSubtotal;
  int get cartDiscount => _cartDiscount;
  int get cartFinalTotal => _cartFinalTotal;
  bool get isLoading => _isLoading;
  PaymentMethod get selectedMethod => selectedPaymentMethod.value;
  /// A getter to check if the cart has any items.
  bool get hasItems => cart.value.isNotEmpty;

  final Map<String, int> selectedInstallments = {}; // productId -> selected frequency

  @override
  void dispose() {
    selectedPaymentMethod.dispose();
    refferalCode.dispose();
    super.dispose();
  }

  void selectMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
    notifyListeners();
  }

  /// Removes an item from the cart both locally and on the server.
  Future<void> removeItem(CartItem item) async {
    setBusy(true);
    try {
      if (item.product?.id == null) {
        _log.e("Attempted to remove item with null product ID.");
        return;
      }

      final res = await _repo.deleteFromCart(item.product!.id!);

      if (res.statusCode == 200) {
        // Use a more efficient `removeWhere` to ensure the correct item is removed
        cart.value.removeWhere((cartItem) => cartItem.product?.id == item.product?.id);
        cart.notifyListeners();
        await getCartSummary();
        _snackBar.showSnackbar(message: "Item removed successfully.", duration: Duration(seconds: 2));
      } else {
        _snackBar.showSnackbar(message: "Failed to remove item: ${res.data['message']}", duration: Duration(seconds: 2));
      }
    } catch (e) {
      _log.e("Error removing item: $e");
      _snackBar.showSnackbar(message: "An error occurred while removing the item.", duration: Duration(seconds: 2));
    } finally {
      setBusy(false);
    }
  }

  /// Adds or removes an item from the raffle cart.
  /// Note: The original logic seems to handle a temporary list. This can be integrated
  /// with a more robust state management approach if needed.
  // The original `addRemoveDeleteRaffle` method is commented out because it's tightly coupled
  // with a temporary list, which can be a source of bugs. Consider integrating this logic
  // directly into the main cart management flow if it's not a temporary state.
  //
  // void addRemoveDeleteRaffle(CartItem item) {
  //   if (itemsToDeleteRaffle.contains(item)) {
  //     itemsToDeleteRaffle.remove(item);
  //   } else {
  //     itemsToDeleteRaffle.add(item);
  //   }
  //   notifyListeners();
  // }

  /// Refreshes the cart data from the server.
  Future<void> refreshData() async {
    setBusy(true);
    await fetchOnlineCart();
    setBusy(false);
  }

  /// Modifies the quantity of a cart item and updates the server.
  Future<void> modifyCartQuantity(CartItem item, String action) async {
    if (item.product?.id == null) {
      _log.e("Attempted to modify quantity for item with null product ID.");
      return;
    }

    setBusy(true);
    try {
      final res = await _repo.modifyCartItem(item.product!.id!, action);
      if (res.statusCode == 200) {
        // Find the item in the local cart and update its quantity
        final localItem = cart.value.firstWhere(
              (cartItem) => cartItem.product?.id == item.product?.id,
          orElse: () => item, // Fallback to the provided item
        );

        if (action == "increment") {
          localItem.quantity = (localItem.quantity ?? 0) + 1;
        } else if (action == "decrement" && (localItem.quantity ?? 1) > 1) {
          localItem.quantity = (localItem.quantity ?? 1) - 1;
        }

        cart.notifyListeners();
        await getCartSummary(); // Get the updated summary from the server
      } else {
        _snackBar.showSnackbar(message: "Failed to update cart: ${res.data['message']}", duration: Duration(seconds: 2));
      }
    } catch (e) {
      _log.e("Cart modification error: $e");
      _snackBar.showSnackbar(message: "An error occurred while updating the cart.");
    } finally {
      setBusy(false);
    }
  }

  /// Adds a new product to the cart.
  Future<void> addNewItemToCart(Product product) async {
    setBusy(true);
    try {
      if (product.id == null) {
        _log.e("Attempted to add item with null product ID.");
        return;
      }

      final response = await _repo.addToCart({"productId": product.id!, "quantity": 1});

      if (response.statusCode == 200) {
        await refreshData();
        _snackBar.showSnackbar(
          message: "Added to cart",
          duration: const Duration(seconds: 2),
        );
      } else {
        _snackBar.showSnackbar(message: response.data["message"], duration: Duration(seconds: 2));
      }
    } catch (e) {
      _log.e("Failed to add item to cart: $e");
      _snackBar.showSnackbar(message: "Failed to add item to cart: $e", duration: Duration(seconds: 3));
    } finally {
      setBusy(false);
    }
  }

  /// Clears the entire cart both on the server and locally.
  Future<void> clearRaffleCart() async {
    setBusy(true);
    try {
      final res = await _repo.clearCart();
      if (res.statusCode == 200) {
        cart.value.clear();
        await _localStorage.delete(LocalStorageDir.productCart);
        cart.notifyListeners();
        _cartSubtotal = 0;
        _cartDiscount = 0;
        _cartFinalTotal = 0;
        notifyListeners();
      } else {
        _snackBar.showSnackbar(
          message: "Failed to clear cart: ${res.data['message']}", duration: Duration(seconds: 3)
        );
      }
    } catch (e) {
      _log.e("Error clearing the cart: $e");
      _snackBar.showSnackbar(
        message: "An error occurred while clearing the cart: $e", duration: Duration(seconds: 3)
      );
    } finally {
      setBusy(false);
    }
  }

  /// Calculates the local subtotal of the cart items.
  void getRaffleSubTotal() {
    int total = 0;
    for (var element in cart.value) {
      final product = element.product;
      final ticketPrice = product?.salePrice != null ? double.tryParse(product!.salePrice!) ?? 0.0 : 0.0;
      total += (ticketPrice * (element.quantity ?? 0)).toInt();
    }
    _cartSubtotal = total;
    notifyListeners();
  }

  /// Fetches the cart items and summary from the server.
  Future<void> fetchOnlineCart() async {
    setBusy(true);
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _repo.cartList();
      if (res.statusCode == 200) {
        List<dynamic> items = res.data["cartItems"] ?? [];
        cart.value = items.map((item) => CartItem.fromJson(Map<String, dynamic>.from(item))).toList();
        await getCartSummary();
        await _localStorage.save(LocalStorageDir.productCart, cart.value.map((e) => e.toJson()).toList());
      } else {
        _snackBar.showSnackbar(message: res.data["message"] ?? "Failed to load cart from server.",
            duration: Duration(seconds: 3));
      }
    } catch (e) {
      _log.e('Failed to load online cart: $e');
      _snackBar.showSnackbar(message: "Failed to load cart from server.", duration: Duration(seconds: 3));
    } finally {
      _isLoading = false;
      setBusy(false);
    }
  }

  /// Updates local summary variables from the server response.
  Future<void> getCartSummary() async {
    try {
      final res = await _repo.cartList();
      if (res.statusCode == 200) {
        final summary = res.data["summary"] ?? {};
        _cartSubtotal = summary["totalPrice"] ?? 0;
        _cartDiscount = summary["discountAmount"] ?? 0;
        _cartFinalTotal = summary["finalPrice"] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      _log.e("Error fetching cart summary: $e");
    }
  }

  /// Selects an installment option and updates the server.
  Future<void> selectInstallmentOption(CartItem item, int frequency) async {
    if (item.product?.id == null) {
      _log.e("Attempted to select installment for item with null product ID.");
      return;
    }

    setBusy(true);
    try {
      // Optimistic UI update
      selectedInstallments[item.product!.id!] = frequency;
      item.installmentFrequency = frequency;
      notifyListeners();

      final res = await _repo.modifyCartItem(
        item.product!.id!,
        "installment",
        newFrequency: frequency,
      );

      if (res.statusCode == 200) {
        // The server-side response confirms the update
        await getCartSummary();
        _snackBar.showSnackbar(message: "Installment option updated.", duration: Duration(seconds: 3));
      } else {
        // Rollback on failure
        selectedInstallments.remove(item.product!.id!);
        item.installmentFrequency = null;
        notifyListeners();
        _snackBar.showSnackbar(message: res.data["message"] ?? "Failed to update installment.", duration: Duration(seconds: 3));
      }
    } catch (e) {
      _log.e("Error updating installment: $e");
      _snackBar.showSnackbar(message: "An error occurred: $e", duration: Duration(seconds: 2));
    } finally {
      setBusy(false);
    }
  }
}