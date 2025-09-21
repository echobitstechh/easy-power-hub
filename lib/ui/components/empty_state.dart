import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../common/ui_helpers.dart';

class EmptyState extends StatelessWidget {
  final String animation;
  final String label;

  const EmptyState({
    required this.animation,
    required this.label,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Use a fraction of the available height for the animation
              SizedBox(
                height: constraints.maxHeight * 0.4,
                child: Lottie.asset(animation),
              ),
              verticalSpaceMedium,
              Text(
                label,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              )
            ],
          ),
        );
      },
    );
  }
}