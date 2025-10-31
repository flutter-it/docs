// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
abstract class ThemeProvider {
  ThemeData getTheme();
}

class LightThemeProvider implements ThemeProvider {
  @override
  ThemeData getTheme() => ThemeData.light();
}

class DarkThemeProvider implements ThemeProvider {
  @override
  ThemeData getTheme() => ThemeData.dark();
}

class HighContrastThemeProvider implements ThemeProvider {
  @override
  ThemeData getTheme() => ThemeData(brightness: Brightness.light);
}

class ThemePickerDialog extends StatelessWidget {
  const ThemePickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final allThemes = getIt.getAll<ThemeProvider>();
    print('allThemes: $allThemes');
    // Returns: [LightThemeProvider, DarkThemeProvider, HighContrastThemeProvider]

    return ListView(
      children: allThemes.map((themeProvider) {
        return ListTile(
          title: Text(themeProvider.getTheme().toString()),
          onTap: () {
            // Apply theme
          },
        );
      }).toList(),
    );
  }
}

void main() {
  getIt.enableRegisteringMultipleInstancesOfOneType();

  // Unnamed - available to getAll()
  getIt.registerSingleton<ThemeProvider>(LightThemeProvider());
  getIt.registerSingleton<ThemeProvider>(DarkThemeProvider());

  // Named - accessible individually or via getAll()
  getIt.registerSingleton<ThemeProvider>(
    HighContrastThemeProvider(),
    instanceName: 'highContrast',
  );

  // Access high contrast theme directly
  final highContrastTheme = getIt<ThemeProvider>(instanceName: 'highContrast');
  print('highContrastTheme: $highContrastTheme');
  print('High contrast theme: $highContrastTheme');
}
// #endregion example
