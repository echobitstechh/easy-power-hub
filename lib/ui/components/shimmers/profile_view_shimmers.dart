
import 'package:easy_ph/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfilePageShimmer extends StatelessWidget {
  const ProfilePageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[600]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Shimmer for Profile Picture
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
            ),
          ),
          verticalSpaceMedium,
          // Shimmer for Name
          Center(
            child: Container(
              height: 20,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          verticalSpaceLarge,
          // Shimmer for ListTiles
          _buildShimmerListTile(),
          _buildShimmerListTile(),
          _buildShimmerListTile(),
          _buildShimmerListTile(),
          _buildShimmerListTile(),
          _buildShimmerListTile(),
          verticalSpaceMedium,
          // Shimmer for Sign Out/Delete section
          _buildShimmerListTile(),
        ],
      ),
    );
  }

  Widget _buildShimmerListTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          horizontalSpaceSmall,
          Container(
            height: 20,
            width: 150,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}