import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CheckoutPageShimmer extends StatelessWidget {
  const CheckoutPageShimmer({super.key});

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
          // Shimmer for Order Summary
          _buildShimmerCard(height: 120),
          _buildShimmerDivider(),
          // Shimmer for Shipping Details
          _buildShimmerCard(height: 150),
          _buildShimmerDivider(),
          // Shimmer for Billing Summary
          _buildShimmerCard(height: 150),
          _buildShimmerDivider(),
          // Shimmer for Delivery Method
          _buildShimmerCard(height: 120),
          _buildShimmerDivider(),
          // Shimmer for Payment Options
          _buildShimmerCard(height: 120),
        ],
      ),
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildShimmerDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
    );
  }
}