
import 'package:flutter/material.dart';

import 'app_colors.dart';

final ThemeData easyPhLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kcPrimaryColor,
  colorScheme: const ColorScheme.light(
    primary: kcPrimaryColor,
    secondary: kcSecondaryColor,
    surface: Color(0xFFF5F7FF),
  ),
  scaffoldBackgroundColor: const Color(0xFFF0F2FA),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: kcBlackColor,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardColor: kcGlassSurfaceLight,
  fontFamily: 'HostGrotesk',
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: kcBlackColor, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(color: kcBlackColor, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(color: kcBlackColor, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(color: kcBlackColor, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: kcBlackColor),
    bodyMedium: TextStyle(color: kcMediumGrey),
    bodySmall: TextStyle(color: kcMediumGrey),
  ),
);

final ThemeData easyPhDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kcPrimaryColor,
  colorScheme: const ColorScheme.dark(
    primary: kcPrimaryColor,
    secondary: kcSecondaryColor,
    surface: Color(0xFF161B2E),
  ),
  scaffoldBackgroundColor: const Color(0xFF0D1117),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: kcWhiteColor,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardColor: kcGlassSurfaceDark,
  fontFamily: 'HostGrotesk',
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: kcWhiteColor, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(color: kcWhiteColor, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(color: kcWhiteColor, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(color: kcWhiteColor, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: kcWhiteColor),
    bodyMedium: TextStyle(color: kcLightGrey),
    bodySmall: TextStyle(color: kcLightGrey),
  ),
);