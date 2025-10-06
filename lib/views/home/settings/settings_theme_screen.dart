import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reloc/providers/theme_provider.dart';

class SettingsThemeScreen extends StatelessWidget {
  const SettingsThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Theme Settings")),
      body: Column(
        children: [
          RadioListTile<AppThemeMode>(
            title: const Text("System Default"),
            value: AppThemeMode.system,
            groupValue: _mapThemeMode(themeProvider.themeMode),
            onChanged: (val) {
              if (val != null) themeProvider.setTheme(val);
            },
          ),
          RadioListTile<AppThemeMode>(
            title: const Text("Light Theme"),
            value: AppThemeMode.light,
            groupValue: _mapThemeMode(themeProvider.themeMode),
            onChanged: (val) {
              if (val != null) themeProvider.setTheme(val);
            },
          ),
          RadioListTile<AppThemeMode>(
            title: const Text("Dark Theme"),
            value: AppThemeMode.dark,
            groupValue: _mapThemeMode(themeProvider.themeMode),
            onChanged: (val) {
              if (val != null) themeProvider.setTheme(val);
            },
          ),
        ],
      ),
    );
  }

  /// 🔹 Helper: Map Flutter ThemeMode to our enum
  AppThemeMode _mapThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
      case ThemeMode.system:
        return AppThemeMode.system;
    }
  }
}
