import 'package:easyph/state.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:easyph/ui/views/dashboard/productcard.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easyph/ui/views/shop/shop_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../core/data/models/category.dart';
import '../../../core/data/models/product.dart';
import '../../../utils/money_util.dart';
import '../../components/brand_chips.dart';

class ShopView extends StackedView<ShopViewModel> {
  final Category? filter;
  final bool isSpecialCategory;
  final PageController _pageController = PageController();

  ShopView({Key? key, this.filter, this.isSpecialCategory = false})
      : super(key: key);

  @override
  Widget builder(
    BuildContext context,
      ShopViewModel viewModel,
    Widget? child,
  ) {
    viewModel.filteredProductList
        .map((p) => p.brandName ?? '')
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList();

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
          onRefresh: () async {},
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
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
                                      placeholder: (context, url) =>
                                          const Center(
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
                        scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent - 200) {
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
                                          if (productTextEditingValue.text ==
                                              '') {
                                            return const Iterable<
                                                Product>.empty();
                                          }
                                          return viewModel.filteredProductList
                                              .where((Product product) {
                                            final query =
                                                productTextEditingValue.text
                                                    .toLowerCase();
                                            return (product.productName !=
                                                        null &&
                                                    product.productName!
                                                        .toLowerCase()
                                                        .contains(query)) ||
                                                (product.brandName != null &&
                                                    product.brandName!
                                                        .toLowerCase()
                                                        .contains(query));
                                          });
                                        },
                                        displayStringForOption:
                                            (Product product) =>
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
                                                  topLeft:
                                                      Radius.circular(25.0),
                                                  topRight:
                                                      Radius.circular(25.0)),
                                            ),
                                            backgroundColor:
                                                Colors.black.withOpacity(0.7),
                                            builder: (BuildContext context) {
                                              return ProductCard(
                                                  product: value);
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
                                              color: uiMode.value ==
                                                      AppUiModes.dark
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
                                        optionsViewBuilder:
                                            (BuildContext context,
                                                AutocompleteOnSelected<Product>
                                                    onSelected,
                                                Iterable<Product> options) {
                                          return Material(
                                            elevation: 4,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                  maxHeight: 100),
                                              child: ListView.builder(
                                                padding: EdgeInsets.zero,
                                                itemCount: options.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  final Product product =
                                                      options.elementAt(index);
                                                  return ListTile(
                                                    leading: product.images !=
                                                            null
                                                        ? Image.network(
                                                            product
                                                                .images!.first,
                                                            width: 40,
                                                            height: 40,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : const Icon(
                                                            Icons.image,
                                                            size: 40),
                                                    title: Text(
                                                        product.productName ??
                                                            ""),
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
                                      onSelected: (String value) {},
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
                                          ...brands
                                              .map((brand) => PopupMenuItem(
                                                    value: brand,
                                                    child: Text(brand),
                                                  )),
                                        ];
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              verticalSpaceMedium,
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: viewModel.brands.map((brand) {
                                    return buildBrandChip( brand, viewModel);
                                  }).toList(),
                                ),
                              ),
                              popularDrawsSlider(context, viewModel),
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

  Widget popularDrawsSlider(
      BuildContext context, ShopViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kcDarkGreyColor // Slightly lighter black for contrast
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
                                  ? kcDarkGreyColor // Slightly lighter black for contrast
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          kcSecondaryColor),
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
  void onViewModelReady(ShopViewModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.init();
  }

  @override
  void onDispose(ShopViewModel viewModel) {
    _pageController.dispose();
  }

  @override
  ShopViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ShopViewModel();
}
