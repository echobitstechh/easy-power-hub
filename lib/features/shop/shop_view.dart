import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../../core/data/models/category.dart';
import '../../../ui/common/app_colors.dart';
import '../../../ui/common/ui_helpers.dart';
import '../../../ui/components/empty_state.dart';
import '../../ui/components/shimmers/shimmer_loading.dart';
import '../../ui/components/brand_chips.dart';
import '../../ui/components/product_search_bar.dart';
import '../dashboard/presentation/dashboard_viewmodel.dart';
import '../dashboard/presentation/widgets/popular_products_section.dart';
import '../dashboard/presentation/widgets/product_tags_section.dart';

class ShopView extends StackedView<DashboardViewModel> {
  final Category? filter;
  final bool isSpecialCategory;
  final ScrollController _listController = ScrollController();

  ShopView({
    super.key,
    this.filter,
    this.isSpecialCategory = false,
  });

  @override
  Widget builder(
    BuildContext context,
    DashboardViewModel viewModel,
    Widget? child,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, String>> slides = (filter != null &&
            filter?.image != null)
        ? [
            {
              'image': filter!.image!,
              'title': filter?.name ?? '',
              'description': 'Explore ${filter?.name ?? ''}',
            }
          ]
        : [
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? kcDarkBgGradient : kcLightBgGradient,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: RefreshIndicator(
          color: kcSecondaryColor,
          onRefresh: () async => viewModel.getProducts(isRefresh: true),
          child: NestedScrollView(
            controller: _listController,
            headerSliverBuilder: (ctx, innerBoxScrolled) =>
                [_buildSliverAppBar(ctx, viewModel, slides, isDark)],
            body: Builder(
              builder: (ctx) {
                return NotificationListener<ScrollNotification>(
                  onNotification: (info) {
                    if (info is ScrollEndNotification &&
                        info.metrics.pixels >=
                            info.metrics.maxScrollExtent - 200) {
                      viewModel.getProducts();
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          ctx,
                        ),
                      ),
                      if (viewModel.isLoadingProducts)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: DashboardShimmer(),
                          ),
                        )
                      else if (viewModel.productList.isEmpty)
                        SliverFillRemaining(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: EmptyState(
                              animation: 'assets/animations/empty_cart.json',
                              label: 'No products yet',
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildListDelegate([
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: ProductTagsSection(
                                viewModel: viewModel,
                                crossAxisCount: 2,
                              ),
                            ),
                            verticalSpaceMedium,
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: viewModel.brands
                                      .map(
                                        (b) => buildBrandChip(b, viewModel),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: PopularProductsSection(
                                viewModel: viewModel,
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 80,
                            ),
                          ]),
                        ),
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    DashboardViewModel viewModel,
    List<Map<String, String>> slides,
    bool isDark,
  ) {
    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverAppBar(
        expandedHeight: 260,
        pinned: true,
        floating: true,
        collapsedHeight: 70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            fit: StackFit.expand,
            children: [
              CarouselSlider.builder(
                options: CarouselOptions(
                  height: double.infinity,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                ),
                itemCount: slides.length,
                itemBuilder: (ctx, i, _) {
                  final slide = slides[i];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      slide['image']!.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: slide['image']!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: const Color(0xFF161B2E),
                              ),
                              errorWidget: (_, __, ___) =>
                                  const Icon(Icons.error),
                            )
                          : Image.asset(
                              slide['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.error),
                            ),
                      // Gradient overlay
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0xCC000000),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 28,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slide['title']!,
                              style: TextStyle(fontFamily: 'HostGrotesk',
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              slide['description']!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        title: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? kcGlassSurfaceDark : kcGlassSurfaceLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/easy_ph_logo.png',
                    height: 32,
                    width: 32,
                  ),
                  horizontalSpaceSmall,
                  Expanded(
                    child: ProductSearchBar(viewModel: viewModel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onViewModelReady(DashboardViewModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.filteredProductList = [];
    if (filter != null) {
      viewModel.setSelectedCategory(filter!.id);
    } else {
      viewModel.init();
    }
  }

  @override
  DashboardViewModel viewModelBuilder(BuildContext context) =>
      DashboardViewModel();
}

