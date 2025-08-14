// lib/services/user_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin/model/user.dart';
import 'dart:developer' as developer;

class UserService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api'; // Laravel API base URL

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET all users
  Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'), // Changed from /user to /users
        headers: await _getHeaders(),
      );
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          return data.map((dynamic item) => User.fromJson(item)).toList();
        } else if (data is Map && data.containsKey('data')) {
          return (data['data'] as List).map((dynamic item) => User.fromJson(item)).toList();
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      } else {
        throw Exception('Failed to load users: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      developer.log('Error fetching users: $e');
      throw Exception('Failed to load users: ${e.toString()}');
    }
  }

  // GET user by ID
  Future<User> fetchUserById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$id'),
        headers: await _getHeaders(),
      );
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load user: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      developer.log('Error fetching user: $e');
      throw Exception('Failed to load user: ${e.toString()}');
    }
  }

  // POST create user
  Future<User> addUser(User user) async {
    try {
      developer.log('Adding user: ${user.toJson()}');
      final response = await http.post(
        Uri.parse('$_baseUrl/user'),
        headers: await _getHeaders(),
        body: json.encode(user.toJson()),
      );
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add user: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      developer.log('Error adding user: $e');
      throw Exception('Failed to add user: ${e.toString()}');
    }
  }

  // PUT update user
  Future<User> updateUser(User user) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/user/${user.id}'),
        headers: await _getHeaders(),
        body: json.encode(user.toJson()..removeWhere((key, value) => key == 'id')),
      );
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update user else: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      developer.log('Error updating user: $e');
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  // DELETE user
  Future<void> deleteUser(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/user/$id'),
        headers: await _getHeaders(),
      );
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      if (response.statusCode == 200) { 
        return;
      } else {
        throw Exception('Failed to delete user: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      developer.log('Error deleting user: $e');
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }
}