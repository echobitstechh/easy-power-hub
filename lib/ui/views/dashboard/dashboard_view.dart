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

  final GlobalKey _tagsSectionKey = GlobalKey();
  final ScrollController _listController = ScrollController();

  void _scrollTagsIntoView() {
    final ctx = _tagsSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
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
      ),
    );
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








  @override
  void onViewModelReady(DashboardViewModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.init();
  }

  @override
  void onDispose(DashboardViewModel viewModel) {
  }

  @override
  DashboardViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DashboardViewModel();
}


