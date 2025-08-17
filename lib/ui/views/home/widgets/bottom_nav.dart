
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/data/models/cart_item.dart';
import '../../../../state.dart';
import '../../../common/app_colors.dart';
import '../home_viewmodel.dart';

class BottomNavBar extends StatelessWidget {
  final HomeViewModel viewModel;

  const BottomNavBar({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CartItem>>(
      valueListenable: cart,
      builder: (context, _, __) {
        Color iconColor = Colors.grey;
        Color selectedColor = kcSecondaryColor;

        List<BottomNavigationBarItem> items = navItems(iconColor, selectedColor);

        int currentIndex = viewModel.selectedTab;

        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: uiMode.value == AppUiModes.dark
              ? kcDarkGreyColor
              : kcWhiteColor,
          selectedLabelStyle: TextStyle(color: selectedColor),
          selectedItemColor: selectedColor,
          unselectedItemColor: iconColor,
          onTap: (index) => viewModel.changeSelected(index),
          currentIndex: currentIndex,
          items: items,
        );
      },
    );
  }

  List<BottomNavigationBarItem> navItems(Color iconColor, Color selectedColor) {
    return [
      BottomNavigationBarItem(
        icon: _navBarItemIcon('home.svg', 'home_outline.svg', viewModel.selectedTab == 0, iconColor),
        label: "Home",
      ),
      BottomNavigationBarItem(
        icon: _navBarItemIcon('shopicon.svg', 'shopicon.svg', viewModel.selectedTab == 1, iconColor),
        label: "Shop",
      ),
      BottomNavigationBarItem(
        icon: _navBarItemWithCounter('buy.svg', 'buy.svg',  viewModel.selectedTab == 2, cart, iconColor),
        label: "Cart",
      ),
      BottomNavigationBarItem(
        icon: _navBarItemIcon('engineering.svg', 'engineering.svg', viewModel.selectedTab == 3, iconColor),
        label: "Services",
      ),
      BottomNavigationBarItem(
        icon: _navBarItemIcon('menu.svg', 'menu_outline.svg', viewModel.selectedTab == 4, iconColor),
        label: "Profile",
      ),
    ];
  }

  Widget _navBarItemIcon(String filledIcon, String outlinedIcon, bool isSelected, Color iconColor) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? kcSecondaryColor.withOpacity(0.2) : Colors.transparent,
      ),
      child: SvgPicture.asset(
        'assets/icons/${isSelected ? filledIcon : outlinedIcon}',
        height: 16, // Icon size
      ),
    );
  }

  Widget _navBarItemWithCounter(String icon, String filledIcon, bool isSelected, ValueListenable<List<dynamic>> counterListenable, Color color) {
    return ValueListenableBuilder<List<dynamic>>(
      valueListenable: counterListenable,
      builder: (context, value, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _navBarItemIcon(filledIcon, icon, isSelected, color),
            if (value.isNotEmpty)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${value.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}