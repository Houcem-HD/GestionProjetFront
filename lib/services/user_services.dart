import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin/model/user.dart';

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
    final response = await http.get(
      Uri.parse('$_baseUrl/user'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 201) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => User.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load users: ${response.statusCode} ${response.body}');
    }
  }

  // GET user by ID
  Future<User> fetchUserById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user: ${response.statusCode} ${response.body}');
    }
  }

  // POST create user
  Future<User> addUser(User user) async {
    print('Adding user: ${user.toJson()}');
    final response = await http.post(
      Uri.parse('$_baseUrl/user'),
      headers: await _getHeaders(),
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add user: ${response.statusCode} ${response.body}');
    }
  }

  // PUT update user
  Future<User> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/user/${user.id}'),
      headers: await _getHeaders(),
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update user: ${response.statusCode} ${response.body}');
    }
  }

  // DELETE user
  Future<void> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/user/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to delete user: ${response.statusCode} ${response.body}');
    }
  }
}
