import 'package:admin/constants.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/controllers/theme_controller.dart'; // Added theme controller import
import 'package:admin/login.dart';
import 'package:admin/screens/projets/list_projects.dart';
import 'package:admin/screens/main/main_screen.dart'; // Import MainScreen
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check authentication status
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  bool isAuthenticated = false;

  if (token != null && token.isNotEmpty) {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/check-auth'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        isAuthenticated = data['authenticated'] ?? false;
      }
    } catch (e) {
      print('Error checking auth: $e');
    }
  }

  runApp(MyApp(initialRoute: isAuthenticated ? MainScreen() : LoginScreen()));
}

class MyApp extends StatelessWidget {
  final Widget initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiProvider( // Changed to MultiProvider to support theme controller
      providers: [
        ChangeNotifierProvider(create: (_) => MenuAppController()),
        ChangeNotifierProvider(create: (_) => ThemeController()), // Added theme controller
      ],
      child: Consumer<ThemeController>( // Added Consumer to listen to theme changes
        builder: (context, themeController, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Admin Panel',
            theme: themeController.lightTheme.copyWith( // Use theme controller's light theme
              textTheme: GoogleFonts.poppinsTextTheme(themeController.lightTheme.textTheme),
            ),
            darkTheme: themeController.darkTheme.copyWith( // Use theme controller's dark theme
              textTheme: GoogleFonts.poppinsTextTheme(themeController.darkTheme.textTheme),
            ),
            themeMode: themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light, // Dynamic theme mode
            home: initialRoute,
            routes: {
              '/login': (context) => LoginScreen(),
              '/main': (context) => ProjectListScreen(),
            },
          );
        },
      ),
    );
  }
}
