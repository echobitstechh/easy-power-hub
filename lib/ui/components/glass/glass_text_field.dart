import 'dart:ui';
import 'package:flutter/material.dart';
import '../../common/app_colors.dart';

class GlassTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final Widget? prefix;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final int? maxLines;
  final String? prefixText;

  const GlassTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.prefix,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.prefixText,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? kcGlassSurfaceDark : kcGlassSurfaceLight;
    final borderColor = _focused
        ? kcPrimaryColor.withOpacity(0.70)
        : (isDark ? kcGlassBorderDark : kcGlassBorderLight);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: kcPrimaryColor.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: TextFormField(
            focusNode: _focus,
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            maxLines: widget.maxLines,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? kcWhiteColor : kcBlackColor,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixText: widget.prefixText,
              hintStyle: TextStyle(
                fontSize: 14,
                color: isDark
                    ? Colors.white.withOpacity(0.4)
                    : Colors.black.withOpacity(0.4),
              ),
              prefixIcon: widget.prefix == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: widget.prefix,
                    ),
              suffixIcon: widget.suffix == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: widget.suffix,
                    ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
