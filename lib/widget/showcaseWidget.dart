import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class AppShowcase extends StatelessWidget {
  final GlobalKey showcaseKey;
  final String title;
  final String description;
  final VoidCallback? onSkip;
  final VoidCallback? onNext;
  final Widget child;
  final double? width;
  final double? height;

  const AppShowcase({
    Key? key,
    required this.showcaseKey,
    required this.title,
    required this.description,
    this.onSkip,
    this.onNext,
    required this.child,
    this.width = 350,
    this.height = 500,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Showcase.withWidget(
      key: showcaseKey,
      container: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white, // General background color for the showcase popup
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7, // Adjust popup width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black, // You can customize color as needed
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87, // Customize as needed
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: onSkip ?? () {
                        ShowCaseWidget.of(context).dismiss(); // Exit the showcase
                      },
                      child: const Text('Skip'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onNext ?? () {
                        ShowCaseWidget.of(context).next(); // Move to the next showcase
                      },
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      disposeOnTap: false,
      onTargetClick: () {
        // Dismiss showcase when target is clicked
        ShowCaseWidget.of(context).dismiss();
      },
      width: width,
      height: height,
      child: child, // The widget you want to highlight in the showcase
    );
  }
}
