import 'package:easyph/core/data/models/cart_item.dart';
import 'package:easyph/core/data/models/raffle_cart_item.dart';
import 'package:easyph/state.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:easyph/ui/components/empty_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';
import '../../../utils/money_util.dart';
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
                  borderRadius: const BorderRadius.only(
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
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
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
                                                                  (item.product?.images !=
                                                                              null &&
                                                                          item
                                                                              .product!
                                                                              .images!
                                                                              .isNotEmpty)
                                                                      ? item
                                                                          .product!
                                                                          .images![0]
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
                                                                  MoneyUtils().formatAmount(((item.product?.salePrice !=
                                                                                  null &&
                                                                              item.quantity !=
                                                                                  null)
                                                                          ? (double.parse(item
                                                                                  .product!
                                                                                  .salePrice!) *
                                                                              item.quantity!)
                                                                          : 0)
                                                                      .toInt()),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                    fontSize: 16,
                                                                    color: uiMode
                                                                                .value ==
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
                                                            viewModel
                                                                .removeItem(item);
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
                                                                if (item.quantity! >
                                                                    1) {
                                                                  viewModel
                                                                      .modifyCartQuantity(
                                                                          item,
                                                                          "decrement");
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
                                                                viewModel
                                                                    .modifyCartQuantity(
                                                                        item,
                                                                        "increment");
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
                                                                child: const Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Icon(
                                                                    Icons.add,
                                                                    size: 18,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),

                                                  ],
                                                ),
                                                if (item.product?.installment == true &&
                                                    item.product?.installmentFrequency != null)
                                                  Row(
                                                  children: [
                                                    Text(
                                                      "Installment Options",
                                                      style: GoogleFonts
                                                          .redHatDisplay(
                                                        textStyle:
                                                            const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    horizontalSpaceSmall,
                                                    Padding(
                                                        padding: const EdgeInsets.only(top: 8.0),
                                                        child: Wrap(
                                                          spacing: 8,
                                                          children: List.generate(
                                                            item.product!.installmentFrequency!,
                                                                (i) {
                                                              final selectedFrequency = viewModel.selectedInstallments[item.product!.id] ?? item.installmentFrequency ?? 1;

                                                              return ChoiceChip(
                                                                label: Text("${i + 1}x"),
                                                                backgroundColor: Colors.grey.shade200,
                                                                selectedColor: kcPrimaryColor,
                                                                selected: selectedFrequency == (i + 1),
                                                                onSelected: (_) {
                                                                  viewModel.selectInstallmentOption(item, i + 1);
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                )

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
          color: uiMode.value == AppUiModes.dark ? kcMediumGrey : kcWhiteColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, -4), // Shadow for the top edge
            ),
          ],
        ),
        child: viewModel.isLoading
            ?Shimmer.fromColors(
          baseColor: uiMode.value == AppUiModes.dark
              ? Colors.grey[800]!
              : Colors.grey[300]!,
          highlightColor: uiMode.value == AppUiModes.dark
              ? Colors.grey[600]!
              : Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtotal shimmer
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 16,
                      color: uiMode.value == AppUiModes.dark
                          ? Colors.grey[700]!
                          : Colors.white,
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 16,
                      color: uiMode.value == AppUiModes.dark
                          ? Colors.grey[700]!
                          : Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Discount shimmer
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 16,
                      color: uiMode.value == AppUiModes.dark
                          ? Colors.grey[700]!
                          : Colors.white,
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 16,
                      color: uiMode.value == AppUiModes.dark
                          ? Colors.grey[700]!
                          : Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Total shimmer
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 20,
                      color: uiMode.value == AppUiModes.dark
                          ? Colors.grey[700]!
                          : Colors.white,
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 80,
                      height: 24,
                      color: uiMode.value == AppUiModes.dark
                          ? Colors.grey[700]!
                          : Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Checkout button shimmer
                Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    color: uiMode.value == AppUiModes.dark
                        ? Colors.grey[700]!
                        : Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Subtotal:",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                        horizontalSpaceTiny,
                        Text(
                          MoneyUtils().formatAmount(viewModel.cartSubtotal),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          "Discount:",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                        horizontalSpaceTiny,
                        Text(
                          "- ${MoneyUtils().formatAmount(viewModel.cartDiscount)}",
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        horizontalSpaceTiny,
                        Text(
                          MoneyUtils().formatAmount(viewModel.cartFinalTotal),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        horizontalSpaceLarge,
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Checkout(viewModel: viewModel),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: kcPrimaryColor,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, -2),
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
              )
            ],
          ),
        ),
      ),
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
