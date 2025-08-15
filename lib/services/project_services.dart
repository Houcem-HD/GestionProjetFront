import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin/model/projet.dart';

class ProjectService {
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

  Future<List<Project>> fetchProjects() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/projets'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Project.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load projects: ${response.statusCode} ${response.body}');
    }
  }

  Future<Project> fetchProjectById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/projets/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200 || response.statusCode == 200) {
      return Project.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load project: ${response.statusCode} ${response.body}');
    }
  }

  Future<Project> addProject(Project projet) async {
    print('Adding project: ${projet.toJson()}');
    final response = await http.post(
      Uri.parse('$_baseUrl/projets'),
      headers: await _getHeaders(),
      body: json.encode(projet.toJson()),
    );

    if (response.statusCode == 200) {
      return Project.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add project: ${response.statusCode} ${response.body}');
    }
  }

  Future<Project> updateProject(Project projet) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/projets/${projet.id}'),
      headers: await _getHeaders(),
      body: json.encode(projet.toJson()),
    );

    if (response.statusCode == 200) {
      return Project.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update project: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteProject(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/projets/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete project: ${response.statusCode} ${response.body}');
    }
  }

  Future<Project> validateProject(int id) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/projets/$id/validate'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return Project.fromJson(responseData['project']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to validate project');
    }
  }

  Future<Project> invalidateProject(int id) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/projets/$id/invalidate'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return Project.fromJson(responseData['project']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to invalidate project');
    }
  }
}
