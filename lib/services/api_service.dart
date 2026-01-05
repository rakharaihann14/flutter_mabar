import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_endpoints.dart';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Request failed');
    }
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.register),
      headers: await getHeaders(),
      body: json.encode(data),
    );
    final result = await handleResponse(response);
    
    // Save token after successful registration
    if (result['success'] && result['data']['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['data']['token']);
    }
    
    return result;
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.login),
      headers: await getHeaders(),
      body: json.encode({'email': email, 'password': password}),
    );
    final result = await handleResponse(response);
    
    // Save token
    if (result['success'] && result['data']['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['data']['token']);
    }
    
    return result;
  }

  static Future<Map<String, dynamic>> forgotPassword(
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.forgotPassword),
      headers: await getHeaders(),
      body: json.encode({
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    return handleResponse(response);
  }

  static Future<void> logout() async {
    await http.post(
      Uri.parse(ApiEndpoints.logout),
      headers: await getHeaders(),
    );
    
    // Clear token
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(
      Uri.parse(ApiEndpoints.me),
      headers: await getHeaders(),
    );
    return handleResponse(response);
  }

  // Events endpoints
  static Future<Map<String, dynamic>> getEvents() async {
    final response = await http.get(
      Uri.parse(ApiEndpoints.events),
      headers: await getHeaders(),
    );
    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> getEvent(int id) async {
    final response = await http.get(
      Uri.parse('${ApiEndpoints.events}/$id'),
      headers: await getHeaders(),
    );
    return handleResponse(response);
  }

  // Registration endpoints
  static Future<Map<String, dynamic>> registerEvent(int eventId) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.registrations),
      headers: await getHeaders(),
      body: json.encode({'event_id': eventId}),
    );
    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMyRegistrations() async {
    final response = await http.get(
      Uri.parse(ApiEndpoints.myRegistrations),
      headers: await getHeaders(),
    );
    return handleResponse(response);
  }

  // Notifications endpoints
  static Future<Map<String, dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse(ApiEndpoints.notifications),
      headers: await getHeaders(),
    );
    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> markAsRead(int id) async {
    final response = await http.put(
      Uri.parse('${ApiEndpoints.notifications}/$id/read'),
      headers: await getHeaders(),
    );
    return handleResponse(response);
  }
  
  // Generic API methods
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
      headers: await getHeaders(),
    );
    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
      headers: await getHeaders(),
      body: json.encode(data),
    );
    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
      headers: await getHeaders(),
      body: json.encode(data),
    );
    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
      headers: await getHeaders(),
    );
    return handleResponse(response);
  }
}
