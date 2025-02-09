import 'dart:async';
import 'package:afriprize/app/app.router.dart';
import 'package:afriprize/state.dart';
import 'package:afriprize/ui/common/app_colors.dart';
import 'package:afriprize/ui/common/ui_helpers.dart';
import 'package:afriprize/ui/views/dashboard/productcard.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:stacked/stacked.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../core/data/models/category.dart';
import '../../../core/data/models/product.dart';
import '../../../core/data/models/raffle_cart_item.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../widget/AdventureDialog.dart';
import 'shop_viewmodel.dart';

/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class ShopView extends StackedView<ShopViewModel> {
  final Category? filter;

  ShopView({Key? key, this.filter}) : super(key: key);
  final PageController _pageController = PageController();

  @override
  Widget builder(
    BuildContext context,
    ShopViewModel viewModel,
    Widget? child,
  ) {
    // Filter products based on the passed category
    List<Product> categoryProducts = viewModel.filteredProductList;
    if (filter != null) {
      categoryProducts = viewModel.filteredProductList.where((product) {
        return product.categoryId == filter?.id;
      }).toList();
    }

    // Prepare slides dynamically based on the filtered category
    List<Map<String, String>> slides = [];

    if (filter != null && filter?.image != null) {
      slides = [
        {
          'image': filter!.image!,
          'title': filter?.name ?? '',
          'description': 'Explore ${filter?.name ?? ''}',
        }
      ];
    } else {
      // Fallback to default slides if no category or no images
      slides = [
        {
          'image': 'assets/images/shop_solar.jpeg',
          'title': 'Solar Energy Systems',
          'description': 'Explore Solar Products',
        },
        {
          'image': 'assets/images/shop_light.jpeg',
          'title': 'Electronics',
          'description': 'Get the best deals',
        },
        {
          'image': 'assets/images/shop_light2.jpeg',
          'title': 'Lighting',
          'description': 'Light up your world',
        },
      ];
    }

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  expandedHeight: 300.0,
                  pinned: true,
                  floating: true,
                  collapsedHeight: 80.0,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: CarouselSlider.builder(
                      options: CarouselOptions(
                        height: 300,
                        viewportFraction: 1.0,
                        autoPlay: true,
                      ),
                      itemCount: slides.length,
                      itemBuilder:
                          (BuildContext context, int index, int pageIndex) {
                        final slide = slides[index];
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            slide['image']!.startsWith('http') || slide['image']!.startsWith('https')
                                ? CachedNetworkImage(
                              imageUrl: slide['image']!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            )
                                : Image.asset(
                              slide['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                            ),


                            Container(
                              color: Colors.black.withOpacity(0.3),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Spacer(),
                                  Text(
                                    slide['title']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    slide['description']!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Builder(
            builder: (BuildContext context) {
              return CustomScrollView(
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  viewModel.filteredCategories.map((category) {
                                return _buildCategoryChip(category, viewModel);
                              }).toList(),
                            ),
                          ),
                          popularDrawsSlider(
                              context, categoryProducts, viewModel),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget popularDrawsSlider(
    BuildContext context,
    List<Product> productList,
    ShopViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.75, // Adjusted aspect ratio
          ),
          itemCount: productList.length,
          itemBuilder: (context, index) {
            final product = productList[index];
            return ProductCardWidget(
              product: product,
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
                    return ProductCard(product: product);
                  },
                );
              },
              onAddToCart: () => viewModel.addToRaffleCart(product),
            );
          },
        )
      ],
    );
  }

  Widget _buildCategoryChip(Category category, ShopViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ChoiceChip(
        label: Text(
          category.name ?? '',
          style: GoogleFonts.redHatDisplay(
            textStyle: const TextStyle(),
          ),
        ),
        selected: category.id ==
            viewModel.selectedId, // Check if this category is selected
        onSelected: (bool selected) {
          viewModel.setSelectedCategory(
              selected ? category.id : 0); // Update viewModel properly
          viewModel.notifyListeners(); // Notify the listeners to rebuild the UI
        },
        selectedColor: kcSecondaryColor,
        backgroundColor: uiMode.value == AppUiModes.dark
            ? Colors.grey[500]!
            : Colors.grey[100]!,
        labelStyle: TextStyle(
          color:
              category.id == viewModel.selectedId ? Colors.white : Colors.black,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: uiMode.value == AppUiModes.dark
                ? Colors.grey[500]!
                : Colors.grey[100]!, // Set the border color to light grey
            width: 1.0, // Set the border width
          ),
          borderRadius: BorderRadius.circular(
              30.0), // Reduce the border radius (adjust this value)
        ),
      ),
    );
  }

  @override
  void onViewModelReady(ShopViewModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.initialise();
  }

  @override
  void onDispose(ShopViewModel viewModel) {
    viewModel.dispose();
    _pageController.dispose();
  }

  @override
  ShopViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ShopViewModel();
}

/// Product Card Widget
class ProductCardWidget extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCardWidget({
    Key? key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      // child: Card(
      //   margin: const EdgeInsets.all(8.0),
      //   elevation: 3,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(20),
      //   ),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       Stack(
      //         children: [
      //           ClipRRect(
      //             borderRadius: const BorderRadius.only(
      //               topLeft: Radius.circular(20),
      //               topRight: Radius.circular(20),
      //             ),
      //             child: CachedNetworkImage(
      //               placeholder: (context, url) => const Center(
      //                 child: CircularProgressIndicator(
      //                   strokeWidth: 2.0,
      //                   valueColor: AlwaysStoppedAnimation<Color>(
      //                     kcSecondaryColor,
      //                   ),
      //                 ),
      //               ),
      //               imageUrl: (product.images != null && product.images!.isNotEmpty)
      //                   ? product.images!.first
      //                   : 'https://via.placeholder.com/120',
      //               height: MediaQuery.of(context).size.height * 0.1,
      //               width: double.infinity,
      //               fit: BoxFit.fitHeight,
      //               errorWidget: (context, url, error) => const Icon(Icons.error),
      //               fadeInDuration: const Duration(milliseconds: 500),
      //               fadeOutDuration: const Duration(milliseconds: 300),
      //             ),
      //           ),
      //           Positioned(
      //             top: 8,
      //             left: 8,
      //             child: Container(
      //               padding: const EdgeInsets.symmetric(
      //                 horizontal: 8.0,
      //                 vertical: 4.0,
      //               ),
      //               decoration: BoxDecoration(
      //                 color: Colors.black,
      //                 borderRadius: BorderRadius.circular(12),
      //               ),
      //               child: const Text(
      //                 'NEW',
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 12,
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //       Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      //         child: Row(
      //           children: List.generate(5, (starIndex) {
      //             return Icon(
      //               Icons.star,
      //               color: starIndex < (product.rating?.toInt() ?? 0)
      //                   ? kcStarColor
      //                   : Colors.grey,
      //               size: 16,
      //             );
      //           }),
      //         ),
      //       ),
      //       Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //         child: Text(
      //           product.productName ?? 'Product name',
      //           style: const TextStyle(
      //             fontSize: 14,
      //             fontWeight: FontWeight.bold,
      //           ),
      //           maxLines: 1,
      //           overflow: TextOverflow.ellipsis,
      //         ),
      //       ),
      //       Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Expanded(
      //               child: Text(
      //                 '₦${product.price ?? 0}',
      //                 style: const TextStyle(
      //                   fontSize: 14,
      //                   fontWeight: FontWeight.bold,
      //                   color: kcPrimaryColor,
      //                 ),
      //                 maxLines: 1,
      //                 overflow: TextOverflow.ellipsis,
      //               ),
      //             ),
      //             GestureDetector(
      //               onTap: onAddToCart,
      //               child: Container(
      //                 padding: const EdgeInsets.all(8.0),
      //                 decoration: BoxDecoration(
      //                   color: Colors.white,
      //                   shape: BoxShape.circle,
      //                   boxShadow: [
      //                     BoxShadow(
      //                       color: Colors.grey.withOpacity(0.5),
      //                       spreadRadius: 1,
      //                       blurRadius: 5,
      //                       offset: const Offset(0, 3),
      //                     ),
      //                   ],
      //                 ),
      //                 child: GestureDetector(
      //                   onTap: (){
      //                     locator<NavigationService>().navigateToCartView();
      //                   },
      //                   child: const Icon(
      //                     Icons.shopping_cart_outlined,
      //                     color: kcSecondaryColor,
      //                     size: 16,
      //                   ),
      //                 ),
      //               ),
      //             )
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Container(
                    //height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade300, // Border color
                        width: 1.0, // Border width
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: CachedNetworkImage(
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(kcSecondaryColor),
                          ),
                        ),
                        imageUrl: (product.images != null &&
                                product.images!.isNotEmpty)
                            ? product.images!.first
                            : 'https://via.placeholder.com/120',
                        height: MediaQuery.of(context).size.height * 0.13,
                        width: double.infinity,
                        fit: BoxFit.fitHeight,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fadeInDuration: const Duration(milliseconds: 500),
                        fadeOutDuration: const Duration(milliseconds: 300),
                      ),
                    ),
                  ),
                ),
                // if (isNew)
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName ?? 'Product name',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₦${product.price ?? 0}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "2.5",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
