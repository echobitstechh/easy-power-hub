import 'package:easyph/ui/common/app_colors.dart';
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
      padding: const EdgeInsets.only(left: 20, right: 20,bottom: 20, top: 20),
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
          buildOption(
            context: context,
            text: 'Raffles',
            icon: 'ticket_star.svg',
            isSelected: widget.isRafflesSelected,
            onTap: () => widget.onToggle(!widget.isRafflesSelected),
          ),

          // AfriShop Button
          buildOption(
            context: context,
            text: 'AfriShop',
            icon: 'bag.svg',
            isSelected: !widget.isRafflesSelected,
            onTap: () => widget.onToggle(false),
          ),
        ],
      ),
    );
  }

  Widget buildOption({
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
            color: isSelected ? kcSecondaryColor : Colors.transparent,
            width: 2.0, // Set the width as needed
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/$icon',
                color: isSelected ? kcSecondaryColor : kcPrimaryColor,
              height: 20,
            ),
            // Icon(icon, color: isSelected ? kcSecondaryColor : kcPrimaryColor),
            const SizedBox(width: 8.0),
            Text(
              text,
              style: const TextStyle(
                color: kcPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Panchang",
                  fontSize: 13
              ),
            ),
          ],
        ),
      ),
    );
  }
}
