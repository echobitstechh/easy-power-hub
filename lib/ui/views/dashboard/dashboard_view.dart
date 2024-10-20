import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:easy_power/ui/common/app_colors.dart';
import 'package:easy_power/ui/common/ui_helpers.dart';
import 'package:easy_power/ui/views/shop/productcard.dart';
import 'package:stacked/stacked.dart';
import 'dashboard_viewmodel.dart';

// class DashboardView extends StackedView<DashboardViewModel> {
//   DashboardView({Key? key}) : super(key: key);
//
//
//   @override
//   Widget builder(
//     BuildContext context,
//     DashboardViewModel viewModel,
//     Widget? child,
//   ) {
//     final Color primaryColor = kcPrimaryColor;
//
//     final List<String> names = [
//       'All ',
//       'Iron',
//       'Refrigirator ',
//       'Solar Panel ',
//       'Hybrid Solar '
//     ];
//     return Scaffold(
//         body: RefreshIndicator(
//             onRefresh: () async {
//               await viewModel.refreshData();
//             },
//             child: ListView(children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Discover',
//                       style: TextStyle(
//                         fontSize: 22,
//                       ),
//                       softWrap: true,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           horizontalSpaceSmall,
//                           GestureDetector(
//                             onTap: () {
//                               // Define the action when the avatar is tapped
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(50),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey.withOpacity(0.5),
//                                     blurRadius: 7,
//                                     offset: Offset(
//                                         0, 3), // changes position of shadow
//                                   ),
//                                 ],
//                               ),
//                               child: CircleAvatar(
//                                 child: Icon(Icons.shopping_cart_outlined,
//                                     size: 25, color: Colors.black),
//                                 radius: 18,
//                                 backgroundColor: kcWhiteColor,
//                               ),
//                             ),
//                           ),
//                           horizontalSpaceSmall,
//                           GestureDetector(
//                             onTap: () {
//                               // Define the action when the avatar is tapped
//                             },
//                             child: CircleAvatar(
//                               child: Icon(Icons.person_2_outlined,
//                                   size: 25, color: Colors.black),
//                               radius: 25,
//                               backgroundColor: Colors.grey.shade200,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8.0),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(16.0),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           decoration: InputDecoration(
//                             hintText: 'Search',
//                             border: InputBorder.none,
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.search),
//                         onPressed: () {
//                           // Handle search button press
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Card(
//                           color: kcPrimaryColor,
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Container(
//                                       width:
//                                           150, // Set the width to control text wrapping
//                                       child: const Text(
//                                         'Best Full Solar Installation',
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                           color: kcWhiteColor,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         softWrap: true,
//                                       ),
//                                     ),
//                                     Container(
//                                       width:
//                                           200, // Set the width to control text wrapping
//                                       child: Text(
//                                         'Light out your world',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           color: kcWhiteColor,
//                                         ),
//                                         softWrap: true,
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: ElevatedButton(
//                                         onPressed: () {},
//                                         style: ElevatedButton.styleFrom(
//                                           foregroundColor: kcBlackColor,
//                                           backgroundColor: kcWhiteColor,
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 12.0, horizontal: 24.0),
//                                           textStyle: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 16,
//                                           ),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(8.0),
//                                           ),
//                                         ),
//                                         child: Text("Check now"),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(right: 8.0),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.only(
//                                       topLeft: Radius.circular(15),
//                                       topRight: Radius.circular(15),
//                                     ),
//                                     image: DecorationImage(
//                                       image: AssetImage(
//                                           "assets/images/Mercury-10KVA-Solar-System-1 2.png"),
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                   height: 150,
//                                   width: 130,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Align(
//                         alignment: Alignment.bottomCenter,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             IndicatorDot(isActive: true),
//                             const SizedBox(width: 8),
//                             IndicatorDot(isActive: false),
//                           ],
//                         ),
//                       ),
//                     ),
//                      Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 16.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Categories',
//                             style: TextStyle(
//                               fontSize: 16,
//                             ),
//                           ),
//                           Text(
//                             'See all',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: kcPrimaryColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.all(16.0),
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           children: List.generate(names.length, (index) {
//                             return GestureDetector(
//                               onTap: () {
//                                 viewModel.selectedIndex = index;
//                               },
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: 8.0, horizontal: 16.0),
//                                 margin: EdgeInsets.symmetric(horizontal: 4.0),
//                                 decoration: BoxDecoration(
//                                   color: viewModel.selectedIndex == index
//                                       ? primaryColor
//                                       : kcWhiteColor,
//                                   border: Border.all(color: Colors.grey),
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                                 child: Text(
//                                   names[index],
//                                   style: TextStyle(
//                                     color: viewModel.selectedIndex == index
//                                         ? Colors.white
//                                         : Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }),
//                         ),
//                       ),
//                     ),
//                     GridView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2, // Number of columns in the grid
//                         crossAxisSpacing: 10.0,
//                         mainAxisSpacing: 0.0,
//                         childAspectRatio:
//                             0.9, // Adjusts the height of the items relative to their width
//                       ),
//                       itemCount: viewModel.productList.length,
//                       itemBuilder: (context, index) {
//                         final item = viewModel.productList[index];
//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Card containing image and rating
//                             Container(
//                               margin: const EdgeInsets.all(8.0),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey.withOpacity(0.5),
//                                     spreadRadius: 2,
//                                     blurRadius: 5,
//                                     offset: Offset(
//                                         0, 3), // changes position of shadow
//                                   ),
//                                 ],
//                               ),
//                               child: Stack(
//                                 children: [
//                                   // Product image
//                                   ClipRRect(
//                                     borderRadius: const BorderRadius.only(
//                                       topLeft: Radius.circular(12),
//                                       topRight: Radius.circular(12),
//                                     ),
//                                     child: CachedNetworkImage(
//                                       placeholder: (context, url) =>
//                                           const Center(
//                                         child: CircularProgressIndicator(
//                                           strokeWidth:
//                                               2.0, // Make the loader thinner
//                                           valueColor: AlwaysStoppedAnimation<
//                                                   Color>(
//                                               kcSecondaryColor), // Change the loader color
//                                         ),
//                                       ),
//                                       imageUrl: item.images?.first ??
//                                           'https://via.placeholder.com/120',
//                                       height: 140,
//                                       width: double.infinity,
//                                       fit: BoxFit.cover,
//                                       errorWidget: (context, url, error) =>
//                                           const Icon(Icons.error),
//                                       fadeInDuration:
//                                           const Duration(milliseconds: 500),
//                                       fadeOutDuration:
//                                           const Duration(milliseconds: 300),
//                                     ),
//                                   ),
//                                   // Rating badge at the top right corner
//                                   Positioned(
//                                     top: 8,
//                                     right: 8,
//                                     child: Container(
//                                       padding:
//                                           EdgeInsets.symmetric(horizontal: 8.0),
//                                       decoration: BoxDecoration(
//                                         color: kcDarkGreyColor.withOpacity(0.8),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           const Icon(
//                                             Icons.star,
//                                             color: kcStarColor,
//                                             size: 16,
//                                           ),
//                                           Text(
//                                             item.rating.toString(),
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 14,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             // Title
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8.0, vertical: 4.0),
//                               child: Text(
//                                 item.productName ?? 'Product name',
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             // Price
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 12.0),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'N${item.price}' ?? "N0",
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       color: kcPrimaryColor,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => ProductCard(),
//                                         ),
//                                       );
//                                     },
//                                     child: Container(
//                                       padding: const EdgeInsets.all(
//                                           8.0), // Add some padding if needed
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: const Icon(
//                                         Icons.shopping_cart_outlined,
//                                         size: 16,
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     )
//                   ],
//                 ),
//                 ),
//               );
//   }
//
//   @override
//   void onDispose(DashboardViewModel viewModel) {
//     viewModel.dispose();
//   }
//
//   @override
//   void onViewModelReady(DashboardViewModel viewModel) {
//     viewModel.init();
//     super.onViewModelReady(viewModel);
//   }
//
//   @override
//   DashboardViewModel viewModelBuilder(BuildContext context) =>
//       DashboardViewModel();
// }

final List<String> names = [
  'All ',
  'Iron',
  'Refrigirator ',
  'Solar Panel ',
  'Hybrid Solar '
];

class DashboardView extends StackedView<DashboardViewModel> {
  DashboardView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context,
      DashboardViewModel viewModel,
      Widget? child,
      ) {
    final Color primaryColor = kcPrimaryColor;

    return DefaultTabController(
      length: 3, // The number of tabs you want
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text('Dashboard'),
        //   backgroundColor: kcPrimaryColor,
        // ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Discover',
                    style: TextStyle(
                      fontSize: 22,
                    ),
                    softWrap: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        horizontalSpaceSmall,
                        GestureDetector(
                          onTap: () {
                            // Define the action when the avatar is tapped
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              child: Icon(Icons.shopping_cart_outlined,
                                  size: 25, color: Colors.black),
                              radius: 18,
                              backgroundColor: kcWhiteColor,
                            ),
                          ),
                        ),
                        horizontalSpaceSmall,
                        GestureDetector(
                          onTap: () {
                            // Define the action when the avatar is tapped
                          },
                          child: CircleAvatar(
                            child: Icon(Icons.person_2_outlined,
                                size: 25, color: Colors.black),
                            radius: 25,
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        // Handle search button press
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Add SegmentedTabControl here
            verticalSpaceSmall,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SegmentedTabControl(
                splashColor: Colors.grey.shade300,
                indicatorDecoration: BoxDecoration(
                  color: kcPrimaryColor, // Sets the indicator color
                  borderRadius: BorderRadius.circular(10), // Customize the indicator shape
                ),                tabTextColor: Colors.black45,
                selectedTabTextColor: Colors.white,
                tabs: [
                  SegmentTab(
                    label: 'Solar energy system',
                  ),
                  SegmentTab(
                    label: 'Lighting eelectronics',
                  ),
                  SegmentTab(
                    label: 'Services',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // First tab with your existing dashboard content
                  RefreshIndicator(
                    onRefresh: () async {
                      await viewModel.refreshData();
                    },
                    child: ListView(children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Card(
                            color: kcPrimaryColor,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width:
                                        150, // Set the width to control text wrapping
                                        child: const Text(
                                          'Best Full Solar Installation',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: kcWhiteColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          softWrap: true,
                                        ),
                                      ),
                                      Container(
                                        width:
                                        200, // Set the width to control text wrapping
                                        child: Text(
                                          'Light out your world',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: kcWhiteColor,
                                          ),
                                          softWrap: true,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: kcBlackColor,
                                            backgroundColor: kcWhiteColor,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12.0, horizontal: 24.0),
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          child: Text("Check now"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "assets/images/Mercury-10KVA-Solar-System-1 2.png"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    height: 150,
                                    width: 130,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IndicatorDot(isActive: true),
                              const SizedBox(width: 8),
                              IndicatorDot(isActive: false),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Categories',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'See all',
                              style: TextStyle(
                                fontSize: 14,
                                color: kcPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(names.length, (index) {
                              return GestureDetector(
                                onTap: () {
                                  viewModel.selectedIndex = index;
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                                  decoration: BoxDecoration(
                                    color: viewModel.selectedIndex == index
                                        ? primaryColor
                                        : kcWhiteColor,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    names[index],
                                    style: TextStyle(
                                      color: viewModel.selectedIndex == index
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of columns in the grid
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 0.0,
                          childAspectRatio:
                          0.9, // Adjusts the height of the items relative to their width
                        ),
                        itemCount: viewModel.productList.length,
                        itemBuilder: (context, index) {
                          final item = viewModel.productList[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Card containing image and rating
                              Container(
                                margin: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Product image
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                        const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth:
                                            2.0, // Make the loader thinner
                                            valueColor: AlwaysStoppedAnimation<
                                                Color>(
                                                kcSecondaryColor), // Change the loader color
                                          ),
                                        ),
                                        imageUrl: item.images?.first ??
                                            'https://via.placeholder.com/120',
                                        height: 140,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                        fadeInDuration:
                                        const Duration(milliseconds: 500),
                                        fadeOutDuration:
                                        const Duration(milliseconds: 300),
                                      ),
                                    ),
                                    // Rating badge at the top right corner
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                        decoration: BoxDecoration(
                                          color: kcDarkGreyColor.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: kcStarColor,
                                              size: 16,
                                            ),
                                            Text(
                                              item.rating.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Title
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Text(
                                  item.productName ?? 'Product name',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Price
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'N${item.price}' ?? "N0",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: kcPrimaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductCard(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                            8.0), // Add some padding if needed
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.shopping_cart_outlined,
                                          size: 16,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    ],
                    ),
                  ),

                  // Second tab (Account) - empty for now
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'MG Solar Panel' ,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.cancel_outlined,
                                    size: 16,
                                  )
                                ],
                              ),
                              horizontalSpaceSmall,
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lighting' ,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.cancel_outlined,
                                    size: 16,
                                  )
                                ],
                              ),
                              horizontalSpaceSmall,
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'CCTV' ,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.cancel_outlined,
                                    size: 16,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of columns in the grid
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 0.0,
                            childAspectRatio:
                            0.9, // Adjusts the height of the items relative to their width
                          ),
                          itemCount: viewModel.productList.length,
                          itemBuilder: (context, index) {
                            final item = viewModel.productList[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Card containing image and rating
                                Container(
                                  margin: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Product image
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) =>
                                          const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth:
                                              2.0, // Make the loader thinner
                                              valueColor: AlwaysStoppedAnimation<
                                                  Color>(
                                                  kcSecondaryColor), // Change the loader color
                                            ),
                                          ),
                                          imageUrl: item.images?.first ??
                                              'https://via.placeholder.com/120',
                                          height: 140,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                          fadeInDuration:
                                          const Duration(milliseconds: 500),
                                          fadeOutDuration:
                                          const Duration(milliseconds: 300),
                                        ),
                                      ),
                                      // Rating badge at the top right corner
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            color: kcDarkGreyColor.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: kcStarColor,
                                                size: 16,
                                              ),
                                              Text(
                                                item.rating.toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Title
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  child: Text(
                                    item.productName ?? 'Product name',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Price
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'N${item.price}' ?? "N0",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: kcPrimaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProductCard(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(
                                              8.0), // Add some padding if needed
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.shopping_cart_outlined,
                                            size: 16,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        )

                      ],
                    ),
                  ),

                  // Third tab (Settings) - empty for now
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(10), // Adding padding around the list
                      children: [
                        // Service 1
                        buildServiceItem(
                          'assets/images/girl.png',
                          'Site Suitability Evaluation',
                          '\$29.99',
                        ),
                        buildServiceItem(
                          'assets/images/girl.png',
                          'Panel Cleaning',
                          '\$19.99',
                        ),
                        buildServiceItem(
                          'assets/images/girl.png',
                          'Inverter Installation',
                          '\$39.99',
                        ),
                      ],
                    ),
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildServiceItem(String imagePath, String serviceName, String price) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10), // Spacing between cards
      elevation: 5, // Adds shadow to the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners
      ),
      child: Padding(
        padding: EdgeInsets.all(10), // Padding inside the card
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8), // Rounded corners for the image
              child: Image.asset(
                imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10), // Space between image and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                // Handle your click actions here
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 'Edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'Delete',
                    child: Text('Delete'),
                  ),
                ];
              },
              icon: Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void onDispose(DashboardViewModel viewModel) {
    viewModel.dispose();
  }

  @override
  void onViewModelReady(DashboardViewModel viewModel) {
    viewModel.init();
    super.onViewModelReady(viewModel);
  }

  @override
  DashboardViewModel viewModelBuilder(BuildContext context) =>
      DashboardViewModel();
}

class IndicatorDot extends StatelessWidget {
  final bool isActive;
  const IndicatorDot({super.key, required this.isActive});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? Colors.orange : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
