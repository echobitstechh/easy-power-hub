import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_ph/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../../app/app.locator.dart';
import '../../../../core/data/models/cart_item.dart';
import '../../../../core/data/models/product.dart';
import '../../../../core/network/interceptors.dart';
import '../../../../core/utils/money_util.dart';
import '../../../../state.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../../../../ui/components/glass/glass_button.dart';
import '../../../shop/shop_view.dart';
import '../dashboard_viewmodel.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final DashboardViewModel dashboardViewModel;

  const ProductCard({
    Key? key,
    required this.product,
    required this.dashboardViewModel,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String selectedImage = '';
  List<Review> productReviews = [];

  @override
  void initState() {
    super.initState();
    fetchProductReviews();
    selectedImage =
        (widget.product.images?.isNotEmpty == true)
            ? widget.product.images!.first
            : '';
    widget.dashboardViewModel.filteredProductList =
        widget.dashboardViewModel.productList
            .where((p) => p.categoryId == widget.product.categoryId)
            .toList();
  }

  Future<void> fetchProductReviews() async {
    try {
      final res = await repo.getReviews(widget.product.id!);
      if (res.statusCode == 200 && mounted) {
        setState(() {
          productReviews = (res.data['reviews'] as List)
              .map((r) => Review.fromJson(r))
              .toList();
        });
      }
    } catch (_) {}
  }

  void _selectImage(String img) {
    if (mounted) setState(() => selectedImage = img);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFavorite = widget.dashboardViewModel
        .isProductFavorite(widget.product.id!);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? kcDarkBgGradient : kcLightBgGradient,
          ),
        ),
        child: Column(
          children: [
            _buildGlassAppBar(context, isFavorite, isDark),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeroSection(context, isDark),
                  _buildInfoCard(context, isDark),
                  if (widget.dashboardViewModel.filteredProductList.isNotEmpty)
                    _buildRelatedProducts(context, isDark),
                  if (productReviews.isNotEmpty)
                    _buildReviewsSection(context, isDark),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Glass app bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildGlassAppBar(BuildContext context, bool isFavorite, bool isDark) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 4,
            right: 4,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: isDark ? kcGlassSurfaceDark : kcGlassSurfaceLight,
            border: Border(
              bottom: BorderSide(
                color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  'Product Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'HostGrotesk',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () =>
                    widget.dashboardViewModel.toggleFavorite(widget.product),
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded, size: 22),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // â”€â”€ Hero image section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildHeroSection(BuildContext context, bool isDark) {
    final images = widget.product.images ?? [];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail strip
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                children: images
                    .map(
                      (img) => GestureDetector(
                        onTap: () => _selectImage(img),
                        child: Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selectedImage == img
                                  ? kcSecondaryColor
                                  : (isDark
                                        ? kcGlassBorderDark
                                        : kcGlassBorderLight),
                              width: selectedImage == img ? 2 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: CachedNetworkImage(
                              imageUrl: img,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                              ),
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.broken_image_rounded,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          // Main image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 340,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1F35) : const Color(0xFFEBEFF8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: selectedImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: selectedImage,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kcSecondaryColor.withOpacity(0.6),
                          ),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.broken_image_rounded,
                          size: 80,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.image_not_supported_rounded,
                        size: 80,
                        color: Colors.grey,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Info card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildInfoCard(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? kcGlassSurfaceDark : kcGlassSurfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.28 : 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  widget.product.productName ?? '',
                  style: TextStyle(fontFamily: 'HostGrotesk',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                verticalSpaceSmall,
                // Price
                Text(
                  MoneyUtils().formatAmount(
                    (double.tryParse(widget.product.salePrice ?? '0') ?? 0)
                        .toInt(),
                  ),
                  style: GoogleFonts.roboto(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kcSecondaryColor,
                  ),
                ),
                // Warranty badge
                if (widget.product.warranty == true &&
                    (widget.product.warrantyPeriod ?? 0) > 0) ...[
                  verticalSpaceSmall,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded,
                            color: Colors.green.shade600, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.product.warrantyPeriod}-month warranty',
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                verticalSpaceSmall,
                // Description
                Text(
                  widget.product.productDescription ?? '',
                  style: TextStyle(fontFamily: 'HostGrotesk',
                    fontSize: 13,
                    height: 1.6,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                verticalSpaceMedium,
                // CTA
                _buildCTA(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCTA(BuildContext context, bool isDark) {
    final isAvailable = (widget.product.availability ?? 0) >= 1;

    return ValueListenableBuilder<List<CartItem>>(
      valueListenable: cart,
      builder: (context, cartItems, _) {
        final inCart =
            cartItems.any((i) => i.product?.id == widget.product.id);
        final cartItem = inCart
            ? cartItems.firstWhere((i) => i.product?.id == widget.product.id)
            : null;

        if (inCart && cartItem != null) {
          return Row(
            children: [
              Expanded(
                child: GlassButton(
                  label: 'Go to Cart',
                  icon: const Icon(Icons.shopping_cart_rounded, size: 18, color: Colors.white),
                  onTap: () {
                    Navigator.pop(context);
                    locator<NavigationService>().navigateToCartView();
                  },
                ),
              ),
              const SizedBox(width: 12),
              _QuantityRow(
                item: cartItem,
                viewModel: widget.dashboardViewModel,
                onChanged: () => setState(() {}),
              ),
            ],
          );
        }

        return GlassButton(
          label: isAvailable ? 'Add to Cart' : 'Request Item',
          icon: const Icon(Icons.shopping_bag_outlined, size: 18, color: Colors.white),
          onTap: () {
            setState(() {
              widget.dashboardViewModel.addProductToCart(
                widget.product,
                isUnavailable: !isAvailable,
              );
            });
          },
        );
      },
    );
  }

  // â”€â”€ Related products â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildRelatedProducts(BuildContext context, bool isDark) {
    final related = widget.dashboardViewModel.filteredProductList
        .where((p) => p.id != widget.product.id)
        .take(10)
        .toList();
    if (related.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You might also like',
            style: TextStyle(fontFamily: 'HostGrotesk',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          verticalSpaceSmall,
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: related.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final p = related[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductCard(
                        product: p,
                        dashboardViewModel: widget.dashboardViewModel,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: 140,
                        decoration: BoxDecoration(
                          color: isDark
                              ? kcGlassSurfaceDark
                              : kcGlassSurfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? kcGlassBorderDark
                                : kcGlassBorderLight,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: p.images?.first ?? '',
                                height: 100,
                                width: 140,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  height: 100,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                              child: Text(
                                p.productName ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontFamily: 'HostGrotesk',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              child: Text(
                                MoneyUtils().formatAmount(
                                  (double.tryParse(p.salePrice ?? '0') ?? 0)
                                      .toInt(),
                                ),
                                style: GoogleFonts.roboto(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: kcSecondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Reviews â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildReviewsSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ratings & Reviews',
                style: TextStyle(fontFamily: 'HostGrotesk',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${productReviews.length} reviews',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
          verticalSpaceSmall,
          ...productReviews.map((r) => _buildReviewCard(r, isDark)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? kcGlassSurfaceDark : kcGlassSurfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    review.rating.toInt(),
                    (_) => const Icon(Icons.star_rounded,
                        color: kcSecondaryColor, size: 15),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  review.content,
                  style: TextStyle(fontFamily: 'HostGrotesk',
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'by ${review.reviewerName}',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                    Text(
                      '${review.date.day.toString().padLeft(2, '0')}-'
                      '${review.date.month.toString().padLeft(2, '0')}-'
                      '${review.date.year}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

// â”€â”€ Quantity row widget â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _QuantityRow extends StatelessWidget {
  final CartItem item;
  final DashboardViewModel viewModel;
  final VoidCallback onChanged;
  const _QuantityRow({
    required this.item,
    required this.viewModel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kcGlassBorderLight, width: 1),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if ((item.quantity ?? 0) > 1) {
                viewModel.modifyCartQuantity(item, 'decrement');
              }
              onChanged();
            },
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.remove_rounded, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.quantity}',
            style: GoogleFonts.roboto(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              viewModel.modifyCartQuantity(item, 'increment');
              onChanged();
            },
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.add_rounded,
                size: 18,
                color: kcSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

