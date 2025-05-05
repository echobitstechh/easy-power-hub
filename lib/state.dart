import 'package:easyph/core/data/models/app_notification.dart';
import 'package:easyph/core/data/models/raffle_cart_item.dart';
import 'package:flutter/material.dart';

import 'core/data/models/cart_item.dart';
import 'core/data/models/category.dart';
import 'core/data/models/product.dart';
import 'core/data/models/profile.dart';

enum AppUiModes { dark, light }
enum AppModules { raffle, shop }
enum PaymentMethod { wallet, paystack, flutterwave, applePay }


ValueNotifier<List<CartItem>> cart = ValueNotifier([]);
ValueNotifier<Profile> profile = ValueNotifier(Profile());
ValueNotifier<bool> userLoggedIn = ValueNotifier(false);
ValueNotifier<bool> isFirstLaunch = ValueNotifier(true);
ValueNotifier<AppUiModes> uiMode = ValueNotifier(AppUiModes.light);
ValueNotifier<List<AppNotification>> notifications = ValueNotifier([]);
ValueNotifier<int> unreadCount = ValueNotifier(0);
ValueNotifier<AppModules> currentModuleNotifier = ValueNotifier(AppModules.raffle);
ValueNotifier<bool> appLoading = ValueNotifier(false);
ValueNotifier<bool> isLoginByEmail = ValueNotifier(false);
ValueNotifier<bool> isOtpRequestedByEmail = ValueNotifier(false);
ValueNotifier<List<Category>> globalCategories = ValueNotifier([]);



void switchModule(AppModules module) {
  currentModuleNotifier.value = module;
}
