
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../ui/common/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? openDrawer;
  const HomeHeader({super.key, this.openDrawer});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kcWhiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: openDrawer,
            icon: const Icon(Icons.menu, size: 31),
          ),
          SvgPicture.asset('assets/icons/logo.svg', height: 41),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFDDE7D7),
            child: Icon(Icons.person, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
