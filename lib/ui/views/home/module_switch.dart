import 'package:easy_power/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ModuleSwitch extends StatefulWidget {
  final bool isRafflesSelected;
  final Function(bool) onToggle;

  const ModuleSwitch({super.key, 
    required this.isRafflesSelected,
    required this.onToggle,
  });

  @override
  _ModuleSwitchState createState() => _ModuleSwitchState();
}

class _ModuleSwitchState extends State<ModuleSwitch> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(13.0),
        border: Border.all(color: Colors.transparent, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Raffles Button
          _buildOption(
            context: context,
            text: 'Solar Energy',
            icon: 'ticket_star.svg',
            isSelected: widget.isRafflesSelected,
            onTap: () => widget.onToggle(!widget.isRafflesSelected),
          ),

          // AfriShop Button
          _buildOption(
            context: context,
            text: 'Electronics',
            icon: 'bag.svg',
            isSelected: !widget.isRafflesSelected,
            onTap: () => widget.onToggle(false),
          ),
          // AfriShop Button
          _buildOption(
            context: context,
            text: 'Services',
            icon: 'bag.svg',
            isSelected: !widget.isRafflesSelected,
            onTap: () => widget.onToggle(false),
          ),

        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String text,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.transparent, // Interior color remains transparent
          borderRadius: BorderRadius.circular(13.0),
          border: Border.all(
            color: isSelected ? kcPrimaryColor : Colors.transparent,
            width: 2.0, // Set the width as needed
          ),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/icons/$icon',
                color: isSelected ? kcPrimaryColor : kcBlackColor,
              height: 20,
            ),
            // Icon(icon, color: isSelected ? kcSecondaryColor : kcPrimaryColor),
            const SizedBox(width: 8.0),
            Text(
              text,
              style: const TextStyle(
                color: kcBlackColor,
                  fontSize: 13
              ),
            ),
          ],
        ),
      ),
    );
  }
}
