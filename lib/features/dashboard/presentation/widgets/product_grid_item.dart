

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_ph/features/dashboard/presentation/product_details/product_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/data/models/product.dart';
import '../../../../core/utils/image_util.dart';
import '../../../../core/utils/money_util.dart';
import '../../../../ui/common/app_colors.dart';
import '../dashboard_viewmodel.dart';
import 'product_flags.dart';

class ProductGridItem extends StatelessWidget {
  final Product product;
  final DashboardViewModel viewModel;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
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
            return ProductCard(product: product, dashboardViewModel: viewModel);
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? kcGlassSurfaceDark
              : kcGlassSurfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? kcGlassBorderDark
                : kcGlassBorderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(Theme.of(context).brightness == Brightness.dark
                      ? 0.25
                      : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(context),
            Expanded(
              child: _buildProductDetails(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(14)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: (product.images != null && product.images!.isNotEmpty)
                    ? ImageUtils.getCutoutImageUrl(product.images!.first)
                    : 'https://via.placeholder.com/120',
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.15,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error_outline, color: Colors.grey),
                ),
                fadeInDuration: const Duration(milliseconds: 500),
                fadeOutDuration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        ),
        // if ((product.availability ?? 0) < 1)
        //   const Positioned(
        //     right: 10,
        //     top: 10,
        //     child: OutOfStockTag(),
        //   )
        if (viewModel.isNewProduct(product.createdAt ?? ''))
          const Positioned(
            left: 16,
            top: 16,
            child: NewProductTag(),
          ),
        if (product.discountPercent != null && product.discountPercent! > 0)
          Positioned(
            right: 16,
            top: 16,
            child: DiscountTag(percent: product.discountPercent!),
          ),
        if (product.brandName != null && product.brandName!.isNotEmpty)
          Positioned(
            left: 16,
            bottom: 8,
            child: BrandPill(label: product.brandName!),
          ),
      ],
    );
  }



  Widget _buildProductDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.productName ?? 'Product name',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildCartButton(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // The fix is here: wrap the Text widget in an Expanded widget
              Expanded(
                child: Text(
                  MoneyUtils().formatAmount((double.tryParse(product.salePrice ?? '0.0') ?? 0.0).toInt()),
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if ((product.rating ?? 0.0) > 0) _buildRating(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartButton() {
    final isUnavailable = (product.availability ?? 0) < 1;
    return InkWell(
      onTap: () {
        viewModel.addProductToCart(product, isUnavailable: isUnavailable);
      },
      child: viewModel.loadingItems.contains(product.id)
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
        size: 24,
      ),
    );
  }


  Widget _buildRating() {
    return Row(
      children: [
        Stack(
          children: [
            const Icon(
              Icons.star,
              size: 16,
              color: Colors.grey,
            ),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                final ratingValue = product.rating ?? 0.0;
                return LinearGradient(
                  stops: [ratingValue / 5, ratingValue / 5],
                  colors: const [Colors.amber, Colors.grey],
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
          (product.rating ?? 0.0).toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}


