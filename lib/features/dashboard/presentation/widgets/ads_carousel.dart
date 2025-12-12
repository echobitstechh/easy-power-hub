import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

const List<String> _gifList = [
  // "assets/gif/quality_power_supply.gif",
  "assets/gif/easy_power_hub.gif",
  // "assets/gif/easy_ph_1.gif",
  "assets/gif/motion.gif"
];

class AdsCarousel extends StatelessWidget {
  const AdsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: _gifList.length,
      itemBuilder: (context, index, realIndex) {
        final gifPath = _gifList[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              gifPath,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        enlargeCenterPage: true,
        viewportFraction: 1.0,
      ),
    );
  }
}