import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PrizeCard extends StatelessWidget {
  const PrizeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Text with a grey background

        // Card with a title, SVG icon, and a price
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blue, // Assuming the card background is blue
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: <Widget>[
              SvgPicture.asset(
                'assets/icons/card_icon.svg', // Replace with your actual asset path
                color: Colors.white, // Icon color
                height: 24, // Icon size
              ),
              const SizedBox(width: 8), // Spacing between icon and text
              const Text(
                'Easyph Card',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  // Other text style properties
                ),
              ),
              const SizedBox(width: 8), // Spacing between text and price
              const Text(
                '\$5.00',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  // Other text style properties
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
