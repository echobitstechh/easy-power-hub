import 'package:flutter/material.dart';

import 'core/data/models/cart_item.dart';
import 'core/data/models/category.dart';
import 'core/data/models/order_item.dart';
import 'core/data/models/profile.dart';
import 'features/startup/domain/entities/user.dart';

enum AppUiModes { dark, light }
enum PaymentMethod { wallet, paystack }


ValueNotifier<List<CartItem>> cart = ValueNotifier([]);
ValueNotifier<Profile> profile = ValueNotifier(Profile());
ValueNotifier<bool> userLoggedIn = ValueNotifier(false);
ValueNotifier<bool> isFirstLaunch = ValueNotifier(true);
ValueNotifier<AppUiModes> uiMode = ValueNotifier(AppUiModes.light);
ValueNotifier<int> unreadCount = ValueNotifier(0);
ValueNotifier<bool> appLoading = ValueNotifier(false);
ValueNotifier<bool> isLoginByEmail = ValueNotifier(false);
ValueNotifier<bool> isOtpRequestedByEmail = ValueNotifier(false);
ValueNotifier<List<Category>> globalCategories = ValueNotifier([]);

/// Pay-Now banner: the pending unpaid InstantPayment order (null if none).
ValueNotifier<Order?> payNowOrder = ValueNotifier(null);

/// ID of the order the user dismissed the banner for.
ValueNotifier<String?> dismissedPayNowId = ValueNotifier(null);