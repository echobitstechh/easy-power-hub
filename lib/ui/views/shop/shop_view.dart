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

/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

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
    List<Product> categoryProducts = viewModel.filteredProductList;
    if (filter != null) {
      categoryProducts = viewModel.filteredProductList.where((product) {
        return product.categoryId == filter?.id;
      }).toList();
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
            await viewModel.getProducts(isRefresh: true);
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
                      viewModel.getProducts();
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
                                        if (value == "All") {
                                          viewModel.setSelectedBrand("");
                                        } else {
                                          viewModel.setSelectedBrand(value);
                                        }
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
                              _buildProductTagsSection(context, viewModel),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: viewModel.filteredProductList
                                      .map((product) => product.brandName ?? '')
                                      .where((brand) => brand.isNotEmpty)
                                      .toSet()
                                      .toList()
                                      .map((brand) => _buildBrandChip(brand, viewModel))
                                      .toList(),
                                ),
                              ),
                              if (categoryProducts.isEmpty && !viewModel.isBusy)
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.5,
                                  child: const EmptyState(
                                    animation: "empty_order.json",
                                    label: "No products yet",
                                  ),
                                )
                              else
                                popularDrawsSlider(
                                    context, categoryProducts, viewModel),
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
  Widget _buildProductTagsSection(BuildContext context, ShopViewModel viewModel) {
    if (viewModel.isLoadingTags) {
      return buildTagsShimmerLoading(isSpecialCategory);
    }

    if (viewModel.tags.isEmpty) {
      return const SizedBox.shrink();
    }
    if (isSpecialCategory) {
      return SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: viewModel.tags.length,
          itemBuilder: (context, index) {
            final tag = viewModel.tags[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _buildCompactTagChip(context, tag, viewModel),
            );
          },
        ),
      );
    } else {
      return Container(
        height: 160,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.0,
          ),
          itemCount: viewModel.tags.length,
          itemBuilder: (context, index) {
            final tag = viewModel.tags[index];
            return _buildTagChip(context, tag, viewModel);
          },
        ),
      );
    }
  }  Widget _buildTagChip(BuildContext context, Tag tag, ShopViewModel viewModel) {
    final isSelected = viewModel.selectedTag?.id == tag.id;
    return InkWell(
      onTap: () {
        viewModel.setSelectedTag(isSelected ? null : tag);
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Column(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: tag.image != null && tag.image!.isNotEmpty
                    ? DecorationImage(
                  image: CachedNetworkImageProvider(tag.image!),
                  fit: BoxFit.cover,
                )
                    : null,
                color: tag.image == null || tag.image!.isEmpty
                    ? Colors.grey[200]
                    : null,
              ),
              child: tag.image == null || tag.image!.isEmpty
                  ? const Center(child: Icon(Icons.category, size: 30))
                  : null,
            ),
            // const SizedBox(height: 4),
            Text(
              tag.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? kcSecondaryColor : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCompactTagChip(BuildContext context, Tag tag, ShopViewModel viewModel) {
    final isSelected = viewModel.selectedTag?.id == tag.id;
    return InkWell(
      onTap: () {
        viewModel.setSelectedTag(isSelected ? null : tag);
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: kcSecondaryColor, width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? kcDarkGreyColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: tag.image != null && tag.image!.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: tag.image!,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  ),
                )
                    : Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.category, size: 30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tag.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? kcSecondaryColor : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
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
            childAspectRatio: 0.75,
          ),
          itemCount: productList.length,
          itemBuilder: (context, index) {
            final item = productList[index];
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kcDarkGreyColor
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
                              color: Theme.of(context).brightness ==
                                  Brightness.dark
                                  ? kcDarkGreyColor
                                  : Colors.white,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.0,
                              ),
                              borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Center(
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: MediaQuery.of(context).size.height * 0.15,
                                      width: double.infinity,
                                      color: Colors.white,
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
                                    .fitHeight,
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
                        viewModel.isNewProduct(item.createdAt ?? '')
                            ? Positioned(
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
                        )
                            : const SizedBox.shrink(),
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
                              GestureDetector(
                                onTap: () {
                                  viewModel.addToRaffleCart(item);
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
                                MoneyUtils().formatAmount(
                                    (double.tryParse(item.salePrice ?? '0.0') ??
                                        0.0)
                                        .toInt()),
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
                                          double ratingValue =
                                              item.rating ?? 0.0;
                                          return LinearGradient(
                                            stops: [
                                              ratingValue / 5,
                                              ratingValue / 5
                                            ],
                                            colors: const [
                                              Colors.amber,
                                              Colors.grey
                                            ],
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
  Widget _buildBrandChip(String brand,ShopViewModel  viewModel) {
    final availableBrands = viewModel.filteredProductList
        .map((product) => product.brandName ?? '')
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList();

    if (!availableBrands.contains(brand)) {
      return const SizedBox.shrink();
    }
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
            viewModel.selectedId,
        onSelected: (bool selected) {
          viewModel.setSelectedCategory(
              selected ? category.id : 0);
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
                : Colors.grey[100]!,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(
              30.0),
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
    // _pageController.dispose();
  }

  @override
  ShopViewModel viewModelBuilder(
      BuildContext context,
      ) =>
      ShopViewModel();
}
