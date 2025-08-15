import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  bool _isDarkMode = true;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeController() {
    _loadThemeFromPrefs();
  }
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    _saveThemeToPrefs(); // Remove await since we don't need to wait
  }
  
  void _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }
  
  Future<void> _saveThemeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
  
  ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: const Color(0xFF2697FF),
      scaffoldBackgroundColor: Colors.grey[50],
      canvasColor: Colors.white,
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        titleLarge: TextStyle(color: Colors.black87),
        titleMedium: TextStyle(color: Colors.black87),
      ),
      iconTheme: const IconThemeData(color: Colors.black54),
    );
  }
  
  ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: const Color(0xFF2697FF),
      scaffoldBackgroundColor: const Color(0xFF212332),
      canvasColor: const Color(0xFF2A2D3E),
      cardColor: const Color(0xFF2A2D3E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
    );
  }
}
