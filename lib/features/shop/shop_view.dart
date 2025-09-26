import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
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
    // Correctly build slides based on filter
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          await viewModel.getProducts(isRefresh: true);
        },
        child: Container(
          color: Theme.of(context).brightness == Brightness.dark ? kcDarkGreyColor : kcWhiteColor,
          child: NestedScrollView(
            controller: _listController,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                _buildSliverAppBar(context, viewModel, slides),

              ];
            },
            body: Builder(
              builder: (BuildContext context) {
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo is ScrollEndNotification &&
                        scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                      viewModel.getProducts();
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      ),
                      if (viewModel.isBusy)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: DashboardShimmer(),
                          ),
                        )
                      else if (viewModel.filteredProductList.isEmpty)
                        SliverFillRemaining(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: EmptyState(
                              animation: "assets/animations/empty_cart.json",
                              label: "No products yet",
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: ProductTagsSection(
                                  viewModel: viewModel,
                                  crossAxisCount: 2,
                                ),
                              ),
                              verticalSpaceMedium,
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      ...viewModel.brands.map((brand) => buildBrandChip(brand, viewModel)),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: PopularProductsSection(viewModel: viewModel),
                              ),
                            ],
                          ),
                        ),
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
                );
              },
            ),
          ),
        ),
      ),
    );


  }

  Widget _buildSliverAppBar(BuildContext context, DashboardViewModel viewModel, List<Map<String, String>> slides) {
    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverAppBar(
        expandedHeight: 250.0,
        pinned: true,
        floating: true,
        collapsedHeight: 80.0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: FlexibleSpaceBar(
          background: CarouselSlider.builder(
            options: CarouselOptions(
              height: 200,
              viewportFraction: 1.0,
              autoPlay: true,
            ),
            itemCount: slides.length,
            itemBuilder: (BuildContext context, int index, int pageIndex) {
              final slide = slides[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  slide['image']!.startsWith('http') || slide['image']!.startsWith('https')
                      ? CachedNetworkImage(
                    imageUrl: slide['image']!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
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
                        const Spacer(),
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
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Image.asset("assets/images/easy_ph_logo.png", height: 40, width: 40),
              horizontalSpaceSmall,
              ProductSearchBar(viewModel: viewModel), // Replaced with the component
            ],
          ),
        ),
      ),
    );
  }



  @override
  void onViewModelReady(DashboardViewModel viewModel) {
    super.onViewModelReady(viewModel);
    if (filter != null) {
      viewModel.setSelectedCategory(filter!.id);
    } else {
      viewModel.init();
    }
  }

  @override
  DashboardViewModel viewModelBuilder(
      BuildContext context,
      ) =>
      DashboardViewModel();
}