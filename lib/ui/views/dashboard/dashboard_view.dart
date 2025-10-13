import 'dart:async';
import 'package:easyph/app/app.router.dart';
import 'package:easyph/state.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:easyph/ui/views/dashboard/productcard.dart';
import 'package:easyph/ui/views/dashboard/widgets/category_grid.dart';
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
import '../../components/brand_chips.dart';
import '../../components/shimmer.dart';
import '../shop/shop_view.dart';
import 'dashboard_viewmodel.dart';
import '../../../core/data/models/tags.dart';

/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class DashboardView extends StackedView<DashboardViewModel> {
  DashboardView({Key? key}) : super(key: key);

  final PageController _pageController = PageController();

  final ScrollController _listController = ScrollController();

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
              horizontalSpaceSmall,
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
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              await viewModel.getProducts(isRefresh: true);
            },
            child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
      if (scrollInfo is ScrollEndNotification &&
      scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
        viewModel.getProducts();
      }
      return false;
      },
        child: ListView(
          controller: _listController,
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


  Widget _buildShimmerOrContent(
      BuildContext context, DashboardViewModel viewModel) {
    if (viewModel.filteredProductList.isEmpty && viewModel.isBusy) {
      return Column(
        children: [
          buildShimmerContainer(),
          verticalSpaceSmall,
          buildShimmerQuickActions(),
          verticalSpaceMedium,
          buildShimmerQuickActions(),
          verticalSpaceMedium,
          buildShimmerSlider(),
          verticalSpaceMedium,
          buildShimmerSlider(),
        ],
      );
    } else {
      return Column(
        children: [
          _buildAdsSlideshow(),
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
                return buildBrandChip(brand, viewModel);
              }).toList(),
            ),
          ),
          verticalSpaceMedium,
          popularDrawsSlider(context, viewModel),
        ],
      );
    }
  }
  Widget _buildAdsSlideshow() {
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
                                  //viewModel.addToRaffleCart(item);
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

  @override
  void onViewModelReady(DashboardViewModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.init();
  }

  @override
  void onDispose(DashboardViewModel viewModel) {
    _pageController.dispose();
  }

  @override
  DashboardViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DashboardViewModel();
}


