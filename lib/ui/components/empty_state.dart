import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///


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
    return Center(
      child: SingleChildScrollView(
         // Add padding if needed
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset("assets/animations/$animation"),
              const SizedBox(height: 5), // Spacing between animation and text
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold, // Make the text more prominent
                ),
                textAlign: TextAlign.center, // Center-align the text
              ),
            ],
          ),
        ),
    );


  }
}
