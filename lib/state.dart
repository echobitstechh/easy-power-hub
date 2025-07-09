import 'package:flutter/material.dart';

import 'features/startup/domain/entities/user.dart';

enum AppUiModes { dark, light }


ValueNotifier<User> profile = ValueNotifier(const User());
ValueNotifier<bool> userLoggedIn = ValueNotifier(false);
ValueNotifier<bool> isFirstLaunch = ValueNotifier(true);
ValueNotifier<AppUiModes> uiMode = ValueNotifier(AppUiModes.light);