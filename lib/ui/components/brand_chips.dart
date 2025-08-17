import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../state.dart';
import '../common/app_colors.dart';
import '../views/dashboard/dashboard_viewmodel.dart';

Widget buildBrandChip(String brand, DashboardViewModel viewModel) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5.0),
    child: ChoiceChip(
      label: Text(
        brand ?? '',
        style: GoogleFonts.redHatDisplay(
          textStyle: const TextStyle(),
        ),
      ),
      selected: brand == viewModel.selectedBrand,
      onSelected: (bool selected) {
        viewModel.setSelectedBrand(selected ? brand : '');
      },
      selectedColor: kcSecondaryColor,
      backgroundColor: uiMode.value == AppUiModes.dark
          ? Colors.grey[500]!
          : Colors.grey[100]!,
      labelStyle: TextStyle(
        color: brand == viewModel.selectedBrand ? Colors.white : Colors.black,
      ),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: uiMode.value == AppUiModes.dark
              ? Colors.grey[500]!
              : Colors.grey[100]!,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(30.0),
      ),
    ),
  );
}