import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../core/data/models/category.dart';
import '../../ui/common/ui_helpers.dart';
import '../../ui/components/brand_chips.dart';
import '../../ui/components/empty_state.dart';
import '../../ui/components/shimmer_loading.dart';
import '../dashboard/presentation/dashboard_viewmodel.dart';
import '../dashboard/presentation/widgets/popular_products_section.dart';
import '../dashboard/presentation/widgets/product_tags_section.dart';

class ShopView extends StackedView<DashboardViewModel> {
  final Category? filter;
  final bool isSpecialCategory;

  const ShopView({
    Key? key,
    this.filter,
    this.isSpecialCategory = false,
  }) : super(key: key);

  @override
  Widget builder(
      BuildContext context,
      DashboardViewModel viewModel,
      Widget? child,
      ) {
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
      body: RefreshIndicator(
        onRefresh: () async {
          await viewModel.getProducts(isRefresh: true);
        },
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
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
                ),
              ),
            ];
          },
          body: Builder(
            builder: (BuildContext context) {
              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  // Re-implemented the load more logic
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
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            if (viewModel.isBusy)
                              const DashboardShimmer()
                            else if (viewModel.filteredProductList.isEmpty)
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.1,
                                child: const EmptyState(
                                  animation: "empty_cart.json",
                                  label: "No products yet",
                                ),
                              )
                            else
                              Column(
                                children: [
                                  ProductTagsSection(
                                    viewModel: viewModel,
                                    crossAxisCount: 2,
                                  ),
                                  verticalSpaceMedium,
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        ...viewModel.brands.map((brand) => buildBrandChip(brand, viewModel)),
                                      ],
                                    ),
                                  ),
                                  verticalSpaceMedium,
                                  PopularProductsSection(viewModel: viewModel),
                                ],
                              ),
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
                  ],
                ),
              );
            },
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