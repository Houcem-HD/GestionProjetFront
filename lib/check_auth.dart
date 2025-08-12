import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin/screens/main/main_screen.dart'; // Import MainScreen
import 'package:admin/login.dart'; // Import LoginScreen
import 'dart:convert';

class CheckAuthScreen extends StatelessWidget {
  const CheckAuthScreen({super.key});

  Future<bool> checkAuth() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        print('No token found');
        return false;
      }

      // Call the Laravel check-auth endpoint
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/check-auth'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        bool isAuthenticated = data['authenticated'] ?? false;
        print('User authenticated: $isAuthenticated');
        return isAuthenticated;
      } else {
        print('Check auth failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error checking auth: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth Screen')),
      body: FutureBuilder<bool>(
        future: checkAuth(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          bool isAuthenticated = snapshot.data ?? false;

          // Navigate based on authentication status
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (isAuthenticated) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            }
          });

          return Center(
            child: Text(
              isAuthenticated ? 'Authenticated!' : 'Not Authenticated',
            ),
          );
        },
      ),
    );
  }
}