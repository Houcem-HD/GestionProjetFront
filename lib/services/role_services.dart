import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:admin/model/role.dart';

class RoleService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<Role>> fetchRoles() async {
    final response = await http.get(Uri.parse('http://localhost:8000/api/role'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Role.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load roles: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  Future<Role> getRoleById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/role/$id'));

    if (response.statusCode == 200) {
      return Role.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load role');
    }
  }

  Future<void> addRole(Role role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/role'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(role.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add role');
    }
  }

  Future<void> updateRole(Role role) async {
    if (role.id == null) throw Exception('Role ID is required for update');

    final response = await http.put(
      Uri.parse('$baseUrl/role/${role.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(role.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update role');
    }
  }

  Future<void> deleteRole(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/role/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete role');
    }
  }
}
