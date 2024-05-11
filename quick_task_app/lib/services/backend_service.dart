import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:quick_task_app/models/task.dart';

class BackendService {
  static const String baseURL = 'https://parseapi.back4app.com';
  static const String appID = 'rp3o7KiUvZsc2PMVIJAyB0Mf7cHZhwv3nuxg3fXr';
  static const String apiKey = 'LzEGRx7xzLfHDFNjbcbV1ceOokMfn1n3X8joXxxw';
  static final _storage = FlutterSecureStorage();

  // Authentication
  static Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseURL/login'),
      headers: _getHeaders(),
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      _saveSessionData(responseData);
      return responseData['sessionToken'];
    } else {
      throw Exception('Failed to log in');
    }
  }

  static Future<void> signOut() async {
    final token = await _storage.read(key: 'sessionToken');
    if (token == null) {
      throw Exception('Session token not found');
    }

    final response = await http.post(
      Uri.parse('$baseURL/logout'),
      headers: _getHeaders(sessionToken: token),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to sign out');
    }

    _clearSessionData();
  }

  // User Management
  static Future<bool> signup(String username, String password, String email) async {
    final response = await http.post(
      Uri.parse('$baseURL/users'),
      headers: _getHeaders(),
      body: json.encode({
        'username': username,
        'password': password,
        'email': email,
      }),
    );
    return response.statusCode == 201;
  }

  // Tasks
  static Future<List<Map<String, dynamic>>> fetchTasks() async {
    final token = await _storage.read(key: 'sessionToken');
    final response = await http.get(
      Uri.parse('$baseURL/classes/Task'),
      headers: _getHeaders(sessionToken: token),
    );
    _checkResponse(response);
    final responseData = json.decode(response.body);
    return List<Map<String, dynamic>>.from(responseData['results']);
  }

  static Future<void> addTask(Task task) async {
    final token = await _storage.read(key: 'sessionToken');
    final objectId = await _storage.read(key: 'objectId');
    final response = await http.post(
      Uri.parse('$baseURL/classes/Task'),
      headers: _getHeaders(sessionToken: token),
      body: json.encode({
        'title': task.title,
        'dueDate': {'__type': 'Date', 'iso': task.dueDate.toIso8601String()},
        'status': task.status,
        'ACL': {objectId: {'read': true, 'write': true}},
      }),
    );
    _checkResponse(response);
  }

  static Future<void> deleteTask(String taskId) async {
    final token = await _storage.read(key: 'sessionToken');
    final response = await http.delete(
      Uri.parse('$baseURL/classes/Task/$taskId'),
      headers: _getHeaders(sessionToken: token),
    );
    _checkResponse(response);
  }

  static Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    final token = await _storage.read(key: 'sessionToken');
    final response = await http.put(
      Uri.parse('$baseURL/classes/Task/$taskId'),
      headers: _getHeaders(sessionToken: token),
      body: json.encode({'status': isCompleted}),
    );
    _checkResponse(response);
  }

  static Future<void> updateTask(Task task) async {
    final token = await _storage.read(key: 'sessionToken');
    final response = await http.put(
      Uri.parse('$baseURL/classes/Task/${task.id}'),
      headers: _getHeaders(sessionToken: token),
      body: json.encode(task.toJson()),
    );
    _checkResponse(response);
  }

  // Helper Functions
  static Map<String, String> _getHeaders({String? sessionToken}) {
    return {
      'X-Parse-Application-Id': appID,
      'X-Parse-REST-API-Key': apiKey,
      if (sessionToken != null) 'X-Parse-Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };
  }

  static void _saveSessionData(Map<String, dynamic> data) async {
    await _storage.write(key: 'sessionToken', value: data['sessionToken']);
    await _storage.write(key: 'objectId', value: data['objectId']);
  }

  static void _clearSessionData() async {
    await _storage.delete(key: 'sessionToken');
    await _storage.delete(key: 'objectId');
  }

  static void _checkResponse(http.Response response) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }
}
