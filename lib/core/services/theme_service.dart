import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../app/app.locator.dart';
import '../utils/local_stotage.dart';
import '../utils/local_store_dir.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeService with ListenableServiceMixin {
  final _localStorage = locator<LocalStorage>();
  
  // Make this a ReactiveValue
  final _themeMode = ReactiveValue<ThemeMode>(ThemeMode.system);
  
  ThemeMode get themeMode => _themeMode.value;
  
  ThemeService() {
    listenToReactiveValues([_themeMode]);
  }

  /// Initialize theme from storage
  Future<void> init() async {
    final savedTheme = await _localStorage.fetch(LocalStorageDir.themeMode);
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'light':
          _themeMode.value = ThemeMode.light;
          break;
        case 'dark':
          _themeMode.value = ThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode.value = ThemeMode.system;
          break;
      }
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    
    await _localStorage.save(LocalStorageDir.themeMode, modeString);
  }

  /// Toggle between light and dark (skips system)
  Future<void> toggleTheme() async {
    if (_themeMode.value == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  /// Get current theme as string for display
  String get currentThemeString {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}