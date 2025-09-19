

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_ph/features/dashboard/presentation/widgets/category_grid.dart';
import 'package:easy_ph/features/dashboard/presentation/widgets/product_card.dart';
import 'package:easy_ph/features/dashboard/presentation/widgets/product_tags_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/data/models/product.dart';
import '../../../state.dart';
import '../../../ui/common/app_colors.dart';
import '../../../ui/common/ui_helpers.dart';
import '../../../ui/components/brand_chips.dart';
import '../../../ui/components/shimmer_loading.dart';
import '../../shop/shop_view.dart';
import 'dashboard_viewmodel.dart';
import 'widgets/ads_carousel.dart';
import 'widgets/popular_products_section.dart';

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
        backgroundColor: uiMode == AppUiModes.dark ? kcDarkGreyColor : kcWhiteColor,
        body: RefreshIndicator(
          onRefresh: () async {
            await viewModel.getProducts(isRefresh: true);
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo is ScrollEndNotification &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200) {
                viewModel.getProducts();
              }
              return false;
            },
            // The main scrollable body is now a CustomScrollView
            child: CustomScrollView(
              controller: _listController,
              slivers: [
                _buildSliverAppBar(context, viewModel),
                if (viewModel.isBusy)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: DashboardShimmer(),
                    ),
                  )
                else
                  _buildContentSlivers(context, viewModel),
                if (viewModel.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Extracted SliverAppBar for cleaner code
  Widget _buildSliverAppBar(BuildContext context, DashboardViewModel viewModel) {
    return SliverAppBar(
      elevation: 0,
      titleSpacing: 0,
      expandedHeight: 0,
      pinned: true,
      backgroundColor: Colors.transparent,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            // const CircleAvatar(
            //   backgroundImage: AssetImage("assets/images/easy_ph_logo.png"),
            //   radius: 20,
            // ),
            Image.asset(
              "assets/images/easy_ph_logo.png",
              height: 40,
              width: 40,
            ),
            horizontalSpaceSmall,
            Expanded(
              child: Autocomplete<Product>(
                optionsBuilder: (TextEditingValue productTextEditingValue) {
                  if (productTextEditingValue.text.isEmpty) {
                    return const Iterable<Product>.empty();
                  }
                  final query = productTextEditingValue.text.toLowerCase();
                  return viewModel.filteredProductList.where((Product product) {
                    return (product.productName?.toLowerCase().contains(query) ?? false) ||
                        (product.brandName?.toLowerCase().contains(query) ?? false);
                  });
                },
                displayStringForOption: (Product product) => product.productName ?? '',
                onSelected: (Product value) {
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
                      color: uiMode.value == AppUiModes.dark
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
            ),
            const SizedBox(width: 10),
            ValueListenableBuilder<bool>(
              valueListenable: userLoggedIn,
              builder: (context, isLoggedIn, child) {
                // if (isLoggedIn) {
                //   return ValueListenableBuilder(
                //     valueListenable: profile,
                //     builder: (context, userProfile, child) {
                //       return InkWell(
                //         onTap: () {
                //           //todo uncomment when profile is returned
                //           // locator<NavigationService>().navigateTo(Routes.profileView);
                //         },
                //         child: CircleAvatar(
                //           radius: 20,
                //           backgroundImage: (userProfile.profilePicture != null &&
                //               userProfile.profilePicture!.isNotEmpty)
                //               ? (userProfile.profilePicture!.startsWith('http')
                //               ? CachedNetworkImageProvider(userProfile.profilePicture!)
                //           as ImageProvider<Object>
                //               : AssetImage(userProfile.profilePicture!)
                //           as ImageProvider<Object>)
                //               : const AssetImage('assets/images/display_pic.png')
                //           as ImageProvider<Object>,
                //           onBackgroundImageError: (exception, stackTrace) {
                //             debugPrint('Failed to load profile picture: $exception');
                //           },
                //         ),
                //       );
                //     },
                //   );
                // } else {
                  return InkWell(
                    onTap: () {
                      locator<NavigationService>().navigateTo(Routes.authView);
                    },
                    child: Container(
                      // Adjusted height and padding for consistency
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kcSecondaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                }
              // },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSlivers(BuildContext context, DashboardViewModel viewModel) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            verticalSpaceSmall,
            const AdsCarousel(),
            verticalSpaceTiny,
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
              ),
            ),
            verticalSpaceSmall,
            ProductTagsSection(
              viewModel: viewModel,
              onAnyTagTap: () {
                _listController.animateTo(
                  0, // Scroll to the top of the list
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }, crossAxisCount: 1
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: viewModel.brands.map((brand) {
                  return buildBrandChip(brand, viewModel);
                }).toList(),
              ),
            ),
            verticalSpaceSmall,
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
                          color: Theme.of(context).brightness == Brightness.dark
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
                          color: Theme.of(context).brightness == Brightness.dark
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            verticalSpaceSmall,
            PopularProductsSection(viewModel: viewModel),
          ],
        ),
      ),
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