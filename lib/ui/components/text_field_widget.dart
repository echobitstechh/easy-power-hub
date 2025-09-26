import 'package:flutter/material.dart';
import 'package:easy_ph/ui/common/app_colors.dart';

import '../../state.dart';


/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///


class TextFieldWidget extends StatelessWidget {
  final String? label;
  final String hint;
  final TextEditingController controller;
  final Function? validator;
  final Widget? suffix;
  final Widget? leading;
  final bool obscureText;
  final TextInputType? inputType;
  final bool readOnly;
  final Function? onChanged;
  final Color? fillColor;
  final bool filled;
  final InputBorder? border;
  final Color? borderColor; // New property for a flexible border color

  const TextFieldWidget({
    Key? key,
    this.label,
    this.validator,
    this.inputType,
    required this.hint,
    required this.controller,
    this.readOnly = false,
    this.obscureText = false,
    this.onChanged,
    this.leading,
    this.suffix,
    this.fillColor,
    this.filled = false,
    this.border,
    this.borderColor, // Initialize the new border color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the border color based on theme or a passed parameter
    final defaultBorderColor = borderColor ?? (uiMode.value == AppUiModes.light ? kcBlackColor.withOpacity(0.22) : kcWhiteColor.withOpacity(0.22));

    return TextFormField(
      readOnly: readOnly,
      controller: controller,
      onChanged: onChanged as void Function(String value)?,
      cursorColor: uiMode.value == AppUiModes.light ? kcBlackColor : kcWhiteColor,
      style: TextStyle(
          fontSize: 14),
      validator: validator as String? Function(String?)?,
      obscureText: obscureText,
      keyboardType: inputType,
      decoration: InputDecoration(
        // Use the passed `filled` and `fillColor`, with defaults if not provided
        filled: filled,
        fillColor: filled ? fillColor : Colors.transparent,

        // Prioritize the passed `border`, then fall back to a dynamic one
        enabledBorder: border ?? OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: defaultBorderColor),
        ),
        focusedBorder: border ?? OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: defaultBorderColor),
        ),
        border: border ?? OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: defaultBorderColor),
        ),

        labelText: hint,
        labelStyle: TextStyle(
            fontSize: 14),
        prefixIcon: leading == null
            ? null
            : Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: leading,
        ),
        suffixIcon: suffix == null
            ? null
            : Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: suffix,
        ),
      ),
    );
  }
}