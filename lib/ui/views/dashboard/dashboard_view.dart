import 'dart:async';
import 'package:easyph/app/app.router.dart';
import 'package:easyph/state.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:easyph/ui/views/dashboard/widget/ads_sliders.dart';
import 'package:easyph/ui/views/dashboard/productcard.dart';
import 'package:easyph/ui/views/dashboard/widgets/category_grid.dart';
import 'package:easyph/ui/views/service/service_view.dart';
import 'package:easyph/utils/money_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/app.locator.dart';
import '../../../core/data/models/category.dart';
import '../../../core/data/models/product.dart';
import '../../components/brand_chips.dart';
import '../../components/shimmer.dart';
import '../../components/tag_components.dart';
import '../../components/product_grid.dart';
import '../../components/selectable_brand_chips.dart';
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
          actions:
              _buildAppBarActions(context, viewModel.appBarLoading, viewModel),
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


  void showProductDialog({
    required BuildContext context,
    required String title,
    required List<String> products,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  verticalSpaceLarge,
                  Text(
                    title,
                    style: GoogleFonts.bricolageGrotesque(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: const Icon(Icons.lightbulb),
                        title: Text(
                          products[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (c) {
                            return ShopView();
                          }));
                          print('Selected Product: ${products[index]}');
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
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
          verticalSpaceSmall,
          const VideoBanner(),
          verticalSpaceSmall,
          Container(
            padding: const EdgeInsets.all(0),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2,
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
          verticalSpaceSmall,
          buildProductTagsSection(
              context,
              viewModel,
            sectionKey: _tagsSectionKey,              // NEW
            onAnyTagTap: _scrollTagsIntoView,
          ),
          verticalSpaceSmall,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: viewModel.brands.map((brand) {
                return buildBrandChip(brand, viewModel);
              }).toList(),
            ),
          ),
          verticalSpaceMedium,
          popularProducts(context, viewModel),
          verticalSpaceSmall,
        ],
      );
    }
  }





  // Widget _notificationIcon(
  //     int unreadCount, BuildContext context, DashboardViewModel viewModel) {
  //   print('notif count is $unreadCount');
  //   return Stack(
  //     children: [
  //       IconButton(
  //           icon: SvgPicture.asset(
  //             uiMode.value == AppUiModes.dark
  //                 ? "assets/images/dashboard_otification_white.svg" // Dark mode logo
  //                 : "assets/images/dashboard_otification.svg",
  //             width: 25,
  //             height: 25,
  //           ),
  //           onPressed: () {
  //             _showNotificationSheet(context, viewModel);
  //           }),
  //       if (unreadCount > 0)
  //         Positioned(
  //           right: 10,
  //           top: 10,
  //           child: Container(
  //             padding: const EdgeInsets.all(5),
  //             decoration: BoxDecoration(
  //               color: Colors.red,
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
  //             child: Text(
  //               unreadCount.toString(),
  //               style: const TextStyle(color: Colors.white, fontSize: 6),
  //               textAlign: TextAlign.center,
  //             ),
  //           ),
  //         ),
  //     ],
  //   );
  // }

  // void _showNotificationSheet(
  //     BuildContext context, DashboardViewModel viewModel) {
  //   // viewModel.markAllNotificationsAsRead();
  //
  //   TopModalSheet.show(
  //       context: context,
  //       isShowCloseButton: true,
  //       closeButtonRadius: 20.0,
  //       closeButtonBackgroundColor: kcSecondaryColor,
  //       child: Container(
  //         color: kcWhiteColor,
  //         padding: const EdgeInsets.all(16),
  //         height: MediaQuery.of(context).size.height * 0.5,
  //         child: Column(
  //           children: [
  //             const Text("Notifications",
  //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //             Expanded(
  //               child: ListView.builder(
  //                 itemCount: viewModel.notifications.value.length,
  //                 itemBuilder: (context, index) {
  //                   final notification = notifications.value[index];
  //                   return ListTile(
  //                     minLeadingWidth: 10,
  //                     leading: Container(
  //                       margin: const EdgeInsets.only(right: 8),
  //                       child: SvgPicture.asset(
  //                         'assets/icons/ticket_out.svg',
  //                         height: 28,
  //                       ),
  //                     ),
  //                     title: Text(
  //                       notification.subject,
  //                       style: GoogleFonts.redHatDisplay(
  //                         textStyle: const TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.w500,
  //                         ),
  //                       ),
  //                     ),
  //                     subtitle: Text(
  //                       notification.message,
  //                       style: GoogleFonts.redHatDisplay(
  //                         textStyle: const TextStyle(
  //                           fontSize: 11,
  //                           fontWeight: FontWeight.w400,
  //                           color: kcDarkGreyColor,
  //                         ),
  //                       ),
  //                     ),
  //                     trailing: notification.unread
  //                         ? const Icon(Icons.circle, color: Colors.red, size: 10)
  //                         : null,
  //                   );
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       ));
  // }




  List<Widget> _buildAppBarActions(
      BuildContext context, bool isLoading, DashboardViewModel viewModel) {
    if (isLoading) {
      // Display the shimmer effect while loading
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 0.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5.0),
                          bottomLeft: Radius.circular(5.0),
                        ),
                      ),
                      width: 80, // Adjust width for the shimmer
                      height: 20, // Adjust height for the shimmer
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ];
    } else {

      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (userLoggedIn.value == true) ...[
                // _notificationIcon(unreadCount.value, context, viewModel),
                // const SizedBox(width: 3),
                InkWell(
                  onTap: () {
                    locator<NavigationService>().navigateTo(Routes.profileView);
                  },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: (profile.value.profilePicture != null &&
                          profile.value.profilePicture!.isNotEmpty)
                          ? (profile.value.profilePicture!.startsWith('http')
                          ? CachedNetworkImageProvider(profile.value.profilePicture!)
                      as ImageProvider<Object>
                          : AssetImage(profile.value.profilePicture!)
                      as ImageProvider<Object>)
                          : const AssetImage('assets/images/display_pic.png')
                      as ImageProvider<Object>,
                      onBackgroundImageError: (exception, stackTrace) {
                        debugPrint('Failed to load profile picture: $exception');
                      },
                    )
                )
              ] else ...[
                InkWell(
                  onTap: () {
                    locator<NavigationService>().navigateTo(Routes.authView);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: kcSecondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: uiMode.value == AppUiModes.dark
                            ? kcWhiteColor
                            : kcBlackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        )
      ];
    }
  }



  @override
  void onViewModelReady(DashboardViewModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.init();
  }


  @override
  DashboardViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DashboardViewModel();
}

class RaffleRow extends StatelessWidget {
  final Raffle raffle;
  final DashboardViewModel viewModel;
  final int index;

  const RaffleRow({
    required this.raffle,
    super.key,
    required this.viewModel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    CountdownTimerController controller = CountdownTimerController(endTime: 0);
    int remainingStock = 0;
    int remainingDays = 0;
    int endTime = 0;
    // final int stockTotal = raffle.stockTotal ?? 0;
    // final int verifiedSales = raffle.verifiedSales ?? 0;
    // remainingStock = stockTotal - verifiedSales;

    DateTime now = DateTime.now();
    DateTime drawDate = DateFormat("yyyy-MM-dd")
        .parse(raffle.endDate ?? '2024-02-04T00:00:00.000Z');
    // DateTime drawDate = DateFormat("yyyy-MM-dd").parse("2024-02-04T00:00:00.000Z");
    Duration timeDifference = drawDate.difference(now);
    remainingDays = timeDifference.inDays;
// Adding the current time to the timeDifference to get the future end time
    endTime = now.add(timeDifference).millisecondsSinceEpoch;
    controller =
        CountdownTimerController(endTime: endTime, onEnd: viewModel.onEnd);

    // Check conditions to set the color and text
    Color containerColor = Colors.transparent; // Default color
    String bannerText = ''; // Default text
    if (remainingDays <= 5) {
      containerColor = Colors.blue;
      bannerText = 'Coming soon in';
    } else if (remainingStock <= 10) {
      containerColor = Colors.red;
      bannerText = 'Sold out soon \n $remainingStock item left';
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      // height: 400,
      decoration: BoxDecoration(
        color: uiMode.value == AppUiModes.light ? kcWhiteColor : kcBlackColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kcSecondaryColor),
        boxShadow: [
          BoxShadow(
            color: kcBlackColor.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 4,
          )
        ],
      ),
      child: Stack(
        children: [
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [],
          ),
          if (containerColor != Colors.transparent)
            Positioned(
              top: 0,
              left: 22,
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0)),
                  ),
                  child: Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                containerColor, // Blue color for the "Closing Soon" banner
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                bannerText,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Panchang",
                                    fontSize: 11),
                              ),
                              if (remainingDays <= 5)
                                CountdownTimer(
                                  controller: controller,
                                  onEnd: viewModel.onEnd,
                                  endTime: endTime,
                                  widgetBuilder:
                                      (_, CurrentRemainingTime? time) {
                                    if (time == null) {
                                      return const Text('in stock');
                                    }

                                    String dayText = '';
                                    if (time.days != null) {
                                      if (time.days! > 0) {
                                        dayText =
                                            '${time.days} ${time.days == 1 ? 'day' : 'days'}, ';
                                      }
                                    }
                                    String formattedHours =
                                        '${time.hours ?? 0}'.padLeft(2, '0');
                                    String formattedMin =
                                        '${time.min ?? 0}'.padLeft(2, '0');
                                    String formattedSec =
                                        '${time.sec ?? 0}'.padLeft(2, '0');

                                    return Text(
                                      '$dayText$formattedHours : $formattedMin : $formattedSec',
                                      style: const TextStyle(
                                          color: kcWhiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Panchang",
                                          fontSize: 11),
                                    );
                                  },
                                ),
                            ],
                          )),
                    ],
                  )),
            ),
        ],
      ),
    );
  }
  Future<Color?> _updateTextColor(String imageUrl) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      NetworkImage(imageUrl),
    );

    final Color dominantColor = paletteGenerator.dominantColor!.color;
    final double luminance = dominantColor.computeLuminance();

    return luminance < 0.1 ? Colors.white : Colors.black;
  }
}

class BackGroundTile extends StatelessWidget {
  final Color backgroundColor;
  final IconData icondata;

  const BackGroundTile({super.key, required this.backgroundColor, required this.icondata});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Icon(icondata, color: Colors.white),
    );
  }
}
