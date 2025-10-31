import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
abstract class ThemeProvider {
  ThemeData getTheme();
}

void setupThemes() {
  getIt.enableRegisteringMultipleInstancesOfOneType();

  // Unnamed - available to getAll()
  getIt.registerSingleton<ThemeProvider>(LightThemeProvider());
  getIt.registerSingleton<ThemeProvider>(DarkThemeProvider());

  // Named - accessible individually or via getAll()
  getIt.registerSingleton<ThemeProvider>(
    HighContrastThemeProvider(),
    instanceName: 'highContrast',
  );
}

// Get all themes for theme picker
class ThemePickerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final allThemes = getIt.getAll<ThemeProvider>();
    // Returns: [LightThemeProvider, DarkThemeProvider, HighContrastThemeProvider]

    return ListView(
      children: allThemes.map((themeProvider) {
        return ListTile(
          title: Text(themeProvider.getTheme().name),
          onTap: () => applyTheme(themeProvider.getTheme()),
        );
      }).toList(),
    );
  }
}

// Access high contrast theme directly
final highContrastTheme = getIt<ThemeProvider>(instanceName: 'highContrast');
// #endregion example
