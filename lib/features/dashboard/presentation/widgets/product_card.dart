import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app/app.locator.dart';
import '../../../../app/app.router.dart';
import '../../../../core/data/models/cart_item.dart';
import '../../../../core/data/models/product.dart';
import '../../../../core/network/interceptors.dart';
import '../../../../core/utils/money_util.dart';
import '../../../../state.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class ProductCardArguments {
  final Product product;
  ProductCardArguments({required this.product});
}

class _ProductCardState extends State<ProductCard> {
  String selectedImage = '';
  List<Review> productReviews = [];

  List<Product> filteredProductList = [];


  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    selectedImage = (widget.product.images != null && widget.product.images!.isNotEmpty)
        ? widget.product.images!.first
        : 'https://via.placeholder.com/120';
    if(userLoggedIn.value){
      fetchProductReviews();
    }
  }

  Future<void> modifyQuantity(CartItem item, String action) async {
    try {
      final index = cart.value.indexWhere((i) => i.product?.id == item.product?.id);
      if (index == -1) return;

      if (action == "increment") {
        cart.value[index].quantity = (item.quantity ?? 0) + 1;
        await repo.modifyCartItem(item.product!.id.toString(), "increment");
      } else if (action == "decrement") {
        if ((item.quantity ?? 1) > 1) {
          cart.value[index].quantity = (item.quantity ?? 1) - 1;
          await repo.modifyCartItem(item.product!.id.toString(), "decrement");
        } else {
          cart.value.removeAt(index);
          await repo.deleteFromCart(item.product!.id.toString());
        }
      }

      cart.value = [...cart.value];
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
          message: "Error: ${e.toString()}"
      );
    }
  }

  Future<void> fetchProductReviews() async {
    try {
      final response = await repo.getReviews(widget.product.id!);
      if (response.statusCode == 200) {
        final List<dynamic> reviewJson = response.data["reviews"];
        if (mounted) {
          setState(() {
            productReviews = reviewJson.map((r) => Review.fromJson(r)).toList();
          });
        }
      }
    } catch (e) {
      print("Failed to load reviews: $e");
    }
  }

  void updateImage(String imagePath) {
    if (mounted) {
      setState(() {
        selectedImage = imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uiMode.value == AppUiModes.dark ? kcDarkGreyColor : kcWhiteColor,
      appBar: AppBar(
        backgroundColor: uiMode.value == AppUiModes.dark ? kcDarkGreyColor : kcWhiteColor,
        centerTitle: true,
        title: const Text("Product Details"),
        toolbarHeight: 100,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, size: 25),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProductImagesSection(context),
          const Divider(height: 32),
          _buildProductDetails(),
          const Divider(height: 32),
          _buildRelatedProductsSection(),
          const Divider(height: 32),
          _buildRatingReviewsSection(),
        ],
      ),
    );
  }

  Widget _buildProductImagesSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: (widget.product.images ?? [])
              .map((image) => GestureDetector(
            onTap: () => updateImage(image),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildThumbnailImage(image, 80, 80),
            ),
          ))
              .toList(),
        ),
        horizontalSpaceMedium,
        Expanded(
          child: Container(
            height: 345,
            decoration: BoxDecoration(
              color: const Color(0xFFDADADA).withOpacity(0.5),
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: selectedImage,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 345,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.productName ?? '',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        verticalSpaceTiny,
        Text(
          widget.product.productDescription ?? '',
          style: const TextStyle(fontSize: 12),
          softWrap: true,
        ),
        verticalSpaceSmall,
        Text(
          MoneyUtils().formatAmount((double.tryParse(widget.product.salePrice ?? '0.0') ?? 0.0).toInt()),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            fontFamily: 'Roboto',
          ),
        ),
        verticalSpaceMedium,
        _buildAddToCartSection(),
      ],
    );
  }


  Widget _buildAddToCartSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: userLoggedIn,
      builder: (context, isLoggedIn, child) {
        if (isLoggedIn) {
          return ValueListenableBuilder<List<CartItem>>(
            valueListenable: cart,
            builder: (context, value, child) {
              final cartItem = value.firstWhere(
                    (item) => item.product?.id == widget.product.id,
                orElse: () => CartItem(),
              );

              final isInCart = cartItem.product != null;

              return Row(
                children: [
                  if (isInCart)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildGotoCartButton(),
                          _buildQuantitySelector(cartItem),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: _buildAddButton(),
                    ),
                ],
              );
            },
          );
        } else {
          return InkWell(
            onTap: () {
              locator<NavigationService>().navigateTo(Routes.authView);
            },
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kcSecondaryColor,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Text(
                "Login to Add to Cart",
                style: TextStyle(
                  color: kcBlackColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildGotoCartButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        locator<NavigationService>().navigateToCartView();
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: kcSecondaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            "Go to Cart",
            style: TextStyle(
              color: kcBlackColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(CartItem cartItem) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: kcWhiteColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kcVeryLightGrey)
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18, color: kcBlackColor),
            onPressed: () => modifyQuantity(cartItem, "decrement"),
          ),
          horizontalSpaceTiny,
          Text(
            "${cartItem.quantity}",
            style: const TextStyle(color: kcBlackColor),
          ),
          horizontalSpaceTiny,
          IconButton(
            icon: const Icon(Icons.add, size: 18, color: kcBlackColor),
            onPressed: () => modifyQuantity(cartItem, "increment"),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: () {
        //viewModel.addToRaffleCart(widget.product);
        // This logic needs to be added here.
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: kcSecondaryColor,
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Add to cart",
                style: TextStyle(color: kcBlackColor),
              ),
              SizedBox(width: 5),
              Icon(
                Icons.shopping_bag_outlined,
                color: kcBlackColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'You might also like',
          style: TextStyle(fontSize: 18),
        ),
        verticalSpaceMedium,
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredProductList.length,
            itemBuilder: (context, index) {
              final relatedProduct = filteredProductList[index];
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () {
                    locator<NavigationService>().navigateTo(
                      Routes.productCard,
                      arguments: ProductCardArguments(product: relatedProduct),
                    );
                  },
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? kcDarkGreyColor
                          : kcWhiteColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Card(
                      elevation: 0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? kcDarkGreyColor
                          : kcWhiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                            child: CachedNetworkImage(
                              imageUrl: (relatedProduct.images != null && relatedProduct.images!.isNotEmpty)
                                  ? relatedProduct.images!.first
                                  : 'https://via.placeholder.com/150',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0),
                            child: Text(
                              relatedProduct.productName ?? 'Product Title',
                              style: GoogleFonts.redHatDisplay(
                                fontSize: 16,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? kcWhiteColor
                                    : kcBlackColor,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5.0, 0, 8.0, 8.0),
                            child: Text(
                              relatedProduct.productDescription ?? '',
                              style: GoogleFonts.redHatDisplay(
                                fontSize: 12,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? kcWhiteColor
                                    : kcBlackColor,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildRatingReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Product Rating & Reviews',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "${productReviews.length} reviews",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        verticalSpaceSmall,
        if (productReviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No reviews yet.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...productReviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              review.rating.toInt(),
                  (index) => const Icon(Icons.star, color: Colors.orange, size: 16),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            review.content,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "by ${review.reviewerName}",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
              ),
              Text(
                "${review.date.day.toString().padLeft(2, '0')}-${review.date.month.toString().padLeft(2, '0')}-${review.date.year}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailImage(String imagePath, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imagePath,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: width,
              height: height,
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.broken_image,
            size: 50,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}