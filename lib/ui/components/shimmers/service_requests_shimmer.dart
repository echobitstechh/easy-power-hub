import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ServiceRequestsShimmer extends StatelessWidget {
  final int itemCount;

  const ServiceRequestsShimmer({
    super.key,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    );
  }
}