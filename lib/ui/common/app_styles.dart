import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state.dart';
import 'app_colors.dart'; // Assuming your colors are defined here

/// A file to centralize all application-wide styling constants.
///
/// This includes text styles, font sizes, and consistent spacing values.
class AppStyles {
  // --- Font Styles ---
  static final TextStyle headline1 = GoogleFonts.bricolageGrotesque(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: kcBlackColor,
  );

  static final TextStyle headline2 = GoogleFonts.bricolageGrotesque(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: kcBlackColor,
  );

  static final TextStyle subtitle1 = GoogleFonts.redHatDisplay(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: kcBlackColor,
  );

  static final TextStyle subtitle2 = GoogleFonts.redHatDisplay(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: kcBlackColor,
  );

  static final TextStyle bodyText1 = GoogleFonts.roboto(
    fontSize: 16,
    color: kcBlackColor,
  );

  static final TextStyle bodyText2 = GoogleFonts.roboto(
    fontSize: 14,
    color: kcBlackColor,
  );

  // --- Theme-Adaptive Styles ---
  static TextStyle get textStyleHeadline1 {
    return GoogleFonts.bricolageGrotesque(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: _adaptiveColor,
    );
  }

  static TextStyle get textStyleSubtitle2 {
    return GoogleFonts.redHatDisplay(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: _adaptiveColor,
    );
  }

  static TextStyle get textStyleButton {
    return GoogleFonts.redHatDisplay(
      textStyle: const TextStyle(
        fontSize: 12,
        color: kcBlackColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static Color get _adaptiveColor {
    return uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor;
  }
}