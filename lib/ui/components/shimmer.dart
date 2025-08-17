import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../state.dart';
import '../common/app_colors.dart';

Widget buildShimmerServiceItem(BuildContext context) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[900]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[900]! : Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              color: isDarkMode ? Colors.grey[900] : Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 14,
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildShimmerContainer() {
  return Shimmer.fromColors(
    baseColor: uiMode.value == AppUiModes.dark
        ? Colors.grey[700]!
        : Colors.grey[300]!,
    highlightColor: uiMode.value == AppUiModes.dark
        ? Colors.grey[300]!
        : Colors.grey[100]!,
    child: Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: kcSecondaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}

Widget buildShimmerQuickActions() {
  return Shimmer.fromColors(
    baseColor: uiMode.value == AppUiModes.dark
        ? Colors.grey[700]!
        : Colors.grey[300]!,
    highlightColor: uiMode.value == AppUiModes.dark
        ? Colors.grey[300]!
        : Colors.grey[100]!,
    child: Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

Widget buildShimmerSlider() {
  return Shimmer.fromColors(
    baseColor: uiMode.value == AppUiModes.dark
        ? Colors.grey[700]!
        : Colors.grey[300]!,
    highlightColor: uiMode.value == AppUiModes.dark
        ? Colors.grey[300]!
        : Colors.grey[100]!,
    child: Container(
      height: 300, // Adjust the height as per your design
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
