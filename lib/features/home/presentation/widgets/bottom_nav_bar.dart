import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../ui/common/app_colors.dart';
import '../home_viewmodel.dart';

class BottomNavBar extends StatelessWidget {
  final HomeViewModel viewModel;

  const BottomNavBar({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedTab = viewModel.selectedTab;

    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: 'home',
            height: 45,
            selected: selectedTab == 0,
            onTap: () => viewModel.changeSelected(0),
          ),
          _buildNavItem(
            icon: 'search',
            selected: selectedTab == 1,
            onTap: () => viewModel.changeSelected(1),
          ),
          _buildAddButton(),
          _buildNavItem(
            icon: 'notification',
            height: 51,
            selected: selectedTab == 2,
            onTap: () => viewModel.changeSelected(2),
          ),
          _buildProfileItem(
            selected: selectedTab == 3,
            onTap: () => viewModel.changeSelected(3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required bool selected,
    double? height,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: selected
            ? BoxDecoration(
          color: kcSecondaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        )
            : null,
        child: SvgPicture.asset(
          'assets/icons/${icon}_${selected ? "filled" : "outline"}.svg',
          height: selected ? (height ?? 29) + 20 : (height ?? 29),
          // color: selected ? kcSecondaryColor.withOpacity(0.1) : kcMediumGrey,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: viewModel.clearSelectedTab,
      child: Container(
        height: 44,
        width: 44,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }


  Widget _buildProfileItem({
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: const CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(
          'https://placehold.co/64x64.png', // Replace with profile.value.profilePicture
        ),
      ),
    );
  }
}

