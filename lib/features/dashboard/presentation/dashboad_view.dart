import 'dart:ui';

import 'package:easy_ph/features/dashboard/presentation/widgets/category_grid.dart';
import 'package:easy_ph/features/dashboard/presentation/widgets/product_tags_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../state.dart';
import '../../../ui/bottom_sheets/favourite/favourite_bottom_sheet.dart';
import '../../../ui/common/app_colors.dart';
import '../../../ui/common/ui_helpers.dart';
import '../../../ui/components/brand_chips.dart';
import '../../../ui/components/product_search_bar.dart';
import '../../../ui/components/shimmers/shimmer_loading.dart';
import '../../shop/shop_view.dart';
import 'dashboard_viewmodel.dart';
import 'widgets/ads_carousel.dart';
import 'widgets/popular_products_section.dart';

class DashboardView extends StackedView<DashboardViewModel> {
  DashboardView({Key? key}) : super(key: key);

  final ScrollController _listController = ScrollController();

  @override
  Widget builder(
    BuildContext context,
    DashboardViewModel viewModel,
    Widget? child,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? kcDarkBgGradient : kcLightBgGradient,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            color: kcSecondaryColor,
            onRefresh: () async => viewModel.getProducts(isRefresh: true),
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (scrollInfo is ScrollEndNotification &&
                    scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200) {
                  viewModel.getProducts();
                }
                return false;
              },
              child: CustomScrollView(
                controller: _listController,
                slivers: [
                  _buildSliverAppBar(context, viewModel),
                  _buildContentSlivers(context, viewModel),
                  if (viewModel.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kcSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    DashboardViewModel viewModel,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      elevation: 0,
      titleSpacing: 0,
      expandedHeight: 0,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? kcGlassSurfaceDark : kcGlassSurfaceLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Image.asset(
              'assets/images/easy_ph_logo.png',
              height: 36,
              width: 36,
            ),
            horizontalSpaceSmall,
            Expanded(child: ProductSearchBar(viewModel: viewModel)),
            const SizedBox(width: 8),
            ValueListenableBuilder<bool>(
              valueListenable: userLoggedIn,
              builder: (context, isLoggedIn, _) {
                if (isLoggedIn) return const SizedBox();
                return GestureDetector(
                  onTap: () => locator<NavigationService>()
                      .navigateTo(Routes.login),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kcSecondaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: kcSecondaryColor.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(fontFamily: 'HostGrotesk',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kcSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSlivers(
    BuildContext context,
    DashboardViewModel viewModel,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          verticalSpaceSmall,
          const AdsCarousel(),
          verticalSpaceTiny,

          // Categories
          viewModel.isLoadingCategories
              ? const ShimmerLoading(child: ShimmerQuickActionsGrid())
              : GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: buildGridItems(context, viewModel),
                ),

          verticalSpaceSmall,

          // Tags
          viewModel.isLoadingTags
              ? const ShimmerLoading(child: ShimmerQuickActionsGrid())
              : ProductTagsSection(
                  viewModel: viewModel,
                  onAnyTagTap: () => _listController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  ),
                  crossAxisCount: 1,
                ),

          verticalSpaceTiny,

          // Brands
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: viewModel.brands
                  .map((b) => buildBrandChip(b, viewModel))
                  .toList(),
            ),
          ),

          verticalSpaceSmall,

          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Popular Products',
                    style: TextStyle(fontFamily: 'HostGrotesk',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Explore our most sought-after products',
                    style: TextStyle(fontFamily: 'HostGrotesk',
                      fontSize: 11,
                      color: isDark
                          ? Colors.white54
                          : Colors.black45,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ShopView()),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: kcSecondaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: kcSecondaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Explore',
                            style: TextStyle(fontFamily: 'HostGrotesk',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: kcSecondaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: kcSecondaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          verticalSpaceSmall,

          // Products
          viewModel.isLoadingProducts
              ? const ShimmerLoading(
                  child: Column(
                    children: [
                      ShimmerSlider(),
                      verticalSpaceSmall,
                      ShimmerSlider(),
                    ],
                  ),
                )
              : PopularProductsSection(viewModel: viewModel),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
        ]),
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
    try { _listController.dispose(); } catch (_) {}
  }

  @override
  DashboardViewModel viewModelBuilder(BuildContext context) =>
      DashboardViewModel();
}

