import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proplus/core/theme/theme_provider.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final themeMode = prefs.getString('themeMode');
    return ThemeMode.values.firstWhere((e)=> e.name == themeMode,
      orElse: ()=> ThemeMode.light
    );
  }

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveTheme(state);
  }

  void setTheme(ThemeMode mode) {
    state = mode;
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('themeMode', mode.name);
  }
}
