import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../core/data/models/cart_item.dart';
import '../../core/utils/money_util.dart';
import '../../state.dart';
import '../../ui/bottom_sheets/favourite/favourite_bottom_sheet.dart';
import '../../ui/common/app_colors.dart';
import '../../ui/common/ui_helpers.dart';
import '../../ui/components/empty_state.dart';
import '../../ui/components/glass/glass_button.dart';

import 'cart_viewmodel.dart';
import 'checkout/checkout_view.dart';

class CartView extends StackedView<CartViewModel> {
  const CartView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CartViewModel viewModel,
    Widget? child,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? kcDarkBgGradient : kcLightBgGradient,
          ),
        ),
        child: Column(
          children: [
            _GlassCartAppBar(viewModel: viewModel),
            // ── Pay-Now floating banner ──────────────────────────────────
            ValueListenableBuilder(
              valueListenable: payNowOrder,
              builder: (context, order, _) {
                if (order == null ||
                    order.id == dismissedPayNowId.value) {
                  return const SizedBox.shrink();
                }
                return Container(
                  margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                        width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFF59E0B).withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Order #${order.orderNumber} Approved',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Pay ${MoneyUtils().formatAmount(order.totalPrice)} to process delivery',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () =>
                            viewModel.payNowForOrder(context, order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          minimumSize: const Size(0, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Pay Now',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 16, color: Colors.white70),
                        padding: const EdgeInsets.only(left: 4),
                        constraints: const BoxConstraints(),
                        onPressed: () =>
                            dismissedPayNowId.value = order.id,
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: RefreshIndicator(
                color: kcSecondaryColor,
                onRefresh: () async => viewModel.refreshData(),
                child: viewModel.isPaymentProcessing.value
                    ? const Center(
                        child: EmptyState(
                          animation: 'assets/animations/payment_process.json',
                          label: 'Payment is processing...',
                        ),
                      )
                    : _CartContent(viewModel: viewModel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onViewModelReady(CartViewModel viewModel) {
    viewModel.refreshData();
    super.onViewModelReady(viewModel);
  }

  @override
  CartViewModel viewModelBuilder(BuildContext context) => CartViewModel();
}

// â”€â”€ Glass app bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _GlassCartAppBar extends StatelessWidget {
  final CartViewModel viewModel;
  const _GlassCartAppBar({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 20,
            right: 8,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? kcGlassSurfaceDark
                : kcGlassSurfaceLight,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? kcGlassBorderDark
                    : kcGlassBorderLight,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    activeHomeTab.value = 0;
                  }
                },
                color: Theme.of(context).brightness == Brightness.dark
                    ? kcWhiteColor
                    : kcBlackColor,
              ),
              Expanded(
                child: Text(
                  'My Cart',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'HostGrotesk',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? kcWhiteColor
                        : kcBlackColor,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_rounded, color: Colors.red),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => FractionallySizedBox(
                      heightFactor: 0.9,
                      child: FavoritesBottomSheet(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Cart content â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CartContent extends StatefulWidget {
  final CartViewModel viewModel;
  const _CartContent({required this.viewModel});

  @override
  State<_CartContent> createState() => _CartContentState();
}

class _CartContentState extends State<_CartContent>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _shakeAnimation =
        Tween<double>(begin: 0, end: -30).animate(_shakeController);

    if (widget.viewModel.hasItems && widget.viewModel.shouldShowAnimation()) {
      _showAnimation = true;
      _shakeController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _shakeController.reverse().then((_) {
              _shakeController.dispose();
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
    if (_shakeController.isAnimating) _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ValueListenableBuilder<List<CartItem>>(
            valueListenable: cart,
            builder: (context, cartItems, child) {
              if (cartItems.isEmpty) {
                return const EmptyState(
                  animation: 'assets/animations/empty_cart.json',
                  label: 'Your cart is empty.',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  if (index == 0 && _showAnimation) {
                    return AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: _buildGlassCartItem(context, item),
                      ),
                    );
                  }
                  return _buildGlassCartItem(context, item);
                },
              );
            },
          ),
        ),
        if (cart.value.isNotEmpty)
          _buildCheckoutFooter(context, widget.viewModel),
      ],
    );
  }

  Widget _buildGlassCartItem(BuildContext context, CartItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dismissible(
      key: Key(item.product?.id ?? UniqueKey().toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.viewModel.removeItem(item),
      background: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          color: Colors.red.shade400,
          child: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? kcGlassSurfaceDark : kcGlassSurfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImage(item),
                    horizontalSpaceSmall,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product?.productName ?? 'Product',
                            style: TextStyle(fontFamily: 'HostGrotesk',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.isUnavailable == true) ...[
                            verticalSpaceTiny,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.amber.withOpacity(0.5)),
                              ),
                              child: const Text(
                                'Item Requested',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ],
                          verticalSpaceTiny,
                          Text(
                            MoneyUtils().formatAmount(
                              _calculateItemTotal(item),
                            ),
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: kcSecondaryColor,
                            ),
                          ),
                          if (item.product?.installmentDeposit != null) ...[
                            verticalSpaceTiny,
                            Builder(
                              builder: (_) {
                                final raw = item.product!.installmentDeposit;
                                final val = raw is int
                                    ? raw
                                    : int.tryParse(raw.toString()) ?? 0;
                                return Text(
                                  'Down: ${MoneyUtils().formatAmount(val)}',
                                  style: GoogleFonts.roboto(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: kcPrimaryColor,
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _buildQuantityControl(widget.viewModel, item),
                        GestureDetector(
                          onTap: () => widget.viewModel.removeItem(item),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_shouldShowInstallmentOptions(item)) ...[
                  verticalSpaceSmall,
                  _buildInstallmentOptions(widget.viewModel, item),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(CartItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: (item.product?.images?.isNotEmpty == true)
            ? item.product!.images![0]
            : '',
        width: 68,
        height: 68,
        fit: BoxFit.cover,
        placeholder: (ctx, url) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(color: Colors.white, width: 68, height: 68),
        ),
        errorWidget: (ctx, url, e) => Container(
          width: 68,
          height: 68,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildQuantityControl(CartViewModel viewModel, CartItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QtyButton(
          icon: Icons.remove_rounded,
          onTap: () {
            if ((item.quantity ?? 0) > 1) {
              viewModel.modifyCartQuantity(item, 'decrement');
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '${item.quantity ?? 0}',
            style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        _QtyButton(
          icon: Icons.add_rounded,
          onTap: () => viewModel.modifyCartQuantity(item, 'increment'),
          accent: true,
        ),
      ],
    );
  }

  bool _shouldShowInstallmentOptions(CartItem item) =>
      item.product?.installment == true &&
      (item.product?.installmentFrequency ?? 0) > 0;

  Widget _buildInstallmentOptions(CartViewModel viewModel, CartItem item) {
    final freq = item.product?.installmentFrequency ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected =
        viewModel.selectedInstallments[item.product?.id] ??
        item.installmentFrequency ??
        1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Installments:',
          style: TextStyle(fontFamily: 'HostGrotesk',
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: List.generate(freq, (i) {
              final f = i + 1;
              final picked = selected == f;
              return ChoiceChip(
                label: Text('${f}x'),
                selected: picked,
                selectedColor: kcSecondaryColor,
                backgroundColor: isDark ? kcGlassSurfaceDark : Colors.grey[100],
                labelStyle: TextStyle(
                  color: picked
                      ? kcBlackColor
                      : (isDark ? kcWhiteColor : kcBlackColor),
                  fontSize: 11,
                ),
                onSelected: (_) => viewModel.selectInstallmentOption(item, f),
              );
            }),
          ),
        ),
      ],
    );
  }

  int _calculateItemTotal(CartItem item) {
    final price = double.tryParse(item.product?.salePrice ?? '0') ?? 0.0;
    return (price * (item.quantity ?? 0)).toInt();
  }

  Widget _buildCheckoutFooter(BuildContext context, CartViewModel viewModel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: isDark ? kcGlassSurfaceDark : kcGlassSurfaceLight,
            border: Border(
              top: BorderSide(
                color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
                width: 1,
              ),
            ),
          ),
          child: viewModel.isBusy
              ? _buildLoadingShimmer()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _priceRow('Subtotal',
                            MoneyUtils().formatAmount(viewModel.cartSubtotal)),
                        _priceRow(
                          'Discount',
                          '- ${MoneyUtils().formatAmount(viewModel.cartDiscount)}',
                          color: Colors.green,
                        ),
                        _priceRow(
                          'Total',
                          MoneyUtils().formatAmount(viewModel.cartFinalTotal),
                          bold: true,
                          size: 18,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 130,
                      child: GlassButton(
                        label: 'Checkout',
                        height: 52,
                        onTap: () {
                          if (!userLoggedIn.value) {
                            _showSignInSheet(context);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutView(
                                  cartSubtotal: viewModel.cartSubtotal,
                                  cartDiscount: viewModel.cartDiscount,
                                  cartItems: cart.value,
                                  calculatedFinalTotal: viewModel.cartFinalTotal,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _showSignInSheet(BuildContext context) {
    final isDark = uiMode.value == AppUiModes.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(Icons.lock_open_rounded, size: 40, color: kcSecondaryColor),
            const SizedBox(height: 16),
            Text(
              'Almost there!',
              style: TextStyle(
                fontFamily: 'HostGrotesk',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Just sign in to complete your order.\nYour cart is saved and ready to go.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                label: 'Sign In',
                height: 52,
                onTap: () {
                  Navigator.pop(context);
                  locator<NavigationService>().navigateTo(Routes.login);
                },
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Maybe later',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    final isDark = uiMode.value == AppUiModes.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _shimmerRow(70, 60),
              const SizedBox(height: 8),
              _shimmerRow(70, 60),
              const SizedBox(height: 8),
              _shimmerRow(50, 80),
            ],
          ),
          Container(
            width: 130,
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.white,
              borderRadius: BorderRadius.circular(26),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerRow(double w1, double w2) {
    final isDark = uiMode.value == AppUiModes.dark;
    return Row(
      children: [
        Container(
            width: w1,
            height: 14,
            color: isDark ? Colors.grey[700] : Colors.white),
        const SizedBox(width: 8),
        Container(
            width: w2,
            height: 14,
            color: isDark ? Colors.grey[700] : Colors.white),
      ],
    );
  }

  Widget _priceRow(
    String label,
    String amount, {
    Color? color,
    bool bold = false,
    double size = 13,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: bold ? 15 : 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.roboto(
              fontSize: size,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? kcSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Small qty +/- button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool accent;
  const _QtyButton({required this.icon, required this.onTap, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: accent ? kcSecondaryColor.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: accent ? kcSecondaryColor : null,
        ),
      ),
    );
  }
}

