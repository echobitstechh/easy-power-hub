import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../../ui/common/app_colors.dart';
import '../dashboard_viewmodel.dart';

const List<String> _gifList = [
  "assets/gif/easy_ph_2.gif",
  "assets/gif/easy_power_hub.gif",
  "assets/gif/motion.gif",
  "assets/gif/quality_power_supply.gif",
];

/// Home hero carousel. Shows all promo GIFs inside assets/gif.
class AdsCarousel extends StatefulWidget {
  final DashboardViewModel? viewModel;

  const AdsCarousel({super.key, this.viewModel});

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemCount = _gifList.length;

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: itemCount,
          itemBuilder: (context, index, realIndex) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
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
                              Colors.black.withValues(alpha: 0.22),
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
          children: List.generate(itemCount, (i) {
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
                        ? kcWhiteColor.withValues(alpha: 0.25)
                        : kcMediumGrey.withValues(alpha: 0.30)),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

