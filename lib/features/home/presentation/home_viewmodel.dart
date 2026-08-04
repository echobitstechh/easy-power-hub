import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app.bottomsheets.dart';
import '../../../app/app.dialogs.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../core/data/models/cart_item.dart';
import '../../../core/data/models/order_item.dart';
import '../../../core/data/repositories/repository.dart';
import '../../../core/utils/paystack_util.dart';
import '../../../state.dart';
import '../../../ui/common/app_strings.dart';
import '../../Profile/profile_view.dart';
import '../../cart/cart_view.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../dashboard/presentation/dashboad_view.dart';
import '../../services/service_view.dart';
import '../../shop/shop_view.dart';

class HomeViewModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _snackbarService = locator<SnackbarService>();
  final _repo = locator<Repository>();
  final _localStorage = locator<LocalStorage>();
  final _log = getLogger('HomeViewModel');

  final TextEditingController reviewController = TextEditingController();

  int selectedTab = 0;
  double rating = 3.0;

  final List<Widget> _pages = [
    DashboardView(),
    ShopView(),
    CartView(),
    ServicesView(),
    ProfileView(),
  ];

  void init() async {
    try {
      final savedTab = await _localStorage.fetch(LocalStorageDir.lastTabRoute);
      if (savedTab is int && savedTab >= 0 && savedTab < _pages.length) {
        selectedTab = savedTab;
        activeHomeTab.value = savedTab;
      }
    } catch (e) {
      _log.e('Failed to restore tab: $e');
    }
    activeHomeTab.addListener(_onActiveTabChanged);
    notifyListeners();
  }

  void _onActiveTabChanged() {
    if (selectedTab != activeHomeTab.value) {
      changeSelected(activeHomeTab.value);
    }
  }

  @override
  void dispose() {
    activeHomeTab.removeListener(_onActiveTabChanged);
    reviewController.dispose();
    super.dispose();
  }

  /// --- Navigation ---
  void changeSelected(int index) async {
    selectedTab = index;
    if (activeHomeTab.value != index) {
      activeHomeTab.value = index;
    }
    notifyListeners();
    try {
      await _localStorage.save(LocalStorageDir.lastTabRoute, index);
    } catch (e) {
      _log.e('Failed to save tab: $e');
    }
  }
  void setRating(double newRating) {
    rating = newRating;
    notifyListeners();
  }


  Widget get currentPage => _pages[selectedTab];


  /// --- Pay Now (floating banner) ---
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
        payNowOrder.value = candidates.isNotEmpty ? candidates.first : null;
      }
    } catch (e) {
      _log.e('fetchPayNowOrder error: $e');
    }
  }

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
        _snackbarService.showSnackbar(
          message: 'Payment initialization failed.',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _log.e('payNowForOrder error: $e');
      _snackbarService.showSnackbar(
        message: 'An error occurred during payment.',
        duration: const Duration(seconds: 2),
      );
    }
  }


  /// --- Rating ---
  Future<void> reviewRating(Order order) async {
    setBusy(true);
    try {
      final reviews = order.products.map((product) {
        return {
          "reviewText": reviewController.text.trim(),
          "rating": rating,
          "productId": product.id,
          "userId": profile.value.id,
        };
      }).toList();

      final res = await _repo.rating({"orderId": order.id, "reviews": reviews});

      if (res.statusCode == 200) {
        _snackbarService.showSnackbar(message: "Review submitted successfully", duration: Duration(seconds: 3));
      } else {
        _snackbarService.showSnackbar(message: "Failed to submit review", duration: Duration(seconds: 3));
      }
    } catch (e) {
      _snackbarService.showSnackbar(message: "Error submitting review", duration: Duration(seconds: 3));
    } finally {
      setBusy(false);
    }
  }

  Future<void> fetchDeliveredOrders() async {
    setBusy(true);
    try {
      final res = await _repo.getOrderList();
      if (res.statusCode == 200) {
        final ordersData = res.data["orders"] as List<dynamic>? ?? [];
        final deliveredOrders = ordersData
            .map((o) => Order.fromJson(Map<String, dynamic>.from(o)))
            .where((o) => o.status == "Delivered" && !o.isReviewed)
            .toList();

        if (deliveredOrders.isNotEmpty) {
          final unratedOrder = deliveredOrders.first;
          _dialogService.showCustomDialog(
            variant: DialogType.rating,
            title: "Rate Your Order",
            description: "Please rate your recently delivered order.",
            data: unratedOrder,
          );
        }
      }
    } catch (e) {
      _snackbarService.showSnackbar(message: "Failed to load orders", duration: Duration(seconds: 2));
    } finally {
      setBusy(false);
    }
  }

  /// --- Cart ---
  Future<void> fetchOnlineCart() async {
    setBusy(true);
    try {
      final res = await _repo.cartList();
      if (res.statusCode == 200) {
        final items = res.data["cartItems"] as List<dynamic>? ?? [];
        final parsed = items
            .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
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
        notifyListeners();
      }
    } catch (e) {
      _snackbarService.showSnackbar(message: "Could not fetch cart", duration: Duration(seconds: 2));
    } finally {
      setBusy(false);
    }
  }
}
