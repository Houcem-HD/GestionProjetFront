// lib/services/role_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin/model/role.dart';
import 'dart:developer' as developer;

class RoleService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

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

  // GET all roles
  Future<List<Role>> fetchRoles() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/role'),
        headers: await _getHeaders(),
      );
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          return data.map((dynamic item) => Role.fromJson(item)).toList();
        } else if (data is Map && data.containsKey('data')) {
          return (data['data'] as List).map((dynamic item) => Role.fromJson(item)).toList();
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      } else {
        throw Exception('Failed to load roles: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      developer.log('Error fetching roles: $e');
      throw Exception('Failed to load roles: ${e.toString()}');
    }
  }

  // GET role by ID
  Future<Role> fetchRoleById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/role/$id'),
        headers: await _getHeaders(),
      );
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return Role.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load role: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      developer.log('Error fetching role: $e');
      throw Exception('Failed to load role: ${e.toString()}');
    }
  }

  // POST create role
  Future<Role> addRole(Role role) async {
    try {
      developer.log('Adding role: ${role.toJson()}');
      final response = await http.post(
        Uri.parse('$_baseUrl/role'),
        headers: await _getHeaders(),
        body: json.encode(role.toJson()),
      );
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Role.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add role: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      developer.log('Error adding role: $e');
      throw Exception('Failed to add role: ${e.toString()}');
    }
  }

  // PUT update role
  Future<Role> updateRole(Role role) async {
    if (role.id == null) throw Exception('Role ID is required for update');
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/role/${role.id}'),
        headers: await _getHeaders(),
        body: json.encode(role.toJson()..removeWhere((key, value) => key == 'id')),
      );
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return Role.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update role: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      developer.log('Error updating role: $e');
      throw Exception('Failed to update role: ${e.toString()}');
    }
  }

  // DELETE role
  Future<void> deleteRole(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/role/$id'),
        headers: await _getHeaders(),
      );
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to delete role: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      developer.log('Error deleting role: $e');
      throw Exception('Failed to delete role: ${e.toString()}');
    }
  }
}
