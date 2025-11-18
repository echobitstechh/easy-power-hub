import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_ph/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/app.locator.dart';
import '../../../../core/data/models/cart_item.dart';
import '../../../../core/data/models/product.dart';
import '../../../../core/network/interceptors.dart';
import '../../../../core/utils/money_util.dart';
import '../../../../state.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../../../shop/shop_view.dart';
import '../dashboard_viewmodel.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  DashboardViewModel dashboardViewModel;

  ProductCard({Key? key, required this.product, required this.dashboardViewModel}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}



class _ProductCardState extends State<ProductCard> {
  String selectedImage = '';
  Color iconColor = kcBlackColor;

  List<Review> productReviews = [];

  @override
  void initState() {
    super.initState();
    fetchProductReviews();
    selectedImage = (widget.product.images != null && widget.product.images!.isNotEmpty)
        ? widget.product.images!.first
        : '';
    widget.dashboardViewModel?.filteredProductList = widget.dashboardViewModel!.filteredProductList
        .where((product) => product.categoryId == widget.product.categoryId)
        .toList();
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
    if(mounted) {
      setState(() {
        selectedImage = imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite =  widget.dashboardViewModel.isProductFavorite(widget.product.id!);
    return Scaffold(
      appBar: AppBar(

        centerTitle: true,
        title: const Text("Product Details"),
        toolbarHeight: 100,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              widget.dashboardViewModel.toggleFavorite(widget.product);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, size: 25),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: (widget.product.images ?? [])
                    .map((image) => GestureDetector(
                  onTap: () => updateImage(image),
                  child: buildImageContainer(image, 80, 80),
                ))
                    .toList(),
              ),
              const SizedBox(width: 16),
              Flexible(
                fit: FlexFit.loose, // Allows the container to shrink if needed
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
                  child: CachedNetworkImage(
                    imageUrl: selectedImage,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: 345,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.product.productName ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  widget.product.productDescription ?? '',
                  style: const TextStyle(fontSize: 12),
                  softWrap: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      MoneyUtils().formatAmount((double.tryParse(widget.product.salePrice ?? '0.0') ?? 0.0).toInt()),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),

              if (widget.product.warranty == true && (widget.product.warrantyPeriod ?? 0) > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user,
                            color: Colors.green.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.product.warrantyPeriod}-month${(widget.product.warrantyPeriod ?? 0) > 1 ? 's' : ''} warranty',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                            
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: userLoggedIn.value == false
                          ? const SizedBox()
                          : ValueListenableBuilder<List<CartItem>>(
                          valueListenable: cart,
                          builder: (context, value, child) {
                            bool isInCart = value.any((item) => item.product?.id == widget.product.id);
                            CartItem? cartItem = isInCart ? value.firstWhere((item) => item.product?.id == widget.product.id) : null;
                            final bool isAvailable = (widget.product.availability ?? 0) >= 1;

                            if (!isAvailable) {
                              // product not available → show WhatsApp button
                              return _buildWhatsAppContactButton(widget.product);
                            }

                            return isInCart && cartItem != null
                                ? Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                  color: kcVeryLightGrey,
                                  borderRadius:
                                  BorderRadius.circular(9)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      Navigator.pop(context);
                                      locator<NavigationService>()
                                          .navigateToCartView();
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        color: kcSecondaryColor,
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Go to Cart",
                                            style: TextStyle(
                                                color: kcBlackColor,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Container(
                                    height: 53,
                                    decoration: BoxDecoration(
                                      color: kcWhiteColor,
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                    child:  Row(
                                      children: [
                                        InkWell(
                                          onTap: (){
                                            if(mounted){
                                              setState(() {
                                                widget.dashboardViewModel.modifyCartQuantity(cartItem, 'decrement');
                                              });
                                            }
                                          },
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              color: kcWhiteColor,
                                              borderRadius:
                                              BorderRadius.circular(5),
                                            ),
                                            child: const Center(
                                                child: Icon(Icons.remove,
                                                    size: 18,
                                                    color: kcBlackColor)),
                                          ),
                                        ),
                                        horizontalSpaceSmall,
                                        Text(
                                          "${cartItem.quantity}",
                                          style: const TextStyle(
                                              color: kcBlackColor),
                                        ),
                                        horizontalSpaceSmall,
                                        InkWell(
                                          onTap: (){
                                            if(mounted){
                                              setState(() {
                                                widget.dashboardViewModel.modifyCartQuantity(cartItem, 'increment');
                                              });
                                            }
                                          },
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              color: kcWhiteColor,
                                              borderRadius:
                                              BorderRadius.circular(5),
                                            ),
                                            child: const Align(
                                                alignment: Alignment.center,
                                                child: Icon(Icons.add,
                                                    size: 18,
                                                    color: kcBlackColor)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                            )
                                : InkWell(
                              onTap: () async {
                                if(mounted){
                                  setState(() {
                                    widget.dashboardViewModel.addProductToCart(widget.product);
                                  });
                                }
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
                          }),
                    ),
                  ],
                ),

              ),

            ],
          ),
          const Divider(),
          verticalSpaceTiny,
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'You might also like',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          verticalSpaceMedium,
          SizedBox(
            height: 200, // Adjust height to match the size of your cards
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.dashboardViewModel?.filteredProductList.length,
              itemBuilder: (context, index) {
                Product product = widget.dashboardViewModel!.filteredProductList[index];

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopView(
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        color: uiMode.value == AppUiModes.dark
                            ? Colors.transparent // Dark mode logo
                            : kcWhiteColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.transparent,
                            blurRadius: 6.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Card(
                        color: uiMode.value == AppUiModes.dark
                            ? kcDarkGreyColor // Dark mode logo
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
                                imageUrl: (product.images != null && product.images!.isNotEmpty)
                                    ? product.images!.first
                                    : 'https://via.placeholder.com/150',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) {
                                  return Center(child: CircularProgressIndicator());
                                },
                                errorWidget: (context, url, error) {
                                  return Icon(
                                    Icons.broken_image,
                                    size: 100,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0),
                              child: Text(
                                product.productName ?? 'service title',
                                style: GoogleFonts.redHatDisplay(
                                  fontSize: 16,
                                  color: uiMode.value == AppUiModes.dark
                                      ? kcWhiteColor // Dark mode logo
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
                                product.productDescription ?? '',
                                style: GoogleFonts.redHatDisplay(
                                  fontSize: 12,
                                  color: uiMode.value == AppUiModes.dark
                                      ? kcWhiteColor // Dark mode logo
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
          verticalSpaceSmall,
          const Divider(),
          if (productReviews.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Product Rating & Reviews',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${productReviews.length} reviews",
                    style: const TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
          ],
          verticalSpaceSmall,
          Column(
            children: productReviews.map((review) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                    // ⭐ Rating stars
                    Row(
                      children: List.generate(
                        review.rating.toInt(),
                            (index) => const Icon(Icons.star, color: Colors.orange, size: 16),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 📝 Review Title / Summary
                    Text(
                      review.content,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),

                    // 👤 By reviewer
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
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget buildImageContainer(String imagePath, double width, double height) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) {
          return Center(child: CircularProgressIndicator());
        },
        errorWidget: (context, url, error) {
          return const Icon(
            Icons.broken_image,
            size: 50,
            color: Colors.grey,
          );
        },
      ),
    );
  }

  Widget _buildWhatsAppContactButton(Product product) {
    return InkWell(
      onTap: () async {
        final phoneNumber = '+2348081099871';
        final message = "Hello, I'd like to inquire about the product: ${product.productName}";
        final url = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";
        if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
        } else {

        }
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.green.shade600, // Use a distinct WhatsApp color
          borderRadius: BorderRadius.circular(9),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/whatsapp.svg',
                height: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 5),
              const Text(
                "Inquire/Contact us",
                style: TextStyle(
                  color: kcWhiteColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
