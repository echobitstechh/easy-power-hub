import 'dart:ui';
import 'package:flutter/material.dart';
import '../../common/app_colors.dart';

/// Use this as the root widget inside any showModalBottomSheet builder to apply
/// the liquid glass treatment.
class GlassBottomSheetBg extends StatelessWidget {
  final Widget child;
  final double topRadius;
  final EdgeInsetsGeometry? padding;

  const GlassBottomSheetBg({
    super.key,
    required this.child,
    this.topRadius = 28,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xCC161B2E) : const Color(0xF0FFFFFF);
    final border   = isDark ? kcGlassBorderDark : kcGlassBorderLight;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
            border: Border(
              top: BorderSide(color: border, width: 1),
              left: BorderSide(color: border, width: 0.5),
              right: BorderSide(color: border, width: 0.5),
            ),
          ),
          padding: padding ?? const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: child,
        ),
      ),
    );
  }
}
