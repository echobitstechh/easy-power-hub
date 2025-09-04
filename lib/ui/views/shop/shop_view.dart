  import 'package:easyph/state.dart';
  import 'package:easyph/ui/common/app_colors.dart';
  import 'package:easyph/ui/views/dashboard/productcard.dart';
  import 'package:cached_network_image/cached_network_image.dart';
  import 'package:carousel_slider/carousel_slider.dart';
  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:shimmer/shimmer.dart';
  import 'package:stacked/stacked.dart';
  import '../../../core/data/models/category.dart';
  import '../../../core/data/models/product.dart';
  import '../../../core/data/models/tags.dart';
  import '../../../utils/money_util.dart';
  import '../../components/empty_state.dart';
  import '../../components/shimmer.dart';
  import 'shop_viewmodel.dart';


  class ShopView extends StackedView<ShopViewModel> {
    final Category? filter;
    final bool isSpecialCategory;

    ShopView({Key? key, this.filter, this.isSpecialCategory = false}) : super(key: key);

    @override
    Widget builder(
        BuildContext context,
        ShopViewModel viewModel,
        Widget? child,
        ) {

      final specialKeys = ['solar', 'electronics', 'light'];
      final bool useCategoryScoped = filter != null &&
          specialKeys.any((k) => (filter!.name ?? '').toLowerCase().contains(k));

      List<Product> categoryProducts = viewModel.filteredProductList;
      List<Tag> categoryTags = viewModel.tags;
      List<String> categoryBrands = viewModel.filteredProductList
          .map((p) => p.brandName ?? '')
          .where((b) => b.isNotEmpty)
          .toSet()
          .toList();

      // compute scoped lists only when navigated from dashboard category tile
      if (useCategoryScoped) {
        categoryProducts = viewModel.productList.where((p) => p.categoryId == filter!.id).toList();

        categoryBrands = categoryProducts
            .map((p) => (p.brandName ?? '').trim())
            .where((b) => b.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        final Set<dynamic> productTagIds = {};
        for (final p in categoryProducts) {
          final tags = p.tags ?? [];
          for (final dynamic t in tags) {
            if (t == null) continue;
            if (t is Tag) {
              productTagIds.add(t.id);
            } else if (t is Map && t['id'] != null) {
              productTagIds.add(t['id']);
            } else if (t is int) {
              productTagIds.add(t);
            } else if (t is String) {
              final parsed = int.tryParse(t);
              productTagIds.add(parsed ?? t);
            }
          }
        }

        categoryTags = viewModel.tags
            .where((tag) => productTagIds.contains(tag.id))
            .toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      }

      if (!useCategoryScoped && filter != null) {
        categoryProducts = viewModel.filteredProductList.where((product) {
          return product.categoryId == filter?.id;
        }).toList();
      }

      if (filter != null) {
        categoryProducts = viewModel.filteredProductList.where((product) {
          return product.categoryId == filter?.id;
        }).toList();

        // final productTagIds = categoryProducts
        //     .expand((product) => product.tags != null
        //     ? product.tags!.map((tag) => tag.id)
        //     : <dynamic>[])
        //     .toSet();
        //
        // categoryTags = categoryTags
        //     .where((tag) => productTagIds.contains(tag.id))
        //     .toList();

      }

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

      return SafeArea(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          body: RefreshIndicator(
            onRefresh: () async {
            },
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverOverlapAbsorber(
                    handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
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
                          itemBuilder:
                              (BuildContext context, int index, int pageIndex) {
                            final slide = slides[index];
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                slide['image']!.startsWith('http') ||
                                    slide['image']!.startsWith('https')
                                    ? CachedNetworkImage(
                                  imageUrl: slide['image']!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                                )
                                    : Image.asset(
                                  slide['image']!,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                  const Icon(Icons.error),
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
                      if (scrollInfo is ScrollEndNotification &&
                          scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                      }
                      return false;
                    },
                    child: CustomScrollView(
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
                                SizedBox(
                                  height: 30,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Autocomplete<Product>(
                                          optionsBuilder: (TextEditingValue
                                          productTextEditingValue) {
                                            if (productTextEditingValue.text == '') {
                                              return const Iterable<Product>.empty();
                                            }
                                            return viewModel.filteredProductList
                                                .where((Product product) {
                                              final query = productTextEditingValue
                                                  .text
                                                  .toLowerCase();
                                              return (product.productName != null &&
                                                  product.productName!
                                                      .toLowerCase()
                                                      .contains(query)) ||
                                                  (product.brandName != null &&
                                                      product.brandName!
                                                          .toLowerCase()
                                                          .contains(query));
                                            });
                                          },
                                          displayStringForOption: (Product product) =>
                                          product.productName ?? '',
                                          onSelected: (Product value) {
                                            debugPrint(
                                                'You just selected ${value.productName}');
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              isDismissible: true,
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(25.0),
                                                    topRight: Radius.circular(25.0)),
                                              ),
                                              backgroundColor:
                                              Colors.black.withOpacity(0.7),
                                              builder: (BuildContext context) {
                                                return ProductCard(product: value);
                                              },
                                            );
                                          },
                                          fieldViewBuilder: (BuildContext context,
                                              TextEditingController
                                              textEditingController,
                                              FocusNode focusNode,
                                              VoidCallback onFieldSubmitted) {
                                            return Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: uiMode.value == AppUiModes.dark
                                                    ? kcMediumGrey
                                                    : kcWhiteColor,
                                                borderRadius:
                                                BorderRadius.circular(8),
                                              ),
                                              child: TextField(
                                                controller: textEditingController,
                                                focusNode: focusNode,
                                                decoration: const InputDecoration(
                                                  hintText: 'Search product...',
                                                  prefixIcon: Icon(Icons.search),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 10),
                                                ),
                                              ),
                                            );
                                          },
                                          optionsViewBuilder: (BuildContext context,
                                              AutocompleteOnSelected<Product>
                                              onSelected,
                                              Iterable<Product> options) {
                                            return Material(
                                              elevation: 4,
                                              borderRadius: BorderRadius.circular(8),
                                              child: Container(
                                                constraints:
                                                const BoxConstraints(maxHeight: 100),
                                                child: ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  itemCount: options.length,
                                                  itemBuilder: (BuildContext context,
                                                      int index) {
                                                    final Product product =
                                                    options.elementAt(index);
                                                    return ListTile(
                                                      leading: product.images != null
                                                          ? Image.network(
                                                        product.images!.first,
                                                        width: 40,
                                                        height: 40,
                                                        fit: BoxFit.cover,
                                                      )
                                                          : const Icon(Icons.image,
                                                          size: 40),
                                                      title: Text(
                                                          product.productName ?? ""),
                                                      onTap: () =>
                                                          onSelected(product),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.filter_list),
                                        onSelected: (String value) {

                                        },
                                        itemBuilder: (context) {
                                          final brands = viewModel.productList
                                              .map((product) =>
                                          product.brandName ?? "")
                                              .where((brand) => brand.isNotEmpty)
                                              .toSet()
                                              .toList();

                                          return [
                                            const PopupMenuItem(
                                                value: "All",
                                                child: Text("All Brands")),
                                            ...brands.map((brand) => PopupMenuItem(
                                              value: brand,
                                              child: Text(brand),
                                            )),
                                          ];
                                        },
                                      ),
                                    ],
                                  ),
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
        ),
      );
    }
    @override
    void onViewModelReady(ShopViewModel viewModel) {
      super.onViewModelReady(viewModel);
      viewModel.init();
    }

    @override
    void onDispose(ShopViewModel viewModel) {
      // _pageController.dispose();
    }

    @override
    ShopViewModel viewModelBuilder(
        BuildContext context,
        ) =>
        ShopViewModel();
  }
