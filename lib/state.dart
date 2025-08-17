import 'package:easyph/core/data/models/app_notification.dart';
import 'package:flutter/material.dart';

import 'core/data/models/cart_item.dart';
import 'core/data/models/category.dart';
import 'core/data/models/profile.dart';

enum AppUiModes { dark, light }
enum PaymentMethod { wallet, paystack }


ValueNotifier<List<CartItem>> cart = ValueNotifier([]);
ValueNotifier<Profile> profile = ValueNotifier(Profile());
ValueNotifier<bool> userLoggedIn = ValueNotifier(false);
ValueNotifier<AppUiModes> uiMode = ValueNotifier(AppUiModes.light);
ValueNotifier<int> unreadCount = ValueNotifier(0);
ValueNotifier<bool> appLoading = ValueNotifier(false);
ValueNotifier<bool> isLoginByEmail = ValueNotifier(false);
ValueNotifier<bool> isOtpRequestedByEmail = ValueNotifier(false);
ValueNotifier<List<Category>> globalCategories = ValueNotifier([]);
