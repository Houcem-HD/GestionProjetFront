import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin/model/projet.dart';

class ProjectService {
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

  // GET all projects
  Future<List<Projet>> fetchProjects() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/projets'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 201) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Projet.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load projects: ${response.statusCode} ${response.body}');
    }
  }

  // GET project by ID
  Future<Projet> fetchProjectById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/projets/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Projet.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load project: ${response.statusCode} ${response.body}');
    }
  }

  // POST create project
  Future<Projet> addProject(Projet projet) async {
    print('Adding project: ${projet.toJson()}');
    final response = await http.post(
      Uri.parse('$_baseUrl/projets'),
      headers: await _getHeaders(),
      body: json.encode(projet.toJson()),
    );

    if (response.statusCode == 201) {
      return Projet.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add project: ${response.statusCode} ${response.body}');
    }
  }

  // PUT update project
  Future<Projet> updateProject(Projet projet) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/projets/${projet.id}'),
      headers: await _getHeaders(),
      body: json.encode(projet.toJson()),
    );

    if (response.statusCode == 201) {
      return Projet.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update project: ${response.statusCode} ${response.body}');
    }
  }

  // DELETE project
  Future<void> deleteProject(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/projets/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to delete project: ${response.statusCode} ${response.body}');
    }
  }
}
