import 'dart:ui';
import 'package:admin/widgets/theme_selection.dart';
import 'package:flutter/material.dart' as ma;

class ThemeState {
  final ThemeMode themeMode;

  ThemeState({required this.themeMode});

  bool get isDarkMode {
    switch (themeMode) {
      case ThemeMode.system:
        // You might want to check system brightness here
        return ma.WidgetsBinding.instance.window.platformBrightness ==
            Brightness.dark;
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
    }
  }
}
