import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/theme/app_theme.dart';

class ThemeState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isDarkMode = false;
  
  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  ThemeData get currentTheme => _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
  
  // Constructor
  ThemeState() {
    _loadThemePreference();
  }
  
  // Load theme preference (bisa dari SharedPreferences nanti)
  void _loadThemePreference() {
    // Untuk sementara default ke light mode
    // Nanti bisa diintegrasikan dengan SharedPreferences
    _themeMode = ThemeMode.light;
    _isDarkMode = false;
    notifyListeners();
  }
  
  // Toggle theme
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    _saveThemePreference();
  }
  
  // Set light theme
  void setLightTheme() {
    _isDarkMode = false;
    _themeMode = ThemeMode.light;
    notifyListeners();
    _saveThemePreference();
  }
  
  // Set dark theme
  void setDarkTheme() {
    _isDarkMode = true;
    _themeMode = ThemeMode.dark;
    notifyListeners();
    _saveThemePreference();
  }
  
  // Set theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;
    notifyListeners();
    _saveThemePreference();
  }
  
  // Save theme preference (bisa ke SharedPreferences nanti)
  void _saveThemePreference() {
    // TODO: Implement SharedPreferences untuk menyimpan preferensi theme
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setBool('isDarkMode', _isDarkMode);
    // });
  }
  
  // Get theme data berdasarkan mode
  ThemeData getThemeData(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return AppTheme.darkTheme;
      case ThemeMode.light:
        return AppTheme.lightTheme;
      case ThemeMode.system:
        // Gunakan system theme
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    }
  }
  
  // Check if current theme is dark
  bool isDarkTheme(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  // Get primary color berdasarkan theme
  Color getPrimaryColor() {
    return _isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.lightPrimaryColor;
  }
  
  // Get background color berdasarkan theme
  Color getBackgroundColor() {
    return _isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor;
  }
  
  // Get text color berdasarkan theme
  Color getTextColor() {
    return _isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;
  }
}

// Global theme state instance to be used across the app without extra deps
final ThemeState appThemeState = ThemeState();