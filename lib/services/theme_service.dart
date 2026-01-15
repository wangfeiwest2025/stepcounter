import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeOption {
  system,
  light,
  dark,
}

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  final _themeController = StreamController<ThemeModeOption>();
  Stream<ThemeModeOption> get themeStream => _themeController.stream;

  ThemeModeOption _currentMode = ThemeModeOption.system;
  ThemeModeOption get currentMode => _currentMode;

  static const String _themeKey = 'theme_mode';

  Future<void> initialize() async {
    await _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey) ?? 'system';
    _currentMode = ThemeModeOption.values.firstWhere(
      (e) => e.toString() == 'ThemeModeOption.$themeString',
      orElse: () => ThemeModeOption.system,
    );
    _themeController.sink.add(_currentMode);
  }

  Future<void> setTheme(ThemeModeOption mode) async {
    _currentMode = mode;
    _themeController.sink.add(mode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString().split('.').last);
  }

  ThemeMode getThemeMode(ThemeModeOption option) {
    switch (option) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
      default:
        return ThemeMode.system;
    }
  }

  void dispose() {
    _themeController.close();
  }
}
