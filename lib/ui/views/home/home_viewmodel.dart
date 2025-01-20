import 'dart:io';

import 'package:afriprize/app/app.bottomsheets.dart';
import 'package:afriprize/app/app.dialogs.dart';
import 'package:afriprize/app/app.locator.dart';
import 'package:afriprize/app/app.router.dart';
import 'package:afriprize/core/utils/config.dart';
import 'package:afriprize/ui/common/app_colors.dart';
import 'package:afriprize/ui/common/app_strings.dart';
import 'package:afriprize/ui/components/submit_button.dart';
import 'package:afriprize/ui/views/cart/cart_view.dart';
import 'package:afriprize/ui/views/dashboard/dashboard_view.dart';
import 'package:afriprize/ui/views/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:update_available/update_available.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/data/models/cart_item.dart';
import '../../../core/data/models/raffle_cart_item.dart';
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
                  title: Text('App Updates', style: TextStyle(fontSize: 22,
                    fontFamily: "Panchang", fontWeight: FontWeight.bold, color: kcSecondaryColor)),
                  subtitle: Text('A new version of Easy PH is now available.'
                      ' download now to enjoy our lastest features.', style: TextStyle(fontSize: 13,
                    fontFamily: "Panchang",)),
                ),
                ButtonBar(
                  children: <Widget>[
                    TextButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kcSecondaryColor)),
                      onPressed: () {
                        Platform.isIOS ? _launchURL(AppConfig.APPLESTOREURL) : _launchURL(AppConfig.GOOGLESTOREURL);
                        Navigator.pop(context);
                      },
                      child: const Text('Update Now', style: TextStyle(
                          fontFamily: "Panchang", fontWeight: FontWeight.bold, color: kcWhiteColor)),
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

  Future<void> fetchOnlineCart() async {
    setBusy(true);
    try {
      ApiResponse res = await repo.cartList();
      if (res.statusCode == 200) {
        // Corrected the key to "cartItems" and added a null check
        List<dynamic> items = res.data["cartItems"] ?? [];

        print('online cart items: $items');

        // Map the items list to List<CartItem>
        if(items.isNotEmpty){
          List<CartItem> onlineItems = items
              .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
              .toList();

          print('Saved items are: ${onlineItems.first.product?.productName}');

          // Sync online items with the local cart
          cart.value = onlineItems;
          notifyListeners();
          print('Saved raffle cart are: ${cart.value.first.product?.productName}');

          // Update local storage
          List<Map<String, dynamic>> storedList =
          cart.value.map((e) => e.toJson()).toList();
          await locator<LocalStorage>().save(LocalStorageDir.raffleCart, storedList);
        }else{
          cart.value.clear();
          await locator<LocalStorage>().delete(LocalStorageDir.raffleCart);

          notifyListeners();}
      }
    } catch (e) {
      // locator<SnackbarService>().showSnackbar(message: "Failed to load cart from server: $e");
      print('Couldn\'t get online cart: $e');
    } finally {
      setBusy(false);
    }
  }

}
