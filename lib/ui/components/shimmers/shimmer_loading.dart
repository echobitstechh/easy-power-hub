
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../common/ui_helpers.dart';

/// A set of reusable shimmer loading widgets for different UI elements.
class ShimmerLoading extends StatelessWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
      child: child,
    );
  }
}

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerLoading(
      child: Column(
        children: [
          _ShimmerContainer(height: 200, borderRadius: 15),
          verticalSpaceSmall,
          _ShimmerQuickActionsGrid(),
          verticalSpaceMedium,
          _ShimmerQuickActionsGrid(),
          verticalSpaceMedium,
          _ShimmerSlider(),
          verticalSpaceMedium,
          _ShimmerSlider(),
        ],
      ),
    );
  }
}

/// Shimmer effect for a generic container.
class _ShimmerContainer extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const _ShimmerContainer({
    required this.height,
    this.width,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer effect for the quick action grid items.
class _ShimmerQuickActionsGrid extends StatelessWidget {
  const _ShimmerQuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2,
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
        4,
            (index) => const _ShimmerContainer(height: 60),
      ),
    );
  }
}

/// Shimmer effect for the horizontal sliders.
class _ShimmerSlider extends StatelessWidget {
  const _ShimmerSlider();

  @override
  Widget build(BuildContext context) {
    return _ShimmerContainer(
      height: MediaQuery.of(context).size.height * 0.2,
      borderRadius: 15,
    );
  }
}