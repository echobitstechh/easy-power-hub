import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/data/models/category.dart';
import '../../state.dart';
import '../common/app_colors.dart';
import '../views/dashboard/dashboard_viewmodel.dart';

Widget buildCategoryChip(Category category, DashboardViewModel viewModel) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5.0),
    child: ChoiceChip(
      label: Text(
        category.name ?? '',
        style: GoogleFonts.redHatDisplay(
          textStyle: const TextStyle(),
        ),
      ),
      selected: category.id ==
          viewModel.selectedId, // Check if this category is selected
      onSelected: (bool selected) {
        // viewModel.setSelectedCategory(
        //     selected ? category.id : 0); // Update viewModel properly
        viewModel.notifyListeners(); // Notify the listeners to rebuild the UI
      },
      selectedColor: kcSecondaryColor,
      backgroundColor: uiMode.value == AppUiModes.dark
          ? Colors.grey[500]!
          : Colors.grey[100]!,
      labelStyle: TextStyle(
        color:
        category.id == viewModel.selectedId ? Colors.white : Colors.black,
      ),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: uiMode.value == AppUiModes.dark
              ? Colors.grey[500]!
              : Colors.grey[100]!, // Set the border color to light grey
          width: 1.0, // Set the border width
        ),
        borderRadius: BorderRadius.circular(
            30.0),
      ),
    ),
  );
}