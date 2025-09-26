
import 'package:flutter/material.dart';

import 'app_colors.dart';

final ThemeData easyPhLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kcPrimaryColor,
  scaffoldBackgroundColor: kcWhiteColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: kcWhiteColor,
    foregroundColor: kcBlackColor,
  ),
  cardColor: kcWhiteColor,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: kcBlackColor),
    bodyMedium: TextStyle(color: kcBlackColor),
  ),
);

final ThemeData easyPhDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kcPrimaryColor,
  scaffoldBackgroundColor: kcDarkGreyColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: kcDarkGreyColor,
    foregroundColor: kcWhiteColor,
  ),
  cardColor: kcDarkGreyColor,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: kcWhiteColor),
    bodyMedium: TextStyle(color: kcWhiteColor),
  ),
);