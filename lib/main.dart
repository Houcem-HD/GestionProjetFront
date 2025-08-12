import 'package:admin/constants.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/login.dart';
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
    return ChangeNotifierProvider(
      create: (_) => MenuAppController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Admin Panel',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: bgColor,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
              .apply(bodyColor: Colors.white),
          canvasColor: secondaryColor,
        ),
        home: initialRoute,
        routes: {
          '/login': (context) => LoginScreen(),
          '/main': (context) => MainScreen(),
        },
      ),
    );
  }
}
