
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app/app.locator.dart';
import '../../app/app.logger.dart';
import '../../core/data/models/cart_item.dart';
import '../../core/data/models/favourite.dart';
import '../../core/data/models/order_item.dart';
import '../../core/data/models/product.dart';
import '../../core/data/repositories/repository.dart';
import '../../core/utils/local_store_dir.dart';
import '../../core/utils/local_stotage.dart';
import '../../core/utils/paystack_util.dart';
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

  List<FavoriteItem> _favorites = [];
  List<FavoriteItem> get favorites => _favorites;

  bool isProductFavorite(String productId) {
    return _favorites.any((f) => f.product.id == productId);
  }

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

  // Guards against a double-tap/double-swipe firing two removal requests
  // for the same item before the first one completes.
  final Set<String> _removingProductIds = {};

  CartViewModel() {
    cart.addListener(_onGlobalCartChanged);
  }

  void _onGlobalCartChanged() {
    _recomputeLocalTotals();
  }

  @override
  void dispose() {
    cart.removeListener(_onGlobalCartChanged);
    refferalCode.dispose();
    selectedPaymentMethod.dispose();
    isPaymentProcessing.dispose();
    super.dispose();
  }

  /// Pay-Now banner: initiates payment for the pending unpaid order.
  Future<void> payNowForOrder(BuildContext context, Order order) async {
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
          message: 'Payment initialization failed.',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _log.e('payNowForOrder error: $e');
      _snackBar.showSnackbar(
        message: 'An error occurred during payment.',
        duration: const Duration(seconds: 2),
      );
    }
  }

  void selectMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
    notifyListeners();
  }

  /// Removes an item from the cart. Local-only for guests; syncs server when logged in.
  Future<void> removeItem(CartItem item) async {
    final productId = item.product?.id;

    // Already removing this item — ignore the duplicate tap/swipe rather
    // than firing a second request.
    if (productId != null && _removingProductIds.contains(productId)) return;

    cart.value.removeWhere((i) => i.product?.id == item.product?.id);
    cart.notifyListeners();
    await _saveLocalCart();
    _recomputeLocalTotals();

    if (!userLoggedIn.value) {
      locator<SnackbarService>().showSnackbar(
          message: '${item.product?.productName} removed.',
          duration: const Duration(seconds: 1));
      return;
    }

    if (productId == null) return;
    _removingProductIds.add(productId);
    try {
      final res = await _repo.deleteFromCart(productId);
      if (res.statusCode == 200) {
        // The backend treats "already removed" as success too, so this
        // covers both a real deletion and a harmless duplicate/race.
        await getCartSummary();
        locator<SnackbarService>().showSnackbar(
            message: '${item.product?.productName} removed from cart.',
            duration: const Duration(seconds: 1));
      } else {
        // A genuine failure (auth/server error) — restore the item since
        // it's still in the backend cart.
        _snackBar.showSnackbar(
            message: 'Failed to remove item: ${res.data['message']}',
            duration: const Duration(seconds: 2));
        cart.value.add(item);
        cart.notifyListeners();
      }
    } catch (e) {
      _log.e('Error removing item: $e');
      cart.value.add(item);
      cart.notifyListeners();
    } finally {
      _removingProductIds.remove(productId);
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

  /// Refreshes the cart. For logged-in users: syncs any pending guest items
  /// then fetches from server. For guests: recomputes local totals only.
  Future<void> refreshData() async {
    if (!userLoggedIn.value) {
      _recomputeLocalTotals();
      return;
    }
    setBusy(true);
    await syncLocalCartToServer(); // no-op if no pending sync
    await fetchOnlineCart();
    setBusy(false);
  }

  /// Modifies the quantity of a cart item. Local-only for guests.
  Future<void> modifyCartQuantity(CartItem item, String action) async {
    if (item.product?.id == null) return;

    final localItem = cart.value.firstWhere(
      (i) => i.product?.id == item.product?.id,
      orElse: () => item,
    );
    if (action == 'increment') {
      localItem.quantity = (localItem.quantity ?? 0) + 1;
    } else if (action == 'decrement' && (localItem.quantity ?? 1) > 1) {
      localItem.quantity = (localItem.quantity ?? 1) - 1;
    }
    cart.notifyListeners();
    await _saveLocalCart();
    _recomputeLocalTotals();

    if (!userLoggedIn.value) return;

    setBusy(true);
    try {
      final res = await _repo.modifyCartItem(item.product!.id!, action);
      if (res.statusCode == 200) {
        await getCartSummary();
      } else {
        _snackBar.showSnackbar(
            message: 'Failed to update cart: ${res.data['message']}',
            duration: const Duration(seconds: 2));
      }
    } catch (e) {
      _log.e('Cart modification error: $e');
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

  /// Fetches the cart items and summary from the server. No-op for guests.
  Future<void> fetchOnlineCart() async {
    if (!userLoggedIn.value) {
      _recomputeLocalTotals();
      return;
    }
    setBusy(true);
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _repo.cartList();
      if (res.statusCode == 200) {
        final items = res.data['cartItems'] as List? ?? [];
        final parsed = items
            .map((i) => CartItem.fromJson(Map<String, dynamic>.from(i)))
            .toList();

        final Map<String, CartItem> uniqueMap = {};
        for (final item in parsed) {
          final pid = item.product?.id;
          if (pid == null) continue;
          if (uniqueMap.containsKey(pid)) {
            uniqueMap[pid]!.quantity = (uniqueMap[pid]!.quantity ?? 0) + (item.quantity ?? 1);
          } else {
            uniqueMap[pid] = item;
          }
        }

        for (final localItem in cart.value) {
          final pid = localItem.product?.id;
          if (pid != null && !uniqueMap.containsKey(pid)) {
            uniqueMap[pid] = localItem;
          }
        }

        cart.value = uniqueMap.values.toList();
        cart.notifyListeners();
        await getCartSummary();
        await _localStorage.save(
            LocalStorageDir.productCart,
            cart.value.map((e) => e.toJson()).toList());
      } else {
        _snackBar.showSnackbar(
            message: res.data['message'] ?? 'Failed to load cart.',
            duration: const Duration(seconds: 3));
      }
    } catch (e) {
      _log.e('Failed to load online cart: $e');
    } finally {
      _isLoading = false;
      setBusy(false);
    }
  }

  /// Updates local summary from server. Falls back to local computation for guests.
  Future<void> getCartSummary() async {
    if (!userLoggedIn.value) {
      _recomputeLocalTotals();
      return;
    }
    try {
      final res = await _repo.cartList();
      if (res.statusCode == 200) {
        final summary = res.data['summary'] ?? {};
        _cartSubtotal = summary['totalPrice'] ?? 0;
        _cartDiscount = summary['discountAmount'] ?? 0;
        _cartFinalTotal = summary['finalPrice'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      _log.e('Error fetching cart summary: $e');
    }
  }

  /// Pushes local guest cart items to the server if a sync is pending.
  /// Safe to call repeatedly — no-op when no sync is needed.
  Future<void> syncLocalCartToServer() async {
    if (!userLoggedIn.value || cart.value.isEmpty) return;
    final needsSync = await _localStorage.fetch(LocalStorageDir.cartNeedsSync) ?? false;
    if (needsSync != true) return;
    await _localStorage.save(LocalStorageDir.cartNeedsSync, false);
    try {
      for (final item in cart.value) {
        if (item.product?.id == null) continue;
        await _repo.addToCart({
          'productId': item.product!.id,
          'quantity': item.quantity ?? 1,
        });
      }
      await fetchOnlineCart();
    } catch (e) {
      _log.e('Cart sync error: $e');
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Future<void> _saveLocalCart() async {
    try {
      await _localStorage.save(
          LocalStorageDir.productCart,
          cart.value.map((e) => e.toJson()).toList());
    } catch (e) {
      _log.e('Failed to persist local cart: $e');
    }
  }

  void _recomputeLocalTotals() {
    int subtotal = 0;
    for (final item in cart.value) {
      final price = double.tryParse(item.product?.salePrice ?? '0') ?? 0.0;
      subtotal += (price * (item.quantity ?? 1)).toInt();
    }
    _cartSubtotal  = subtotal;
    _cartDiscount  = 0;
    _cartFinalTotal = subtotal;
    notifyListeners();
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