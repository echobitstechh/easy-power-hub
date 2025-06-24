import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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