import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../app/app.locator.dart';
import '../../core/services/theme_service.dart';
import '../common/app_colors.dart';

class ThemeToggleViewModel extends BaseViewModel {
  final ThemeService _themeService = locator<ThemeService>();

  ThemeMode get themeMode => _themeService.themeMode;

  void toggleTheme() {
    final newMode = _themeService.themeMode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    _themeService.setThemeMode(newMode);
    notifyListeners();
  }
}

class ThemeToggleWidget extends StatelessWidget {
  const ThemeToggleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ThemeToggleViewModel>.reactive(
      viewModelBuilder: () => ThemeToggleViewModel(),
      builder: (context, model, child) {
        final isDarkMode = model.themeMode == ThemeMode.dark;

        return GestureDetector(
          onTap: model.toggleTheme,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.grey[800] 
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.light_mode,
                  size: 18,
                  color: !isDarkMode ? kcSecondaryColor : Colors.grey,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.dark_mode,
                  size: 18,
                  color: isDarkMode ? kcSecondaryColor : Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}