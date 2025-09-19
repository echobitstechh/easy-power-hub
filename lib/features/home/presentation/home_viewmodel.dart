import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app.bottomsheets.dart';
import '../../../app/app.dialogs.dart';
import '../../../app/app.locator.dart';
import '../../../core/data/models/cart_item.dart';
import '../../../core/data/models/order_item.dart';
import '../../../core/data/repositories/repository.dart';
import '../../../state.dart';
import '../../../ui/common/app_strings.dart';
import '../../dashboard/presentation/dashboad_view.dart';
import '../../shop/shop_view.dart';

class HomeViewModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _snackbarService = locator<SnackbarService>();
  final _repo = locator<Repository>();

  final TextEditingController reviewController = TextEditingController();

  int selectedTab = 0;
  double rating = 3.0;

  final List<Widget> _pages = [
    DashboardView(),
    ShopView(),
    // CartView(),
    // ServicesView(),
    // ProfileView(),
  ];


  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  /// --- Navigation ---
  void changeSelected(int index) {
    selectedTab = index;
    notifyListeners();
  }
  void setRating(double newRating) {
    rating = newRating;
    notifyListeners();
  }


  Widget get currentPage => _pages[selectedTab];


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
        _snackbarService.showSnackbar(message: "Review submitted successfully");
      } else {
        _snackbarService.showSnackbar(message: "Failed to submit review");
      }
    } catch (e) {
      _snackbarService.showSnackbar(message: "Error submitting review");
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
      _snackbarService.showSnackbar(message: "Failed to load orders");
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
        cart.value = items
            .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        cart.notifyListeners();
        notifyListeners();
      }
    } catch (e) {
      _snackbarService.showSnackbar(message: "Could not fetch cart");
    } finally {
      setBusy(false);
    }
  }
}
