import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeUtil {
  static Future<String?> selectDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String dateFormat = 'dd/MM/yyyy',
  }) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode
                ? const ColorScheme.dark(
                    primary: Colors.orange,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Colors.orange,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
            dialogBackgroundColor:
                isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      return DateFormat(dateFormat).format(picked);
    }
    return null;
  }

  static Future<String?> selectTime(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode
                ? const ColorScheme.dark(
                    primary: Colors.orange,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Colors.orange,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
            dialogBackgroundColor:
                isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      return picked.format(context);
    }
    return null;
  }

  /// Converts date from one format to another
  static String convertDateFormat(
    String dateString, {
    String fromFormat = 'dd/MM/yyyy',
    String toFormat = 'yyyy-MM-dd',
  }) {
    try {
      final parsedDate = DateFormat(fromFormat).parse(dateString);
      return DateFormat(toFormat).format(parsedDate);
    } catch (e) {
      return dateString;
    }
  }
}