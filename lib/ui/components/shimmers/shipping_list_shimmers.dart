import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShippingListShimmer extends StatelessWidget {
  const ShippingListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(3, (index) { // Generate a few placeholder items
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
            ),
            title: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: double.infinity,
                height: 10.0,
                color: Colors.white,
              ),
            ),
            subtitle: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 150.0,
                height: 8.0,
                color: Colors.white,
              ),
            ),
            trailing: Container(
              width: 20.0,
              height: 20.0,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }
}