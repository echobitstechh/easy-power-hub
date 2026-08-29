import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/data/models/cart_item.dart';
import '../../../../state.dart';
import '../../../../ui/common/app_colors.dart';
import '../home_viewmodel.dart';

class BottomNavBar extends StatelessWidget {
  final HomeViewModel viewModel;

  const BottomNavBar({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<List<CartItem>>(
      valueListenable: cart,
      builder: (context, cartItems, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xCC161B2E)
                      : const Color(0xEEFFFFFF),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.30 : 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavItem(
                      filledIcon: 'home.svg',
                      outlinedIcon: 'home_outline.svg',
                      label: 'Home',
                      index: 0,
                      viewModel: viewModel,
                      isDark: isDark,
                    ),
                    _NavItem(
                      filledIcon: 'shopicon.svg',
                      outlinedIcon: 'shopicon.svg',
                      label: 'Shop',
                      index: 1,
                      viewModel: viewModel,
                      isDark: isDark,
                    ),
                    _CartNavItem(
                      viewModel: viewModel,
                      cartItems: cartItems,
                      isDark: isDark,
                    ),
                    _NavItem(
                      filledIcon: 'engineering.svg',
                      outlinedIcon: 'engineering.svg',
                      label: 'Services',
                      index: 3,
                      viewModel: viewModel,
                      isDark: isDark,
                    ),
                    _NavItem(
                      filledIcon: 'menu.svg',
                      outlinedIcon: 'menu_outline.svg',
                      label: 'Profile',
                      index: 4,
                      viewModel: viewModel,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final String filledIcon;
  final String outlinedIcon;
  final String label;
  final int index;
  final HomeViewModel viewModel;
  final bool isDark;

  const _NavItem({
    required this.filledIcon,
    required this.outlinedIcon,
    required this.label,
    required this.index,
    required this.viewModel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = viewModel.selectedTab == index;

    return GestureDetector(
      onTap: () => viewModel.changeSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? kcPrimaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: SvgPicture.asset(
                'assets/icons/${isSelected ? filledIcon : outlinedIcon}',
                height: 20,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? kcPrimaryColor
                      : (isDark
                          ? kcWhiteColor.withOpacity(0.45)
                          : kcMediumGrey),
                  BlendMode.srcIn,
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 3),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: kcPrimaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartNavItem extends StatelessWidget {
  final HomeViewModel viewModel;
  final List<CartItem> cartItems;
  final bool isDark;

  const _CartNavItem({
    required this.viewModel,
    required this.cartItems,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = viewModel.selectedTab == 2;

    return GestureDetector(
      onTap: () => viewModel.changeSelected(2),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? kcPrimaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: SvgPicture.asset(
                'assets/icons/buy.svg',
                height: 20,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? kcPrimaryColor
                      : (isDark
                          ? kcWhiteColor.withOpacity(0.45)
                          : kcMediumGrey),
                  BlendMode.srcIn,
                ),
              ),
            ),
            if (cartItems.isNotEmpty)
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: kcPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${cartItems.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
