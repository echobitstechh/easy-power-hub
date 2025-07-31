import 'dart:convert';

import 'package:easyph/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:share_plus/share_plus.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../core/data/models/cart_item.dart';
import '../../../core/data/models/product.dart';
import '../../../core/network/interceptors.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../state.dart';
import '../../../utils/money_util.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../shop/shop_view.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}
bool isFavorited = false;
class _ProductCardState extends State<ProductCard> {
  String selectedImage = '';
  Color iconColor = kcBlackColor;

  List<Product> filteredProductList = [];
  List<Product> productList = [];
  List<Review> productReviews = [];

  @override
  void initState() {
    super.initState();
    loadProduct();
    fetchProductReviews();
    selectedImage = (widget.product.images != null && widget.product.images!.isNotEmpty)
        ? widget.product.images!.first
        : ''; // Fallback value
  }

  void addToRaffleCart(Product product) async {
    // setBusy(true);
    // notifyListeners();
    try {
      final existingItem = cart.value.firstWhere(
            (raffleItem) => raffleItem.product?.id == product.id,
        orElse: () => CartItem(product: product, quantity: 0),
      );

      if (existingItem.quantity != null && existingItem.quantity! > 0 && existingItem.product != null) {
        existingItem.quantity = (existingItem.quantity! + 1);
      } else {
        existingItem.quantity = 1;
        cart.value.add(existingItem);
      }

      // Save to local storage
      List<Map<String, dynamic>> storedList = cart.value.map((e) => e.toJson()).toList();
      await locator<LocalStorage>().save(LocalStorageDir.raffleCart, storedList);

      // Save to online cart using API
      final response = await repo.addToCart({
        "productId": product.id,
        "quantity": existingItem.quantity,
      });

      if (response.statusCode == 200) {
        locator<SnackbarService>().showSnackbar(message: "Raffle added to cart", duration: const Duration(seconds: 2));
      } else {
        locator<SnackbarService>().showSnackbar(message: response.data["message"], duration: const Duration(seconds: 2));
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(message: "Failed to add raffle to cart: $e", duration: const Duration(seconds: 2));
    }
  }

  Future<void> loadProduct() async {
    print('loading products....');
    try {

      dynamic storedJsonProduct = await locator<LocalStorage>().fetch(LocalStorageDir.product);
      print("Loaded jsonProducts from storage: $storedJsonProduct");


      if ( storedJsonProduct != null && storedJsonProduct.isNotEmpty) {
        List<dynamic> storedProducts = jsonDecode(storedJsonProduct);
        print('Decoded JSON: $storedProducts');
        // Populate productList and filteredProductList
        productList = storedProducts
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        print('loaded products from local storage list ${productList.length}');
        print('loaded products from local storage ${productList.map((e) => e.salePrice)}');
        if(mounted){
          setState(() {
            productList = productList;
            filteredProductList = productList.where((product) => product.categoryId == widget.product.categoryId).toList();
          });
        }
      }else{
        print('no value to load');
      }

    } catch (e) {
      print("Error loading products: $e");
    }
  }

  Future<void> decreaseRaffleQuantity(CartItem item) async {
    try {
      if (item.quantity! > 1) {
        item.quantity = item.quantity! - 1;

        // Update online cart
        await repo.addToCart({
          "productId": item.product?.id,
          "quantity": item.quantity,
        });
      } else if (item.quantity! == 1) {
        // Remove from local cart
        cart.value.removeWhere((cartItem) => cartItem.product?.id == item.product?.id);

        // Remove from online cart
        await repo.deleteFromCart(item.product!.id!);
      }

      // Save to local storage
      List<Map<String, dynamic>> storedList = cart.value.map((e) => e.toJson()).toList();
      await locator<LocalStorage>().save(LocalStorageDir.raffleCart, storedList);
    } catch (e) {
      locator<SnackbarService>().showSnackbar(message: "Failed to decrease raffle quantity: $e", duration: const Duration(seconds: 2));
    print(e);
    }
  }

  Future<void> increaseRaffleQuantity(CartItem item) async {

    try {
      item.quantity = item.quantity! + 1;
      int index = cart.value.indexWhere((raffleItem) => raffleItem.product?.id == item.product?.id);
      if (index != -1) {
        cart.value[index] = item;
        cart.value = List.from(cart.value);

        // Update online cart
        await repo.addToCart({
          "productId": item.product?.id,
          "quantity": item.quantity,
        });

        // Save to local storage
        List<Map<String, dynamic>> storedList = cart.value.map((e) => e.toJson()).toList();
        await locator<LocalStorage>().save(LocalStorageDir.raffleCart, storedList);
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(message: "Failed to increase raffle quantity: $e", duration: const Duration(seconds: 2));

    } finally {

      cart.notifyListeners();
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
    if(mounted) {
      setState(() {
        selectedImage = imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('widget value: ${widget.product.productName}');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Product Details"),
        toolbarHeight: 100,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, size: 25),
            onPressed: ()  {

            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min, // Shrinks the Row's size to fit its content
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
                  child: Image.network(
                    selectedImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey,
                      );
                    },
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
                    color: Colors.black,
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
                            bool isInCart = value.any((item) =>
                            item.product?.id == widget.product.id);
                            CartItem? cartItem = isInCart
                                ? value.firstWhere((item) =>
                            item.product?.id == widget.product.id)
                                : null;

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
                                            "Goto Cart",
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
                                                decreaseRaffleQuantity(cartItem);
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
                                                increaseRaffleQuantity(cartItem);
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
                                    addToRaffleCart(widget.product);
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
                    // IconButton(
                    //   icon: Icon(
                    //     isFavorited
                    //         ? Icons.favorite // Icon when favorited
                    //         : Icons.favorite_border_outlined, // Icon when not favorited
                    //     size: 30,
                    //     color: isFavorited ? kcSecondaryColor : iconColor, // Toggle color
                    //   ),
                    //   onPressed: () {
                    //     if(mounted){
                    //       setState(() {
                    //         isFavorited = !isFavorited; // Toggle the boolean
                    //       });
                    //     }
                    //   },
                    // ),


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
              itemCount: filteredProductList.length,
              itemBuilder: (context, index) {
                Product product = filteredProductList[index];

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
                              child: Image.network(
                                product.images != null && product.images!.isNotEmpty
                                    ? product.images!.first
                                    : 'https://via.placeholder.com/150',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image, size: 100, color: Colors.white);
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
      child: Image.network(imagePath, fit: BoxFit.cover),
    );
  }
}
