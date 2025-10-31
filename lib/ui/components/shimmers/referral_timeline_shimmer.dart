import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ReferralTimelineShimmer extends StatelessWidget {
  const ReferralTimelineShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row shimmer
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildShimmerBox(height: 12, width: 60),
              ),
              Expanded(
                flex: 2,
                child: _buildShimmerBox(height: 12, width: 70),
              ),
              Expanded(
                flex: 1,
                child: _buildShimmerBox(height: 12, width: 50),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 70,
                child: _buildShimmerBox(height: 12, width: 50),
              ),
            ],
          ),
        ),
        // Data rows shimmer
        ...List.generate(3, (index) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildShimmerBox(height: 12, width: 80),
                ),
                Expanded(
                  flex: 2,
                  child: _buildShimmerBox(height: 12, width: 60),
                ),
                Expanded(
                  flex: 1,
                  child: _buildShimmerBox(height: 12, width: 40),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: _buildShimmerBox(height: 20, width: 60, borderRadius: 12),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildShimmerBox({
    required double height,
    required double width,
    double borderRadius = 4,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}