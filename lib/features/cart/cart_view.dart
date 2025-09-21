import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../core/data/models/cart_item.dart';
import '../../core/utils/money_util.dart';
import '../../state.dart';
import '../../ui/common/app_colors.dart';
import '../../ui/common/ui_helpers.dart';
import '../../ui/components/empty_state.dart';
import 'cart_viewmodel.dart';


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
          "My Cart",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kcWhiteColor,
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
            animation: "assets/animations/payment_process.json",
            label: "Payment is processing...",
          ),
        )
            : _CartContent(viewModel: viewModel),
      ),
    );
  }

  @override
  void onViewModelReady(CartViewModel viewModel) {
    viewModel.fetchOnlineCart();
    viewModel.getRaffleSubTotal();
    super.onViewModelReady(viewModel);
  }

  @override
  CartViewModel viewModelBuilder(BuildContext context) => CartViewModel();
}

class _CartContent extends StatefulWidget {
  final CartViewModel viewModel;

  const _CartContent({required this.viewModel});

  @override
  State<_CartContent> createState() => _CartContentState();
}

class _CartContentState extends State<_CartContent> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel.hasItems && widget.viewModel.shouldShowAnimation()) {
      _showAnimation = true;
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
      );

      // Animate the offset from 0 to -30
      _animation = Tween<double>(begin: 0, end: -30).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );

      _animationController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _animationController.reverse().then((_) {
              _animationController.dispose();
              _showAnimation = false;
              widget.viewModel.setAnimationShown();
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    if (mounted && _animationController.isAnimating) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
        color: uiMode.value == AppUiModes.dark ? kcDarkGreyColor : kcWhiteColor,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<List<CartItem>>(
                valueListenable: cart,
                builder: (context, cartItems, child) {
                  if (cartItems.isEmpty) {
                    return const EmptyState(
                      animation: "assets/animations/empty_cart.json",
                      label: "Your cart is empty.",
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      CartItem item = cartItems[index];

                      if (index == 0 && _showAnimation) {
                        return AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_animation.value, 0),
                              child: _buildCartItem(context, widget.viewModel, item),
                            );
                          },
                        );
                      }
                      return _buildCartItem(context, widget.viewModel, item);
                    },
                  );
                },
              ),
            ),
            if (cart.value.isNotEmpty) _buildProceedToPaySection(context, widget.viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartViewModel viewModel, CartItem item) {
    return Dismissible(
      key: Key(item.product?.id ?? UniqueKey().toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        viewModel.removeItem(item);
        locator<SnackbarService>().showSnackbar(
            message: "${item.product?.productName} removed from cart.", duration: const Duration(seconds: 3)
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red[400],
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: uiMode.value == AppUiModes.light ? kcWhiteColor : kcMediumGrey,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildProductImage(item),
                horizontalSpaceSmall,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product?.productName ?? 'Product Name',
                        style: GoogleFonts.bricolageGrotesque(
                          textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
                          ),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      verticalSpaceTiny,
                      Text(
                        MoneyUtils().formatAmount(_calculateItemTotal(item)),
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildQuantityControl(viewModel, item),
              ],
            ),
            if (_shouldShowInstallmentOptions(item)) ...[
              verticalSpaceSmall,
              _buildInstallmentOptions(viewModel, item),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(CartItem item) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: (item.product?.images != null && item.product!.images!.isNotEmpty)
              ? item.product!.images![0]
              : 'https://via.placeholder.com/120',
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(color: Colors.white),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.error, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityControl(CartViewModel viewModel, CartItem item) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            if ((item.quantity ?? 0) > 1) {
              viewModel.modifyCartQuantity(item, "decrement");
            }
          },
          icon: const Icon(Icons.remove_circle_outline, size: 24),
          color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
        ),
        Text(
          "${item.quantity ?? 0}",
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
            ),
          ),
        ),
        IconButton(
          onPressed: () => viewModel.modifyCartQuantity(item, "increment"),
          icon: const Icon(Icons.add_circle_outline, size: 24),
          color: kcPrimaryColor,
        ),
      ],
    );
  }

  bool _shouldShowInstallmentOptions(CartItem item) {
    return item.product?.installment == true && (item.product?.installmentFrequency ?? 0) > 0;
  }

  Widget _buildInstallmentOptions(CartViewModel viewModel, CartItem item) {
    final installmentFrequency = item.product?.installmentFrequency ?? 0;
    final selectedFrequency = viewModel.selectedInstallments[item.product?.id] ?? item.installmentFrequency ?? 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Installments:",
          style: GoogleFonts.redHatDisplay(
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: List.generate(installmentFrequency, (i) {
              final frequency = i + 1;
              final isSelected = selectedFrequency == frequency;

              return ChoiceChip(
                label: Text("${frequency}x"),
                backgroundColor: uiMode.value == AppUiModes.light ? Colors.grey[200] : kcDarkGreyColor,
                selectedColor: kcPrimaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? kcWhiteColor : (uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor),
                  fontSize: 12,
                ),
                selected: isSelected,
                onSelected: (_) {
                  viewModel.selectInstallmentOption(item, frequency);
                },
              );
            }),
          ),
        ),
      ],
    );
  }

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
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: viewModel.isBusy
            ? _buildLoadingShimmer()
            : _buildPricingSection(context, viewModel),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: uiMode.value == AppUiModes.dark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: uiMode.value == AppUiModes.dark ? Colors.grey[600]! : Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                color: uiMode.value == AppUiModes.dark ? Colors.grey[700]! : Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerRow(double width1, double width2) {
    return Row(
      children: [
        Container(
          width: width1,
          height: 16,
          color: uiMode.value == AppUiModes.dark ? Colors.grey[700]! : Colors.white,
        ),
        const SizedBox(width: 8),
        Container(
          width: width2,
          height: 16,
          color: uiMode.value == AppUiModes.dark ? Colors.grey[700]! : Colors.white,
        ),
      ],
    );
  }

  Widget _buildPricingSection(BuildContext context, CartViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
          _buildCheckoutButton(context, viewModel),
        ],
      ),
    );
  }

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
              fontWeight: label == "Total" ? FontWeight.bold : FontWeight.w500,
              fontSize: label == "Total" ? 16 : 14,
              color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
            ),
          ),
          horizontalSpaceTiny,
          Text(
            amount,
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                fontSize: fontSize,
                color: color ?? (uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor),
                fontWeight: fontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, CartViewModel viewModel) {
    return InkWell(
      onTap: () {
        //todo uncomment after creating checkout page
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => CheckoutView(
        //       cartSubtotal: viewModel.cartSubtotal,
        //       cartDiscount: viewModel.cartDiscount,
        //       cartItems: cart.value,
        //       calculatedFinalTotal: viewModel.cartFinalTotal,
        //     ),
        //   ),
        // );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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
        ),
        child: Text(
          "Checkout",
          style: GoogleFonts.redHatDisplay(
            textStyle: const TextStyle(
              color: kcWhiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}