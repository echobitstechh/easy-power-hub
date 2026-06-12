import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../../../ui/common/app_colors.dart';

const List<String> _gifList = [
  "assets/gif/easy_power_hub.gif",
  "assets/gif/motion.gif",
];

class AdsCarousel extends StatefulWidget {
  const AdsCarousel({super.key});

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _gifList.length,
          itemBuilder: (context, index, realIndex) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.35 : 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    Image.asset(
                      _gifList[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    // Subtle gradient overlay at the bottom
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.22),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 190,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayCurve: Curves.easeInOutCubic,
            enlargeCenterPage: false,
            viewportFraction: 1.0,
            onPageChanged: (index, _) => setState(() => _current = index),
          ),
        ),

        const SizedBox(height: 10),

        // Pill indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_gifList.length, (i) {
            final isActive = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? kcPrimaryColor
                    : (isDark
                        ? kcWhiteColor.withOpacity(0.25)
                        : kcMediumGrey.withOpacity(0.30)),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}