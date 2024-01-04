import 'package:afriprize/core/data/models/app_notification.dart';
import 'package:flutter/material.dart';

import 'core/data/models/cart_item.dart';
import 'core/data/models/profile.dart';

enum AppUiModes { dark, light }

ValueNotifier<List<CartItem>> cart = ValueNotifier([]);
ValueNotifier<Profile> profile = ValueNotifier(Profile());
ValueNotifier<bool> userLoggedIn = ValueNotifier(false);
ValueNotifier<bool> isFirstLaunch = ValueNotifier(true);
ValueNotifier<AppUiModes> uiMode = ValueNotifier(AppUiModes.light);
ValueNotifier<List<AppNotification>> notifications = ValueNotifier([]);
