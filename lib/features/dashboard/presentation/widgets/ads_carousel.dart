import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../../core/data/models/product.dart';
import '../../../../core/utils/money_util.dart';
import '../../../../ui/common/app_colors.dart';
import '../dashboard_viewmodel.dart';
import '../product_details/product_card.dart';

const List<String> _gifList = [
  "assets/gif/easy_power_hub.gif",
  "assets/gif/motion.gif",
];

/// Home hero carousel. Shows real products flagged `ad` on the backend
/// when available (mirrors web's `products.filter((p) => p.ad).slice(0, 6)`),
/// falling back to the static promo GIFs when there are none yet.
class AdsCarousel extends StatefulWidget {
  final DashboardViewModel viewModel;

  const AdsCarousel({super.key, required this.viewModel});

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adProducts = widget.viewModel.productList
        .where((p) => p.ad == true)
        .take(6)
        .toList();
    final useAds = adProducts.isNotEmpty;
    final itemCount = useAds ? adProducts.length : _gifList.length;

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
                    color: Colors.black.withOpacity(isDark ? 0.35 : 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: useAds
                    ? _AdSlide(product: adProducts[index], viewModel: widget.viewModel)
                    : Stack(
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
            autoPlayInterval: Duration(seconds: useAds ? 6 : 5),
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

class _AdSlide extends StatelessWidget {
  final Product product;
  final DashboardViewModel viewModel;

  const _AdSlide({required this.product, required this.viewModel});

  void _openProduct(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ProductCard(product: product, dashboardViewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discountPercent = product.discountPercent;

    return GestureDetector(
      onTap: () => _openProduct(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (product.images?.isNotEmpty == true)
            Image.network(
              product.images!.first,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
            )
          else
            Container(color: Colors.grey[300]),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.65),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.brandName != null)
                  Text(
                    product.brandName!.toUpperCase(),
                    style: const TextStyle(
                      color: kcPrimaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  product.productName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'HostGrotesk',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      MoneyUtils().formatAmount(
                        (double.tryParse(product.salePrice ?? '0') ?? 0).toInt(),
                      ),
                      style: const TextStyle(fontFamily: 'Roboto',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (discountPercent != null && discountPercent > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$discountPercent% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
