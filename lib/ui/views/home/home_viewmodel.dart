
import 'package:easyph/app/app.bottomsheets.dart';
import 'package:easyph/app/app.dialogs.dart';
import 'package:easyph/app/app.locator.dart';
import 'package:easyph/ui/common/app_strings.dart';
import 'package:easyph/ui/views/cart/cart_view.dart';
import 'package:easyph/ui/views/dashboard/dashboard_view.dart';
import 'package:easyph/ui/views/home/widgets/update_card.dart';
import 'package:easyph/ui/views/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:update_available/update_available.dart';

import '../../../core/data/models/cart_item.dart';
import '../../../core/data/models/order_item.dart';
import '../../../core/data/repositories/repository.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/interceptors.dart';
import '../../../state.dart';
import '../service/service_view.dart';
import '../shop/shop_view.dart';

/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class HomeViewModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  List<Widget> pages = [
    DashboardView(),
    ShopView(),
    const CartView(),
    const ServicesView(),
    const ProfileView()
  ];

  int selectedTab = 0;
  double rating = 3.0;
  TextEditingController reviewController = TextEditingController();


  void changeSelected(int index) {
    selectedTab = index;
    rebuildUi();
  }

  Widget get currentPage {
    return pages[selectedTab];
  }

  void setRating(double newRating) {
    rating = newRating;
    notifyListeners();
  }

  void showBottomSheet() {
    _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title: ksHomeBottomSheetTitle,
      description: ksHomeBottomSheetDescription,
    );
  }

  Future<void> checkForUpdates(BuildContext context) async {
    final availability = await getUpdateAvailability();
    if (availability is UpdateAvailable) {
      showDialog(
        context: context,
        builder: (context) => const UpdateCardDialog(),
      );
    }
  }

  Future<void> reviewRating(Order order) async {
    setBusy(true);

    try {
      List<Map<String, dynamic>> reviews = order.products.map((product) => {
        "reviewText": reviewController.text,
        "rating": rating,
        "productId": product.id,
        "userId": profile.value.id
      }).toList();

      ApiResponse res = await repo.rating({
        "orderId": order.id,
        "reviews": reviews,
      });

      if (res.statusCode == 200) {
        print('Successfully submitted reviews for order: ${order.id}');
        // fetchDeliveredOrders();
      } else {
        print('Failed to submit reviews.');
      }


    } catch (e) {
      print('Error submitting reviews: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> fetchDeliveredOrders() async {
    setBusy(true);
    try {
      ApiResponse res = await locator<Repository>().getOrderList();
      if (res.statusCode == 200) {
        List<dynamic> ordersData = res.data["orders"] ?? [];
        List<Order> deliveredOrders = ordersData
            .map((order) =>
            Order.fromJson(Map<String, dynamic>.from(order)))
            .where((order) => order.status == "Delivered")
            .toList();

        List<Order> unratedOrders = deliveredOrders
            .where((order) => order.isReviewed == false)
            .toList();

        if (unratedOrders.isNotEmpty) {
          Order unratedOrder = unratedOrders.first;
          _dialogService.showCustomDialog(
            variant: DialogType.rating,
            title: "Rate Your Order",
            description: "Please rate your recently delivered order.",
            data: unratedOrder,
          );
        }
      }
    } catch (e) {
      locator<SnackbarService>()
          .showSnackbar(message: "Failed to load orders", duration: const Duration(seconds: 2));
    } finally {
      setBusy(false);
    }
  }

  Future<void> fetchOnlineCart() async {
    print('getting online cart');
    setBusy(true);
    try {
      ApiResponse res = await repo.cartList();
      if (res.statusCode == 200) {
        List<dynamic> items = res.data["cartItems"] ?? [];

        if (items.isNotEmpty) {
          List<CartItem> onlineItems = items
              .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          cart.value = onlineItems;
          // await locator<LocalStorage>().save(LocalStorageDir.raffleCart, onlineItems.map((e) => e.toJson()).toList());
          cart.notifyListeners();
          notifyListeners();
        } else {
          cart.value.clear();
          // await locator<LocalStorage>().delete(LocalStorageDir.raffleCart);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Couldn\'t get online cart: $e');
    } finally {
      setBusy(false);
    }
  }

}
