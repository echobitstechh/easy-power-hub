import 'package:easyph/core/data/models/cart_item.dart';
import 'package:easyph/state.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:easyph/ui/components/empty_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';
import '../../../utils/money_util.dart';
import 'cart_viewmodel.dart';
import '../checkout/checkout.dart';

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
          ),
        )
            : Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
            color: uiMode.value == AppUiModes.dark
                ? kcDarkGreyColor
                : kcWhiteColor,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
            child: Column(
              children: [
                Expanded(
                  child: cart.value.isEmpty
                      ? const Center(
                    child: EmptyState(
                      animation: "empty_cart.json",
                      label: "Cart Is Empty",
                    ),
                  )
                  // CHANGE 1: Fixed nested ListView structure that was causing Expanded widget conflicts
                  // Replaced nested ListView inside ListView with single ValueListenableBuilder + ListView.builder
                      : ValueListenableBuilder<List<CartItem>>(
                    valueListenable: cart,
                    builder: (context, cartItems, child) =>
                        ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            CartItem item = cartItems[index];
                            // CHANGE 2: Extracted cart item building to separate method for better organization
                            return _buildCartItem(context, viewModel, item);
                          },
                        ),
                  ),
                ),
                if (cart.value.isNotEmpty)
                  _buildProceedToPaySection(context, viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // CHANGE 3: Created separate method to build individual cart items (extracted from main builder)
  // This fixes the widget hierarchy issues and improves code organization
  Widget _buildCartItem(BuildContext context, CartViewModel viewModel, CartItem item) {
    return GestureDetector(
      onTap: () {
        viewModel.addRemoveDeleteRaffle(item);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: uiMode.value == AppUiModes.light ? kcWhiteColor : kcDarkGreyColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: uiMode.value == AppUiModes.dark
                  ? const Color(0xFFE5E5E5).withOpacity(0.1)
                  : const Color(0xFFE5E5E5).withOpacity(0.9),
              offset: const Offset(8.8, 8.8),
              blurRadius: 8.8,
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Product Image and Details
                Expanded(
                  child: Row(
                    children: [
                      // CHANGE 4: Fixed CachedNetworkImage implementation
                      // Replaced DecorationImage approach with proper CachedNetworkImage widget
                      // This prevents the Expanded widget placement issues
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: (item.product?.images != null &&
                                item.product!.images!.isNotEmpty)
                                ? item.product!.images![0]
                                : 'https://via.placeholder.com/120',
                            fit: BoxFit.cover,
                            // CHANGE 5: Added proper error handling for images
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      horizontalSpaceSmall,
                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.product?.productName ?? 'Product Name',
                              style: GoogleFonts.bricolageGrotesque(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            verticalSpaceTiny,
                            // CHANGE 6: Improved price calculation with null safety
                            // Replaced direct calculation with helper method to prevent null-related crashes
                            Text(
                              MoneyUtils().formatAmount(_calculateItemTotal(item)),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                color: uiMode.value == AppUiModes.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Actions Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        viewModel.removeItem(item);
                      },
                      child: Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.red[400],
                      ),
                    ),
                    verticalSpaceSmall,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            // CHANGE 7: Added null safety check for quantity before decrementing
                            if ((item.quantity ?? 0) > 1) {
                              viewModel.modifyCartQuantity(item, "decrement");
                            }
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              border: Border.all(color: kcLightGrey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.remove,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        horizontalSpaceSmall,
                        // CHANGE 8: Added null coalescing operator to prevent null quantity display
                        Text("${item.quantity ?? 0}"),
                        horizontalSpaceSmall,
                        InkWell(
                          onTap: () {
                            viewModel.modifyCartQuantity(item, "increment");
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              border: Border.all(color: kcLightGrey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // CHANGE 9: Improved installment options structure and null safety
            // Extracted logic to helper methods and added proper null checks
            if (_shouldShowInstallmentOptions(item))
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Installment Options:",
                      style: GoogleFonts.redHatDisplay(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    horizontalSpaceSmall,
                    // CHANGE 10: Used Expanded properly within Row (not Center) to fix ParentDataWidget error
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _buildInstallmentChips(viewModel, item),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // CHANGE 11: Created helper method to safely check installment options availability
  // Prevents null pointer exceptions when checking installment properties
  bool _shouldShowInstallmentOptions(CartItem item) {
    return item.product?.installment == true &&
        (item.product?.installmentFrequency ?? 0) > 0;
  }

  // CHANGE 12: Extracted installment chip building to separate method
  // Improved null safety and code organization
  List<Widget> _buildInstallmentChips(CartViewModel viewModel, CartItem item) {
    final installmentFrequency = item.product?.installmentFrequency ?? 0;
    // CHANGE 13: Added null safety for selectedInstallments map access
    final selectedFrequency = viewModel.selectedInstallments[item.product?.id] ??
        item.installmentFrequency ?? 1;

    return List.generate(installmentFrequency, (i) {
      final frequency = i + 1;
      final isSelected = selectedFrequency == frequency;

      return ChoiceChip(
        label: Text("${frequency}x"),
        backgroundColor: Colors.grey.shade200,
        selectedColor: kcPrimaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          // CHANGE 14: Added explicit fontSize to prevent layout issues
          fontSize: 12,
        ),
        selected: isSelected,
        onSelected: (_) {
          viewModel.selectInstallmentOption(item, frequency);
        },
      );
    });
  }

  // CHANGE 15: Created safe calculation method for item totals
  // Prevents crashes from null/invalid price values
  int _calculateItemTotal(CartItem item) {
    final price = double.tryParse(item.product?.salePrice ?? '0') ?? 0.0;
    final quantity = item.quantity ?? 0;
    return (price * quantity).toInt();
  }

  Widget _buildProceedToPaySection(BuildContext context, CartViewModel viewModel) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: uiMode.value == AppUiModes.dark ? kcMediumGrey : kcWhiteColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: viewModel.isLoading
        // CHANGE 16: Extracted shimmer loading to separate method for better organization
            ? _buildLoadingShimmer()
        // CHANGE 17: Extracted pricing section to separate method for better code structure
            : _buildPricingSection(context, viewModel),
      ),
    );
  }

  // CHANGE 18: Created separate shimmer loading widget
  // Simplified the complex shimmer structure that was causing layout issues
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // CHANGE 19: Added mainAxisSize to prevent unnecessary expansion
              mainAxisSize: MainAxisSize.min,
              children: [
                // CHANGE 20: Replaced complex shimmer rows with helper method
                _buildShimmerRow(70, 60),
                const SizedBox(height: 8),
                _buildShimmerRow(70, 60),
                const SizedBox(height: 8),
                _buildShimmerRow(50, 80),
              ],
            ),
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
    );
  }

  // CHANGE 21: Helper method for shimmer row creation to reduce code duplication
  Widget _buildShimmerRow(double width1, double width2) {
    return Row(
      children: [
        Container(
          width: width1,
          height: 16,
          color: uiMode.value == AppUiModes.dark
              ? Colors.grey[700]!
              : Colors.white,
        ),
        const SizedBox(width: 8),
        Container(
          width: width2,
          height: 16,
          color: uiMode.value == AppUiModes.dark
              ? Colors.grey[700]!
              : Colors.white,
        ),
      ],
    );
  }

  // CHANGE 22: Extracted pricing section to separate method for better organization
  Widget _buildPricingSection(BuildContext context, CartViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // CHANGE 23: Added mainAxisSize to prevent layout expansion issues
            mainAxisSize: MainAxisSize.min,
            children: [
              // CHANGE 24: Replaced repetitive code with helper method calls
              _buildPriceRow(
                "Subtotal:",
                MoneyUtils().formatAmount(viewModel.cartSubtotal),
              ),
              _buildPriceRow(
                "Discount:",
                "- ${MoneyUtils().formatAmount(viewModel.cartDiscount)}",
                color: Colors.green,
              ),
              _buildPriceRow(
                "Total",
                MoneyUtils().formatAmount(viewModel.cartFinalTotal),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          // CHANGE 25: Extracted checkout button to separate method
          _buildCheckoutButton(context, viewModel),
        ],
      ),
    );
  }

  // CHANGE 26: Helper method for consistent price row styling and layout
  Widget _buildPriceRow(
      String label,
      String amount, {
        Color? color,
        double fontSize = 14,
        FontWeight fontWeight = FontWeight.w500,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              // CHANGE 27: Added conditional styling for Total row
              fontWeight: label == "Total" ? FontWeight.bold : FontWeight.w500,
              fontSize: label == "Total" ? 16 : 14,
            ),
          ),
          horizontalSpaceTiny,
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: fontSize,
              color: color,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }

  // CHANGE 28: Extracted checkout button to separate method for better organization
  Widget _buildCheckoutButton(BuildContext context, CartViewModel viewModel) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckoutView(
              cartSubtotal: viewModel.cartSubtotal,
              cartDiscount: viewModel.cartDiscount,
              cartItems: cart.value,
              calculatedFinalTotal: viewModel.cartFinalTotal,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
        // CHANGE 29: Simplified checkout button structure (removed unnecessary Row wrapper)
        child: Text(
          "Checkout",
          style: GoogleFonts.redHatDisplay(
            textStyle: const TextStyle(
              color: kcWhiteColor,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onViewModelReady(CartViewModel viewModel) {
    viewModel.fetchOnlineCart();
    // CHANGE 30: Removed commented loadPayStackPlugin call for cleaner code
    viewModel.getRaffleSubTotal();
    super.onViewModelReady(viewModel);
  }

  @override
  // CHANGE 31: Simplified viewModelBuilder method signature
  CartViewModel viewModelBuilder(BuildContext context) => CartViewModel();
}