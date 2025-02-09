import 'dart:async';
import 'dart:developer';
import 'package:afriprize/app/app.router.dart';
import 'package:afriprize/state.dart';
import 'package:afriprize/ui/common/app_colors.dart';
import 'package:afriprize/ui/common/ui_helpers.dart';
import 'package:afriprize/ui/views/dashboard/productcard.dart';
import 'package:afriprize/ui/views/dashboard/raffle_detail.dart';
import 'package:afriprize/ui/views/service/service_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:top_bottom_sheet_flutter/top_bottom_sheet_flutter.dart';
import '../../../app/app.locator.dart';
import '../../../core/data/models/category.dart';
import '../../../core/data/models/product.dart';
import '../../../core/data/models/project.dart';
import '../../../core/data/models/raffle_cart_item.dart';
import '../../components/profile_picture.dart';
import '../service/projectDetailsPage.dart';
import '../shop/shop_view.dart';
import 'dashboard_viewmodel.dart';

/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class DashboardView extends StackedView<DashboardViewModel> {
  DashboardView({Key? key}) : super(key: key);

  final PageController _pageController = PageController();

  List<StaggeredGridTile> buildCardTiles(
      BuildContext context, DashboardViewModel model) {
    return [
      StaggeredGridTile.count(
        crossAxisCellCount: 2,
        mainAxisCellCount: 2,
        child: GestureDetector(
          onTap: () {
            // Navigator.of(context).push(MaterialPageRoute(builder: (c) {
            //   return ShopView(category: "solar energy");
            // }));
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (c) {
                  return ShopView(
                    filter: model.filteredCategories
                        .where((element) =>
                            element.name.toLowerCase().contains("solar"))
                        .first,
                  );
                },
              ),
            );
          },
          child: actionContainer(
              'assets/images/solar.jpg', "Solar Energy", context),
        ),
      ),
      StaggeredGridTile.count(
        crossAxisCellCount: 2,
        mainAxisCellCount: 1,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (c) {
                  return ShopView(
                    filter: model.filteredCategories
                        .where((element) =>
                            element.name.toLowerCase().contains("electronics"))
                        .first,
                  );
                },
              ),
            );
          },
          child: actionContainer(
              'assets/images/2148254069.jpg', "Electronices", context),
        ),
      ),
      StaggeredGridTile.count(
        crossAxisCellCount: 1,
        mainAxisCellCount: 1,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (c) {
              return ServicesView();
            }));
          },
          child: actionContainer(
              'assets/images/2148087576.jpg', "Services", context),
        ),
      ),
      StaggeredGridTile.count(
        crossAxisCellCount: 1,
        mainAxisCellCount: 1,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (c) {
                  return ShopView(
                    filter: model.filteredCategories
                        .where((element) =>
                            element.name.toLowerCase().contains("light"))
                        .first,
                  );
                },
              ),
            );
          },
          child:
              actionContainer('assets/images/107.jpg', "Lightening", context),
        ),
      ),
    ];
  }

  @override
  Widget builder(
    BuildContext context,
    DashboardViewModel viewModel,
    Widget? child,
  ) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Transparent status bar
        statusBarIconBrightness: Brightness.dark, // For dark icons
        statusBarBrightness: Brightness.light, // For light background
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true, // Allow content to flow behind the AppBar
        appBar: AppBar(
          // backgroundColor: Colors.transparent,
          elevation: 0, // Removes shadow
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    const AssetImage("assets/images/easy_ph_logo.png"),
                radius: 20,
              ),
              const SizedBox(width: 8),
              // Autocomplete search in the middle
              Expanded(
                child: Autocomplete<Product>(
                  optionsBuilder: (TextEditingValue productTextEditingValue) {
                    if (productTextEditingValue.text == '') {
                      return const Iterable<Product>.empty();
                    }
                    return viewModel.filteredProductList
                        .where((Product product) {
                      final query = productTextEditingValue.text.toLowerCase();
                      return (product.productName != null &&
                              product.productName!
                                  .toLowerCase()
                                  .contains(query)) ||
                          (product.brandName != null &&
                              product.brandName!.toLowerCase().contains(query));
                    });
                  },
                  displayStringForOption: (Product product) =>
                      product.productName ?? '',
                  onSelected: (Product value) {
                    debugPrint('You just selected ${value.productName}');
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      isDismissible: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25.0),
                            topRight: Radius.circular(25.0)),
                      ),
                      backgroundColor: Colors.black.withOpacity(0.7),
                      builder: (BuildContext context) {
                        return ProductCard(product: value);
                      },
                    );
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Search product...',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          centerTitle: false,
          actions:
              _buildAppBarActions(context, viewModel.appBarLoading, viewModel),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await viewModel.refreshData();
          },
          child: ListView(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            children: [
              // Add some space above the content
              const SizedBox(height: 100), // Space above content
              _buildShimmerOrContent(context, viewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget actionContainer(String imagePath, String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              // width: 110, // Adjust width according to your design
              decoration: BoxDecoration(
                color: Colors.grey[200],
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            // Overlay
            Positioned.fill(
              child: Container(
                color:
                    Colors.black.withOpacity(0.5), // Semi-transparent overlay
              ),
            ),
            // Title Text
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  shadows: [
                    Shadow(
                      blurRadius: 4.0,
                      color: Colors.black,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showProductDialog({
    required BuildContext context,
    required String title,
    required List<String> products,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  verticalSpaceLarge,
                  Text(
                    title,
                    style: GoogleFonts.bricolageGrotesque(
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: Icon(Icons.lightbulb),
                        title: Text(
                          products[index],
                          style: TextStyle(fontSize: 16),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (c) {
                            return ShopView();
                          }));
                          print('Selected Product: ${products[index]}');
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  final List<String> solarProducts = [
    "Solar Panel",
    "Inverter",
    "Battery Storage",
    "Solar Charger",
  ];

  final List<String> LighteningProducts = [
    "LED Bulbs",
    "Chandeliers",
    "Wall Sconces",
    "Outdoor Lights",
  ];

  Widget popularDrawsSlider(
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
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: kcBlackColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
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
          padding: EdgeInsets.only(top: 20),
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.75, // Adjusted aspect ratio
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
              //                   valueColor:
              //                   AlwaysStoppedAnimation<Color>(kcSecondaryColor),
              //                 ),
              //               ),
              //               imageUrl: (item.images != null && item.images!.isNotEmpty)
              //                   ? item.images!.first
              //                   : 'https://via.placeholder.com/120',
              //               height: MediaQuery.of(context).size.height * 0.14, // Reduced image size
              //               width: double.infinity,
              //               fit: BoxFit.fitHeight, // Ensures it fits properly
              //               errorWidget: (context, url, error) =>
              //               const Icon(Icons.error),
              //               fadeInDuration: const Duration(milliseconds: 500),
              //               fadeOutDuration: const Duration(milliseconds: 300),
              //             ),
              //           ),
              //           Positioned(
              //             top: 8,
              //             left: 8,
              //             child: Container(
              //               padding: const EdgeInsets.symmetric(
              //                   horizontal: 8.0, vertical: 4.0),
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
              //         padding: const EdgeInsets.symmetric(
              //             horizontal: 8.0, vertical: 4.0),
              //         child: Row(
              //           children: List.generate(5, (starIndex) {
              //             return Icon(
              //               Icons.star,
              //               color: starIndex < (item.rating?.toInt() ?? 0)
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
              //           item.productName ?? 'Product name',
              //           style: const TextStyle(
              //             fontSize: 14,
              //             fontWeight: FontWeight.bold,
              //           ),
              //           maxLines: 1,
              //           overflow: TextOverflow.ellipsis,
              //         ),
              //       ),
              //       Padding(
              //         padding: const EdgeInsets.symmetric(
              //             horizontal: 8.0, vertical: 4.0),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             Expanded(
              //               child: Text(
              //                 '₦${item.price ?? 0}',
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
              //               onTap: () {
              //                 RaffleCartItem newItem =
              //                 RaffleCartItem(raffle: item, quantity: 1);
              //                 viewModel.addToRaffleCart(item);
              //                 viewModel.notifyListeners();
              //               },
              //               child: Container(
              //                 padding: const EdgeInsets.all(8.0),
              //                 decoration: BoxDecoration(
              //                   color: Colors.white,
              //                   shape: BoxShape.circle,
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
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        kcSecondaryColor),
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

                        // if (isNew)
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
                        ),
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  locator<NavigationService>()
                                      .navigateToCartView();
                                },
                                child: const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: kcSecondaryColor,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₦${item.price ?? 0}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    "2.5",
                                    style: const TextStyle(
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
          },
        )
      ],
    );
  }

  Widget _buildShimmerOrContent(
      BuildContext context, DashboardViewModel viewModel) {
    if (viewModel.filteredProductList.isEmpty && viewModel.isBusy) {
      return Column(
        children: [
          _buildShimmerContainer(), // shimmer for video player placeholder
          verticalSpaceSmall,
          _buildShimmerQuickActions(), // shimmer for quick actions
          verticalSpaceMedium,
          _buildShimmerQuickActions(), // shimmer for quick actions
          verticalSpaceMedium,
          _buildShimmerSlider(), // shimmer for raffle list
          verticalSpaceMedium,
          _buildShimmerSlider(), // shimmer for donations
        ],
      );
    } else {
      return Column(
        children: [
          verticalSpaceSmall,
          // Column(
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.only(right: 8.0),
          //       child: Container(
          //         decoration: BoxDecoration(
          //           border: Border.all(color: Colors.transparent, width: 2.0), // Border color and width
          //           borderRadius: BorderRadius.circular(16.0), // Same radius as ClipRRect
          //         ),
          //         child: ClipRRect(
          //           borderRadius: BorderRadius.circular(16.0),
          //           child: Image.asset(
          //             'assets/animations/easy_power_hub.gif',
          //             fit: BoxFit.cover,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          _buildAdsSlideshow(),
          // quickActions(context),
          verticalSpaceSmall,
          Container(
            // Staggered Grid View starts here
            child: StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              children: buildCardTiles(context, viewModel),
            ),
          ),
          verticalSpaceMedium,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: viewModel.filteredCategories.map((category) {
                return _buildCategoryChip(category, viewModel);
              }).toList(),
            ),
          ),
          verticalSpaceMedium,
          popularDrawsSlider(context, viewModel),
          verticalSpaceSmall,
        ],
      );
    }
  }

  Widget _buildAdsSlideshow() {
    // List of static GIF asset paths
    final List<String> gifList = [
      "assets/animations/quality_power_supply.gif",
      "assets/animations/easy_power_hub.gif",
      "assets/animations/easy_ph_1.gif",
      "assets/animations/easy_ph_2.gif",
    ];

    return CarouselSlider.builder(
      itemCount: gifList.length,
      itemBuilder: (context, index, realIndex) {
        final gifPath = gifList[index];
        return Container(
          // margin: const EdgeInsets.symmetric(horizontal: 3.0), // Add spacing between carousel items
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              gifPath,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 200, // Adjust height of the carousel
        autoPlay: true, // Enable autoplay
        autoPlayInterval: const Duration(seconds: 5),
        enlargeCenterPage: true,
        viewportFraction: 1.0, // Adjust size of the carousel items
      ),
    );
  }
  // Widget _buildAdsSlideshow(DashboardViewModel viewModel) {
  //   if (viewModel.productList.where((element) => element.ad == true).isEmpty) {
  //     // Placeholder Card for no ads
  //     return Card(
  //       color: kcPrimaryColor,
  //       elevation: 2,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(15),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           Flexible(
  //             child: Padding(
  //               padding: const EdgeInsets.all(16.0),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Container(
  //                     width: double.infinity, // Adjust to take available space
  //                     child: const Text(
  //                       'Best Full Solar Installation',
  //                       style: TextStyle(
  //                         fontSize: 20,
  //                         color: kcWhiteColor,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                       softWrap: true,
  //                     ),
  //                   ),
  //                   Container(
  //                     width: double.infinity, // Adjust to take available space
  //                     child: Text(
  //                       'Light out your world',
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         color: kcWhiteColor,
  //                       ),
  //                       softWrap: true,
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: ElevatedButton(
  //                       onPressed: () {},
  //                       style: ElevatedButton.styleFrom(
  //                         foregroundColor: kcBlackColor,
  //                         backgroundColor: kcWhiteColor,
  //                         padding: const EdgeInsets.symmetric(
  //                             vertical: 12.0, horizontal: 24.0),
  //                         textStyle: const TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 16,
  //                         ),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(8.0),
  //                         ),
  //                       ),
  //                       child: Text("Check now"),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.only(right: 4.0),
  //             child: Container(
  //               height: 150, // Adjust the height of the container
  //               width: 130, // Adjust the width of the container
  //               decoration: BoxDecoration(
  //                 borderRadius: const BorderRadius.only(
  //                   topLeft: Radius.circular(10),
  //                   topRight: Radius.circular(10),
  //                 ),
  //                 image: DecorationImage(
  //                   image: AssetImage(
  //                       "assets/images/Mercury-10KVA-Solar-System-1 2.png"),
  //                   fit: BoxFit.fill,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  //
  //   return CarouselSlider.builder(
  //     itemCount:
  //         viewModel.productList.where((element) => element.ad == true).length,
  //     itemBuilder: (context, index, realIndex) {
  //       final ad = viewModel.productList
  //           .where((element) => element.ad == true)
  //           .toList()[index];
  //       return _buildAdItem(ad, context);
  //     },
  //     options: CarouselOptions(
  //       height: 180, // Updated height here
  //       autoPlay: true,
  //       enlargeCenterPage: true,
  //       viewportFraction: 1,
  //       autoPlayInterval: Duration(seconds: 5),
  //       onPageChanged: (index, reason) {},
  //     ),
  //   );
  // }

  Widget _buildAdItem(Product ad, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: kcSecondaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Title and description
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ad.productName ?? 'Best Full Solar Installation',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  verticalSpaceSmall,
                  Text(
                    ad.productDescription ?? 'Light out your world',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  verticalSpaceSmall,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          isDismissible: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25.0),
                                topRight: Radius.circular(25.0)),
                          ),
                          backgroundColor: Colors.black.withOpacity(0.7),
                          builder: (BuildContext context) {
                            return ProductCard(product: ad);
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: kcSecondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: Size(80, 30),
                      ),
                      child: Text('Check Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right side: Product image
          SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              ad.images?.first ?? '',
              width: 120,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.broken_image, size: 100, color: Colors.white);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerContainer() {
    return Shimmer.fromColors(
      baseColor: uiMode.value == AppUiModes.dark
          ? Colors.grey[700]!
          : Colors.grey[300]!,
      highlightColor: uiMode.value == AppUiModes.dark
          ? Colors.grey[300]!
          : Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: kcSecondaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildShimmerQuickActions() {
    return Shimmer.fromColors(
      baseColor: uiMode.value == AppUiModes.dark
          ? Colors.grey[700]!
          : Colors.grey[300]!,
      highlightColor: uiMode.value == AppUiModes.dark
          ? Colors.grey[300]!
          : Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildShimmerSlider() {
    return Shimmer.fromColors(
      baseColor: uiMode.value == AppUiModes.dark
          ? Colors.grey[700]!
          : Colors.grey[300]!,
      highlightColor: uiMode.value == AppUiModes.dark
          ? Colors.grey[300]!
          : Colors.grey[100]!,
      child: Container(
        height: 300, // Adjust the height as per your design
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _notificationIcon(
      int unreadCount, BuildContext context, DashboardViewModel viewModel) {
    print('notif count is $unreadCount');
    return Stack(
      children: [
        IconButton(
            icon: SvgPicture.asset(
              uiMode.value == AppUiModes.dark
                  ? "assets/images/dashboard_otification_white.svg" // Dark mode logo
                  : "assets/images/dashboard_otification.svg",
              width: 25,
              height: 25,
            ),
            onPressed: () {
              _showNotificationSheet(context, viewModel);
            }),
        if (unreadCount > 0)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: BoxConstraints(minWidth: 10, minHeight: 10),
              child: Text(
                unreadCount.toString(),
                style: TextStyle(color: Colors.white, fontSize: 6),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _showNotificationSheet(
      BuildContext context, DashboardViewModel viewModel) {
    // viewModel.markAllNotificationsAsRead();

    TopModalSheet.show(
        context: context,
        isShowCloseButton: true,
        closeButtonRadius: 20.0,
        closeButtonBackgroundColor: kcSecondaryColor,
        child: Container(
          color: kcWhiteColor,
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            children: [
              Text("Notifications",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: notifications.value.length,
                  itemBuilder: (context, index) {
                    final notification = notifications.value[index];
                    return ListTile(
                      minLeadingWidth: 10,
                      leading: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: SvgPicture.asset(
                          'assets/icons/ticket_out.svg',
                          height: 28,
                        ),
                      ),
                      title: Text(
                        notification.subject,
                        style: GoogleFonts.redHatDisplay(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      subtitle: Text(
                        notification.message,
                        style: GoogleFonts.redHatDisplay(
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: kcDarkGreyColor,
                          ),
                        ),
                      ),
                      trailing: notification.unread
                          ? Icon(Icons.circle, color: Colors.red, size: 10)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildCategoryChip(Category category, DashboardViewModel viewModel) {
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

  List<Widget> _buildAppBarActions(
      BuildContext context, bool isLoading, DashboardViewModel viewModel) {
    if (isLoading) {
      // Display the shimmer effect while loading
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 0.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5.0),
                          bottomLeft: Radius.circular(5.0),
                        ),
                      ),
                      width: 80, // Adjust width for the shimmer
                      height: 20, // Adjust height for the shimmer
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ];
    } else {
      // Normal display when data is loaded
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (userLoggedIn.value == true) ...[
                _notificationIcon(unreadCount.value, context, viewModel),
                const SizedBox(width: 3),
                InkWell(
                  onTap: () {
                    locator<NavigationService>().navigateTo(Routes.profileView);
                  },
                  child: CircleAvatar(
                    // backgroundImage: AssetImage("assets/images/easy_ph_logo.png"),
                    backgroundImage: AssetImage(profile.value.profilePicture ??
                        "assets/images/display_pic.png"),
                    radius: 20, // Adjust size as needed
                  ),
                )
              ] else ...[
                InkWell(
                  onTap: () {
                    locator<NavigationService>().navigateTo(Routes.authView);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: kcSecondaryColor
                          .withOpacity(0.2), // Capsule background color
                      borderRadius:
                          BorderRadius.circular(10), // Rounded capsule shape
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: kcBlackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        )
      ];
    }
  }

  @override
  void onViewModelReady(DashboardViewModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.initialise();
  }

  @override
  void onDispose(DashboardViewModel viewModel) {
    viewModel.dispose();
    _pageController.dispose();
  }

  @override
  DashboardViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DashboardViewModel();
}

class RaffleRow extends StatelessWidget {
  final Raffle raffle;
  final DashboardViewModel viewModel;
  final int index;

  const RaffleRow({
    required this.raffle,
    super.key,
    required this.viewModel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    CountdownTimerController controller = CountdownTimerController(endTime: 0);
    int remainingStock = 0;
    int remainingDays = 0;
    int endTime = 0;
    // final int stockTotal = raffle.stockTotal ?? 0;
    // final int verifiedSales = raffle.verifiedSales ?? 0;
    // remainingStock = stockTotal - verifiedSales;

    DateTime now = DateTime.now();
    DateTime drawDate = DateFormat("yyyy-MM-dd")
        .parse(raffle.endDate ?? '2024-02-04T00:00:00.000Z');
    // DateTime drawDate = DateFormat("yyyy-MM-dd").parse("2024-02-04T00:00:00.000Z");
    Duration timeDifference = drawDate.difference(now);
    remainingDays = timeDifference.inDays;
// Adding the current time to the timeDifference to get the future end time
    endTime = now.add(timeDifference).millisecondsSinceEpoch;
    controller =
        CountdownTimerController(endTime: endTime, onEnd: viewModel.onEnd);

    // Check conditions to set the color and text
    Color containerColor = Colors.transparent; // Default color
    String bannerText = ''; // Default text
    if (remainingDays <= 5) {
      containerColor = Colors.blue;
      bannerText = 'Coming soon in';
    } else if (remainingStock <= 10) {
      containerColor = Colors.red;
      bannerText = 'Sold out soon \n $remainingStock item left';
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      // height: 400,
      decoration: BoxDecoration(
        color: uiMode.value == AppUiModes.light ? kcWhiteColor : kcBlackColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kcSecondaryColor),
        boxShadow: [
          BoxShadow(
            color: kcBlackColor.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 4,
          )
        ],
      ),
      child: Stack(
        children: [
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [],
          ),
          if (containerColor != Colors.transparent)
            Positioned(
              top: 0, // Adjust the positioning as you see fit
              left: 22, // Adjust the positioning as you see fit
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0)),
                  ),
                  child: Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                containerColor, // Blue color for the "Closing Soon" banner
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                bannerText,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Panchang",
                                    fontSize: 11),
                              ),
                              if (remainingDays <= 5)
                                CountdownTimer(
                                  controller: controller,
                                  onEnd: viewModel.onEnd,
                                  endTime: endTime,
                                  widgetBuilder:
                                      (_, CurrentRemainingTime? time) {
                                    if (time == null) {
                                      return const Text('in stock');
                                    }

                                    String dayText = '';
                                    if (time.days != null) {
                                      if (time.days! > 0) {
                                        dayText =
                                            '${time.days} ${time.days == 1 ? 'day' : 'days'}, ';
                                      }
                                    }
                                    String formattedHours =
                                        '${time.hours ?? 0}'.padLeft(2, '0');
                                    String formattedMin =
                                        '${time.min ?? 0}'.padLeft(2, '0');
                                    String formattedSec =
                                        '${time.sec ?? 0}'.padLeft(2, '0');

                                    return Text(
                                      '$dayText$formattedHours : $formattedMin : $formattedSec',
                                      style: const TextStyle(
                                          color: kcWhiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Panchang",
                                          fontSize: 11),
                                    );
                                  },
                                ),
                            ],
                          )),
                    ],
                  )),
            ),
        ],
      ),
    );
  }

  Future<Color?> _updateTextColor(String imageUrl) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      NetworkImage(imageUrl),
    );

    // Calculate the brightness of the dominant color
    final Color dominantColor = paletteGenerator.dominantColor!.color;
    final double luminance = dominantColor.computeLuminance();

    // Decide text color based on luminance
    return luminance < 0.1 ? Colors.white : Colors.black;
  }
}

class BackGroundTile extends StatelessWidget {
  final Color backgroundColor;
  final IconData icondata;

  BackGroundTile({required this.backgroundColor, required this.icondata});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Icon(icondata, color: Colors.white),
    );
  }
}
