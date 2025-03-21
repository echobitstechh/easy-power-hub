import 'dart:io';

import 'package:easyph/app/app.bottomsheets.dart';
import 'package:easyph/app/app.dialogs.dart';
import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.router.dart';
import 'package:easyph/core/utils/config.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/app_strings.dart';
import 'package:easyph/ui/components/submit_button.dart';
import 'package:easyph/ui/views/cart/cart_view.dart';
import 'package:easyph/ui/views/dashboard/dashboard_view.dart';
import 'package:easyph/ui/views/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:update_available/update_available.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/data/models/cart_item.dart';
import '../../../core/data/models/order_item.dart';
import '../../../core/data/models/raffle_cart_item.dart';
import '../../../core/data/repositories/repository.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/interceptors.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../state.dart';
import '../draws/draws_view.dart';
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
    ServicesView(),
    const ProfileView()
  ];

  int selectedTab = 0;
  double rating = 3.0;
  TextEditingController reviewController = TextEditingController();


  @override
  void dispose() {
    // Don't forget to remove the listener when the view model is disposed.
    currentModuleNotifier.removeListener(notifyListeners);
    super.dispose();
  }

  HomeViewModel() {
    currentModuleNotifier.addListener(notifyListeners);
  }

  String get counterLabel => 'Counter is: $_counter';

  int _counter = 0;

  //for test
  void incrementCounter() {
    _counter++;
    rebuildUi();
  }

  void changeSelected(int index, AppModules module) {
    selectedTab = index;
    notifyListeners();
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
      showUpdateCard(context);
    }
  }

  void showUpdateCard(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  'assets/icons/update.svg',
                  height: 94,
                ),
                const ListTile(
                  title: Text(
                    'App Updates',
                    style: TextStyle(
                        fontSize: 22,
                        fontFamily: "Panchang",
                        fontWeight: FontWeight.bold,
                        color: kcSecondaryColor),
                  ),
                  subtitle: Text(
                    'A new version of Easy PH is now available. download now to enjoy our lastest features.',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: "Panchang",
                    ),
                  ),
                ),
                ButtonBar(
                  children: <Widget>[
                    TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(kcSecondaryColor)),
                      onPressed: () {
                        Platform.isIOS
                            ? _launchURL(AppConfig.APPLESTOREURL)
                            : _launchURL(AppConfig.GOOGLESTOREURL);
                        Navigator.pop(context);
                      },
                      child: const Text('Update Now',
                          style: TextStyle(
                              fontFamily: "Panchang",
                              fontWeight: FontWeight.bold,
                              color: kcWhiteColor)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> reviewRating(Order order) async {
    setBusy(true);
    try {
      for (var product in order.products) {
        ApiResponse res = await repo.rating({
          "reviewText": reviewController.text,
          "rating": rating,
          "productId": product.id,
        });

        if (res.statusCode == 200) {
          print('Successfully submitted review for product: ${product.productName}');
        } else {
          print('Failed to submit review for product: ${product.productName}');
        }
      }

      // Handle local cart updates if needed

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
            variant: DialogType.ratingDialog,
            title: "Rate Your Order",
            description: "Please rate your recently delivered order.",
            data: unratedOrder,
          );
        }
      }
    } catch (e) {
      locator<SnackbarService>()
          .showSnackbar(message: "Failed to load orders", duration: Duration(seconds: 2));
      print("Failed to load orders: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> submitReview() async {
    // Make API call here
    print("Submitting review: Rating - $rating, Review - ${reviewController.text}");
  }
}
