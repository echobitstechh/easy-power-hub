import 'package:afriprize/core/data/models/cart_item.dart';
import 'package:afriprize/core/data/models/raffle_cart_item.dart';
import 'package:afriprize/state.dart';
import 'package:afriprize/ui/common/app_colors.dart';
import 'package:afriprize/ui/common/ui_helpers.dart';
import 'package:afriprize/ui/components/empty_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../../utils/money_util.dart';
import '../../../utils/paymentModal.dart';
import '../../components/text_field_widget.dart';
import 'cart_viewmodel.dart';
import 'checkout.dart';

/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class CartView extends StackedView<CartViewModel> {
  const CartView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CartViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kcPrimaryColor,
      appBar: AppBar(
        backgroundColor: kcPrimaryColor,
        centerTitle: true,
        title: const Text(
          "My Carts",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // viewModel.itemsToDeleteRaffle.isNotEmpty
          //     ? InkWell(
          //   onTap: () {
          //     viewModel.clearRaffleCart();
          //   },
          //   child: const Padding(
          //     padding: EdgeInsets.all(20.0),
          //     child: Text(
          //       "Delete",
          //       style: TextStyle(color: Colors.red),
          //     ),
          //   ),
          // )
          //     : const SizedBox()
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await viewModel.refreshData();
        },
        child: viewModel.isPaymentProcessing.value
            ? const Center(
                child: EmptyState(
                animation: "payment_process.json",
                label: "payment processing...",
              ))
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                  color: uiMode.value == AppUiModes.dark
                      ? kcDarkGreyColor // Dark mode logo
                      : kcWhiteColor, // Set your desired background color
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                  child: Column(
                    children: [
                      // if (raffleCart.value.isNotEmpty)
                      //   Padding(
                      //     padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.start,
                      //       children: [
                      //         GestureDetector(
                      //           onTap: () {
                      //             viewModel.clearRaffleCart();
                      //           },
                      //           child: Row(
                      //             children: [
                      //               Text("Clear",
                      //                   style: GoogleFonts.redHatDisplay(
                      //                     textStyle: const TextStyle(
                      //                       fontSize: 16,
                      //                       fontWeight: FontWeight.w500,
                      //                       color: Colors.red,
                      //                     ),
                      //                   )),
                      //               SizedBox(width: 2),
                      //               Icon(
                      //                 size: 20,
                      //                 Icons.delete_outline,
                      //                 color:  uiMode.value == AppUiModes.dark
                      //                     ? kcWhiteColor
                      //                     : kcBlackColor,
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      Expanded(
                        child: cart.value.isEmpty
                            ? const EmptyState(
                                animation: "empty_cart.json",
                                label: "Cart Is Empty",
                              )
                            : ListView(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                children: [
                                  ValueListenableBuilder<List<CartItem>>(
                                    valueListenable: cart,
                                    builder: (context, value, child) =>
                                        ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: value.length,
                                      itemBuilder: (context, index) {
                                        CartItem item = value[index];
                                        return GestureDetector(
                                          onTap: () {
                                            viewModel
                                                .addRemoveDeleteRaffle(item);
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: uiMode.value ==
                                                      AppUiModes.light
                                                  ? kcWhiteColor
                                                  : kcDarkGreyColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: uiMode.value ==
                                                            AppUiModes.dark
                                                        ? Color(0xFFE5E5E5)
                                                            .withOpacity(0.1)
                                                        : Color(0xFFE5E5E5)
                                                            .withOpacity(0.9),
                                                    offset:
                                                        const Offset(8.8, 8.8),
                                                    blurRadius: 8.8)
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height: 70,
                                                        width: 70,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          image:
                                                              DecorationImage(
                                                            image:
                                                            CachedNetworkImageProvider(
                                                              (item.product?.images != null && item.product!.images!.isNotEmpty)
                                                                  ? item.product!.images![0]
                                                                  : 'https://via.placeholder.com/120',
                                                            ),

                                                                fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      horizontalSpaceSmall,
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              item.product
                                                                      ?.productName ??
                                                                  'Product Name',
                                                              style: GoogleFonts
                                                                  .bricolageGrotesque(
                                                                textStyle:
                                                                    const TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            verticalSpaceTiny,
                                                            Text(
                                                              MoneyUtils().formatAmount(((item.product?.salePrice != null &&
                                                                          item.quantity !=
                                                                              null)
                                                                      ? (double.parse(item.product!.salePrice!) *
                                                                          item.quantity!)
                                                                      : 0)
                                                                  .toInt()),
                                                              overflow: TextOverflow.ellipsis,
                                                              style:
                                                                  TextStyle(
                                                                fontSize:
                                                                    16,
                                                                color: uiMode.value ==
                                                                        AppUiModes
                                                                            .dark
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                                fontFamily:
                                                                    "Satoshi",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        viewModel.removeItem(item);
                                                      },
                                                      child: Icon(
                                                        Icons.delete,
                                                        size: 18,
                                                        color: Colors.red[100],
                                                      ),
                                                    ),
                                                    verticalSpaceSmall,
                                                    Row(
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            if (item.quantity! > 1) {
                                                              viewModel.modifyCartQuantity(item, "decrement");
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 30,
                                                            width: 30,
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color:
                                                                        kcLightGrey),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                            child: const Center(
                                                              child: Icon(
                                                                Icons.remove,
                                                                size: 18,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        horizontalSpaceSmall,
                                                        Text(
                                                            "${item.quantity!}"),
                                                        horizontalSpaceSmall,
                                                        InkWell(
                                                          onTap: () {
                                                            viewModel.modifyCartQuantity(item, "increment");
                                                          },
                                                          child: Container(
                                                            height: 30,
                                                            width: 30,
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color:
                                                                        kcLightGrey),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(5)),
                                                            child: const Align(
                                                              alignment: Alignment.center,
                                                              child: Icon(Icons.add, size: 18,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                )

                                                // Continue with other components, ensuring null checks
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      verticalSpaceSmall,
                      if (cart.value.isNotEmpty)
                        _buildProceedToPaySection(context,
                            viewModel), // This will be the bottom pinned section
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProceedToPaySection(
      BuildContext context, CartViewModel viewModel) {
    return SafeArea(
        child: Container(
      decoration: BoxDecoration(
        color: Colors.white, // Adjust the background color as needed
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300, // Adjust the border color as needed
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, -4), // Shadow for the top edge
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Total Amount",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kcPrimaryColor, // Adjust text color to match design
                    fontSize: 14, // Adjust font size to match design
                  ),
                ),
                Row(
                  children: [
                    Text(
                      MoneyUtils().formatAmount(viewModel.raffleSubTotal),
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                )
              ],
            ),
            InkWell(
              onTap: () {
                //_showPaymentModal(context, viewModel);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Checkout(
                      infoList: [],
                    ),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: kcPrimaryColor,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, -2), // Shadow for the top edge
                    ),
                  ],
                  border: Border.all(color: kcPrimaryColor),
                ),
                child: Row(
                  children: [
                    Text(
                      "Checkout",
                      style: GoogleFonts.redHatDisplay(
                        textStyle: const TextStyle(
                          color: kcWhiteColor,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildProceedToPayButton(
      BuildContext context, CartViewModel viewModel) {
    return ElevatedButton(
      onPressed: () {
        _showPaymentModal(context, viewModel);
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: kcPrimaryColor,
        backgroundColor: kcSecondaryColor, // Text color
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Button corner radius
        ),
        elevation: 0, // Remove elevation
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16, // Adjust the font size as needed
        ),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Proceed to Pay",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: "Panchang"),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.arrow_forward, // Use the appropriate icon
          ),
        ],
      ),
    );
  }

  // void _showPaymentModal(BuildContext context, CartViewModel viewModel) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (BuildContext context) {
  //     return ValueListenableBuilder<PaymentMethod>(
  //         valueListenable: viewModel.selectedPaymentMethod,
  //         builder: (context, value, child) {
  //       return DraggableScrollableSheet(
  //       expand: false,
  //       builder: (_, controller) {
  //         return ValueListenableBuilder<bool>(
  //           valueListenable: viewModel.isPaymentProcessing,
  //           builder: (context, isProcessing, child) {
  //             return PaymentModalWidget(
  //               onPaymentMethodSelected: (PaymentMethod method) {
  //                 viewModel.selectMethod(method);
  //               },
  //               onProceedWithPayment: ()  async {
  //                 viewModel.checkoutRaffle(context);
  //               },
  //               totalAmount: (viewModel.raffleSubTotal),
  //               selectedPaymentMethod: viewModel.selectedPaymentMethod.value,
  //               isPaymentProcessing: isProcessing,
  //             );
  //           });
  //       },
  //     );
  //       });
  //     },
  //   );
  // }

  void _showPaymentModal(BuildContext context, CartViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ValueListenableBuilder<PaymentMethod>(
          valueListenable: viewModel.selectedPaymentMethod,
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: PaymentModalWidget(
                onPaymentMethodSelected: (PaymentMethod method) {
                  viewModel.selectMethod(method);
                },
                onProceedWithPayment: () async {
                  viewModel.checkoutRaffle(context);
                },
                totalAmount: viewModel.raffleSubTotal,
                selectedPaymentMethod: viewModel.selectedPaymentMethod.value,
                isPaymentProcessing: viewModel.isPaymentProcessing.value,
              ),
            );
          },
        );
      },
    );
  }

  @override
  void onViewModelReady(CartViewModel viewModel) {
    viewModel.fetchOnlineCart();
    // viewModel.loadPayStackPlugin();
    viewModel.getRaffleSubTotal();
    super.onViewModelReady(viewModel);
  }

  @override
  CartViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      CartViewModel();
}
