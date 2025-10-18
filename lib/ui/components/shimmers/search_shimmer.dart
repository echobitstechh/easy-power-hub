import 'package:flutter/material.dart';
import '../../../../ui/common/app_colors.dart';

class SearchShimmer extends StatelessWidget {
  final bool isDarkMode;

  const SearchShimmer({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : kcWhiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image shimmer
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _ShimmerEffect(isDarkMode: isDarkMode),
              ),
              const SizedBox(width: 12),
              // Text shimmers
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name shimmer
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _ShimmerEffect(isDarkMode: isDarkMode),
                    ),
                    const SizedBox(height: 8),
                    // Brand name shimmer
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _ShimmerEffect(isDarkMode: isDarkMode),
                    ),
                    const SizedBox(height: 8),
                    // Price shimmer
                    Container(
                      height: 14,
                      width: 80,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _ShimmerEffect(isDarkMode: isDarkMode),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerEffect extends StatelessWidget {
  final bool isDarkMode;

  const _ShimmerEffect({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(DateTime.now().millisecondsSinceEpoch),
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  (isDarkMode ? Colors.grey[700]! : Colors.grey[100]!)
                      .withOpacity(0.5),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
      onEnd: () {
        // Animation will restart automatically due to key change
      },
    );
  }
}