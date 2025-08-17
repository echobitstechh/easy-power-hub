import 'package:cached_network_image/cached_network_image.dart';
import 'package:easyph/ui/views/dashboard/widget/productcard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../state.dart';
import '../../utils/money_util.dart';
import '../common/app_colors.dart';
import '../views/shop/shop_view.dart';
import '../views/dashboard/dashboard_viewmodel.dart';

Widget popularProducts(
    BuildContext context, DashboardViewModel viewModel) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Popular Products",
                style: GoogleFonts.bricolageGrotesque(
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: uiMode.value == AppUiModes.dark
                        ? kcWhiteColor
                        : kcBlackColor,
                  ),
                ),
              ),
              Text(
                "Explore our most sought-after products",
                style: GoogleFonts.redHatDisplay(
                  textStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: uiMode.value == AppUiModes.dark
                        ? kcWhiteColor
                        : kcBlackColor,
                  ),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (c) {
                return ShopView();
              }));
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: kcSecondaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    "Explore",
                    style: GoogleFonts.redHatDisplay(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        color: kcBlackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: kcSecondaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 20),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 0.75,
        ),
        itemCount: viewModel.filteredProductList.length,
        itemBuilder: (context, index) {
          final item = viewModel.filteredProductList[index];
          return InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                isDismissible: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                backgroundColor: Colors.black.withOpacity(0.7),
                builder: (BuildContext context) {
                  return ProductCard(product: item);
                },
              );
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:Theme.of(context).brightness == Brightness.dark
                    ? kcDarkGreyColor// Slightly lighter black for contrast
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color:Theme.of(context).brightness == Brightness.dark
                                ? kcDarkGreyColor// Slightly lighter black for contrast
                                : Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade300, // Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: CachedNetworkImage(
                              placeholder: (context, url) => const Padding(
                                padding: EdgeInsets.all(16),
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(kcSecondaryColor),
                                  ),
                                ),
                              ),

                              imageUrl: (item.images != null &&
                                  item.images!.isNotEmpty)
                                  ? item.images!.first
                                  : 'https://via.placeholder.com/120',
                              height: MediaQuery.of(context).size.height *
                                  0.15, // Reduced image size
                              width: double.infinity,
                              fit: BoxFit
                                  .fitHeight, // Ensures it fits properly
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                              fadeInDuration:
                              const Duration(milliseconds: 500),
                              fadeOutDuration:
                              const Duration(milliseconds: 300),
                            ),
                          ),
                        ),
                      ),

                      viewModel.isNewProduct(item.createdAt ?? '') ?
                      Positioned(
                        left: 16,
                        top: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'New',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ): const SizedBox.shrink(),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.productName ?? 'Product name',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                viewModel.addProductToCart(item);
                              },
                              child: viewModel.loadingItems.contains(item.id)
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: kcSecondaryColor,
                                ),
                              )
                                  : const Icon(
                                Icons.shopping_cart_outlined,
                                color: kcSecondaryColor,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              MoneyUtils().formatAmount((double.tryParse(item.salePrice ?? '0.0') ?? 0.0).toInt()),
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.grey, // Base star color
                                    ),
                                    ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        double ratingValue = item.rating ?? 0.0;
                                        return LinearGradient(
                                          stops: [ratingValue / 5, ratingValue / 5],
                                          colors: const [Colors.amber, Colors.grey], // Fill and empty colors
                                        ).createShader(bounds);
                                      },
                                      child: const Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  (item.rating ?? 0.0).toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      )
    ],
  );
}