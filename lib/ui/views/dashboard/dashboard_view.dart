import 'dart:async';
import 'package:easyph/app/app.router.dart';
import 'package:easyph/state.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:easyph/ui/views/dashboard/productcard.dart';
import 'package:easyph/ui/views/service/service_view.dart';
import 'package:easyph/utils/money_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easyph/utils/string_entension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:top_bottom_sheet_flutter/top_bottom_sheet_flutter.dart';
import '../../../app/app.locator.dart';
import '../../../core/data/models/category.dart';
import '../../../core/data/models/product.dart';
import '../shop/shop_view.dart';
import 'dashboard_viewmodel.dart';

/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class DashboardView extends StackedView<DashboardViewModel> {
  DashboardView({Key? key}) : super(key: key);

  final PageController _pageController = PageController();

  List<StaggeredGridTile> buildCardTiles(BuildContext context, DashboardViewModel model) {
    List<StaggeredGridTile> tiles = [];

    final categories = {
      "solar": 'assets/images/solar.jpg',
      "electronics": 'assets/images/2148254069.jpg',
      "light": 'assets/images/107.jpg',
    };

    categories.forEach((key, imagePath) {
      final category = model.filteredCategories.firstWhere(
            (cat) => cat.name.toLowerCase().contains(key),
        orElse: () => Category(id: -1, name: '', status: CategoryStatus.active),
      );

      if (category.id != -1) {
        tiles.add(StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (c) => ShopView(filter: category)),
              );
            },
            child: SizedBox(
              height: 50, //
              child: actionContainer(imagePath, key.capitalize(), context),
            ),
          ),
        ));
      }
    });

    // Services card (always shown)
    tiles.add(StaggeredGridTile.count(
      crossAxisCellCount: 1,
      mainAxisCellCount: 1,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (c) => const ServicesView(),
          ));
        },
        child: actionContainer('assets/images/2148087576.jpg', "Services", context),
      ),
    ));

    return tiles;
  }

  List<Widget> buildGridItems(BuildContext context, DashboardViewModel model) {
    List<Widget> tiles = [];

    final categories = {
      "solar": 'assets/images/solar.jpg',
      "electronics": 'assets/images/2148254069.jpg',
      "light": 'assets/images/107.jpg',
    };

    categories.forEach((key, imagePath) {
      final category = model.filteredCategories.firstWhere(
            (cat) => cat.name.toLowerCase().contains(key),
        orElse: () => Category(id: -1, name: '', status: CategoryStatus.active),
      );

      if (category.id != -1) {
        tiles.add(
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (c) => ShopView(filter: category)),
              );
            },
            child: actionContainer(imagePath, key.capitalize(), context),
          ),
        );
      }
    });
    tiles.add(
      GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (c) => const ServicesView(),
          ));
        },
        child: actionContainer('assets/images/2148087576.jpg', "Services", context),
      ),
    );

    return tiles;
  }




  @override
  Widget builder(
    BuildContext context,
    DashboardViewModel viewModel,
    Widget? child,
  ) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          title: Row(
            children: [
              const CircleAvatar(
                backgroundImage:
                    AssetImage("assets/images/easy_ph_logo.png"),
                radius: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Autocomplete<Product>(
                  optionsBuilder: (TextEditingValue productTextEditingValue) {
                    if (productTextEditingValue.text == '') {
                      return const Iterable<Product>.empty();
                    }
                    return viewModel.filteredProductList.where((Product product) {
                      final query = productTextEditingValue.text.toLowerCase();
                      return (product.productName != null &&
                          product.productName!.toLowerCase().contains(query)) ||
                          (product.brandName != null &&
                              product.brandName!.toLowerCase().contains(query));
                    });
                  },
                  displayStringForOption: (Product product) => product.productName ?? '',
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
                        color:  uiMode.value == AppUiModes.dark
                            ? kcMediumGrey
                            : kcWhiteColor,
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
                  // optionsViewBuilder: (BuildContext context,
                  //     AutocompleteOnSelected<Product> onSelected,
                  //     Iterable<Product> options) {
                  //   return Align(
                  //     alignment: Alignment.topLeft,
                  //     child: Material(
                  //       elevation: 4,
                  //       borderRadius: BorderRadius.circular(8),
                  //       child: Container(
                  //         constraints: const BoxConstraints(
                  //           maxHeight: 250, // scrollable max height
                  //           maxWidth: 350,  // limits width of dropdown
                  //         ),
                  //         decoration: BoxDecoration(
                  //           color: Colors.white,
                  //           borderRadius: BorderRadius.circular(8),
                  //         ),
                  //         child:
                  //         // ListView.builder(
                  //         //   padding: EdgeInsets.zero,
                  //         //   shrinkWrap: true,
                  //         //   itemCount: options.length,
                  //         //   itemBuilder: (BuildContext context, int index) {
                  //         //     final Product product = options.elementAt(index);
                  //         //     return ListTile(
                  //         //       leading: (product.images != null && product.images!.isNotEmpty)
                  //         //           ? Image.network(
                  //         //         product.images!.first,
                  //         //         width: 35,
                  //         //         height: 35,
                  //         //         fit: BoxFit.cover,
                  //         //       )
                  //         //           : const Icon(Icons.image, size: 30),
                  //         //       title: Text(
                  //         //         product.productName ?? "",
                  //         //         style: const TextStyle(
                  //         //           fontSize: 13,
                  //         //           fontWeight: FontWeight.w500,
                  //         //           overflow: TextOverflow.ellipsis,
                  //         //         ),
                  //         //         maxLines: 2,
                  //         //       ),
                  //         //       onTap: () => onSelected(product),
                  //         //     );
                  //         //   },
                  //         // ),
                  //           NotificationListener<ScrollNotification>(
                  //             onNotification: (scrollNotification) {
                  //               if (scrollNotification is ScrollEndNotification &&
                  //                   scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent) {
                  //                 viewModel.getProducts(); // This will load the next page
                  //               }
                  //               return false;
                  //             },
                  //             child: ListView.builder(
                  //               padding: EdgeInsets.zero,
                  //               shrinkWrap: true,
                  //               itemCount: viewModel.productList.length + (viewModel.isLoadingMore ? 1 : 0),
                  //               itemBuilder: (BuildContext context, int index) {
                  //                 // Show loading spinner at the end while fetching more
                  //                 if (index == viewModel.productList.length) {
                  //                   return const Center(
                  //                     child: Padding(
                  //                       padding: EdgeInsets.symmetric(vertical: 20),
                  //                       child: CircularProgressIndicator(strokeWidth: 2),
                  //                     ),
                  //                   );
                  //                 }
                  //
                  //                 final Product product = viewModel.productList[index];
                  //
                  //                 return ListTile(
                  //                   leading: (product.images != null && product.images!.isNotEmpty)
                  //                       ? Image.network(
                  //                     product.images!.first,
                  //                     width: 35,
                  //                     height: 35,
                  //                     fit: BoxFit.cover,
                  //                   )
                  //                       : const Icon(Icons.image, size: 30),
                  //                   title: Text(
                  //                     product.productName ?? "",
                  //                     style: const TextStyle(
                  //                       fontSize: 13,
                  //                       fontWeight: FontWeight.w500,
                  //                       overflow: TextOverflow.ellipsis,
                  //                     ),
                  //                     maxLines: 2,
                  //                   ),
                  //                   onTap: () => onSelected(product),
                  //                 );
                  //               },
                  //             ),
                  //           )
                  //
                  //       ),
                  //     ),
                  //   );
                    // In your DashboardView class, replace the optionsViewBuilder section with this:

                    optionsViewBuilder: (BuildContext context,
                        AutocompleteOnSelected<Product> onSelected,
                        Iterable<Product> options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            constraints: const BoxConstraints(
                              maxHeight: 250,
                              maxWidth: 350,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Product product = options.elementAt(index);
                                return ListTile(
                                  leading: (product.images != null && product.images!.isNotEmpty)
                                      ? Image.network(
                                    product.images!.first,
                                    width: 35,
                                    height: 35,
                                    fit: BoxFit.cover,
                                  )
                                      : const Icon(Icons.image, size: 30),
                                  title: Text(
                                    product.productName ?? "",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 2,
                                  ),
                                  onTap: () => onSelected(product),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                  },
                ),
              )
            ],
          ),
          centerTitle: false,
          actions:
              _buildAppBarActions(context, viewModel.appBarLoading, viewModel),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
    await viewModel.getProducts(isRefresh: true);
    },
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification &&
              scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
            viewModel.getProducts(); // This will load the next page
          }
          return false;
        },
        child: ListView(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          children: [
            const SizedBox(height: 100),
            _buildShimmerOrContent(context, viewModel),
            if (viewModel.isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
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
              decoration: BoxDecoration(
                color: Colors.grey[200],
                boxShadow: const [
                  BoxShadow(
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
                    Colors.black.withOpacity(0.5),
              ),
            ),
            // Title Text
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                title,
                style: const TextStyle(
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
                boxShadow: const [
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
                      textStyle: const TextStyle(
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
                        leading: const Icon(Icons.lightbulb),
                        title: Text(
                          products[index],
                          style: const TextStyle(fontSize: 16),
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
                                  viewModel.addToRaffleCart(item);
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
                                        color: Colors.grey,
                                      ),
                                      ShaderMask(
                                        shaderCallback: (Rect bounds) {
                                          double ratingValue = item.rating ?? 0.0;
                                          return LinearGradient(
                                            stops: [ratingValue / 5, ratingValue / 5],
                                            colors: [Colors.amber, Colors.grey],
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

  Widget _buildShimmerOrContent(
      BuildContext context, DashboardViewModel viewModel) {
    if (viewModel.filteredProductList.isEmpty && viewModel.isBusy) {
      return Column(
        children: [
          _buildShimmerContainer(),
          verticalSpaceSmall,
          _buildShimmerQuickActions(),
          verticalSpaceMedium,
          _buildShimmerQuickActions(),
          verticalSpaceMedium,
          _buildShimmerSlider(),
          verticalSpaceMedium,
          _buildShimmerSlider(),
        ],
      );
    } else {
      return Column(
        children: [
          verticalSpaceSmall,
          _buildAdsSlideshow(),
          // quickActions(context),
          verticalSpaceSmall,
          Container(
            padding: const EdgeInsets.all(0),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2,
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: buildGridItems(context, viewModel),
            )

          ),
          verticalSpaceMedium,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: viewModel.brands.map((brand) {
                return _buildBrandChip(brand, viewModel);
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
      "assets/gif/quality_power_supply.gif",
      "assets/gif/easy_power_hub.gif",
      "assets/gif/easy_ph_1.gif",
      "assets/gif/easy_ph_2.gif",
    ];

    return CarouselSlider.builder(
      itemCount: gifList.length,
      itemBuilder: (context, index, realIndex) {
        final gifPath = gifList[index];
        return Container(
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
        height: 200,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        enlargeCenterPage: true,
        viewportFraction: 1.0,
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
        height: 300,
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
                  ? "assets/images/dashboard_otification_white.svg"
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
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 6),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _showNotificationSheet(
      BuildContext context, DashboardViewModel viewModel) {
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
              const Text("Notifications",
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
                          ? const Icon(Icons.circle, color: Colors.red, size: 10)
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
              30.0),
        ),
      ),
    );
  }

  Widget _buildBrandChip(String brand, DashboardViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ChoiceChip(
        label: Text(
          brand ?? '',
          style: GoogleFonts.redHatDisplay(
            textStyle: const TextStyle(),
          ),
        ),
        selected: brand ==
            viewModel.selectedBrand,
        onSelected: (bool selected) {
          viewModel.setSelectedBrand(
              selected ? brand : '');
          viewModel.notifyListeners();
        },
        selectedColor: kcSecondaryColor,
        backgroundColor: uiMode.value == AppUiModes.dark
            ? Colors.grey[500]!
            : Colors.grey[100]!,
        labelStyle: TextStyle(
          color:
          brand == viewModel.selectedBrand ? Colors.white : Colors.black,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: uiMode.value == AppUiModes.dark
                ? Colors.grey[500]!
                : Colors.grey[100]!,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(
              30.0),
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
                      radius: 20,
                      backgroundImage: (profile.value.profilePicture != null &&
                          profile.value.profilePicture!.isNotEmpty)
                          ? (profile.value.profilePicture!.startsWith('http')
                          ? CachedNetworkImageProvider(profile.value.profilePicture!)
                      as ImageProvider<Object>
                          : AssetImage(profile.value.profilePicture!)
                      as ImageProvider<Object>)
                          : const AssetImage('assets/images/display_pic.png')
                      as ImageProvider<Object>,
                      onBackgroundImageError: (exception, stackTrace) {
                        debugPrint('Failed to load profile picture: $exception');
                      },
                    )
                )
              ] else ...[
                InkWell(
                  onTap: () {
                    locator<NavigationService>().navigateTo(Routes.authView);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: kcSecondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: uiMode.value == AppUiModes.dark
                            ? kcWhiteColor
                            : kcBlackColor,
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
    // viewModel.dispose();
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
              top: 0,
              left: 22,
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

    final Color dominantColor = paletteGenerator.dominantColor!.color;
    final double luminance = dominantColor.computeLuminance();

    return luminance < 0.1 ? Colors.white : Colors.black;
  }
}

class BackGroundTile extends StatelessWidget {
  final Color backgroundColor;
  final IconData icondata;

  const BackGroundTile({super.key, required this.backgroundColor, required this.icondata});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Icon(icondata, color: Colors.white),
    );
  }
}
