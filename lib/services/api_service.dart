import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // For Web applications, use the correct origin
  static const String serverUrl = 'http://localhost:3000';
  
  // Get stored token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }
  
  // Store token
  static Future<void> storeToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } catch (e) {
      print('Error storing token: $e');
    }
  }
  
  // Test server connection
  static Future<bool> testConnection() async {
    try {
      print('Testing connection to: $serverUrl/api/health');
      final response = await http.get(Uri.parse('$serverUrl/api/health'));
      print('Health check response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Health check error: $e');
      return false;
    }
  }
  
  // Register user
  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      print('Sending registration request to: $serverUrl/api/auth/register');
      
      // First test the connection
      if (!await testConnection()) {
        return {'error': true, 'message': 'Cannot connect to server. Please check your server is running.'};
      }
      
      final response = await http.post(
        Uri.parse('$serverUrl/api/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(userData),
      );
      
      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data.containsKey('token')) {
          await storeToken(data['token']);
        }
        return data;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'error': true, 'message': errorData['message'] ?? 'Registration failed'};
        } catch (e) {
          return {'error': true, 'message': 'Registration failed: HTTP ${response.statusCode}'};
        }
      }
    } catch (e) {
      print('Registration error: $e');
      return {'error': true, 'message': 'Error connecting to server: $e'};
    }
  }
  
  // Login user
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      print('Sending login request to: $serverUrl/api/auth/login');
      
      // First test the connection
      if (!await testConnection()) {
        return {'error': true, 'message': 'Cannot connect to server. Please check your server is running.'};
      }
      
      final response = await http.post(
        Uri.parse('$serverUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone, 'password': password}),
      );
      
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('token')) {
          await storeToken(data['token']);
        }
        return data;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'error': true, 'message': errorData['message'] ?? 'Login failed'};
        } catch (e) {
          return {'error': true, 'message': 'Login failed: HTTP ${response.statusCode}'};
        }
      }
    } catch (e) {
      print('Login error: $e');
      return {'error': true, 'message': 'Error connecting to server: $e'};
    }
  }
  
  // Get experiences
  static Future<List<dynamic>> getExperiences() async {
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/api/experiences'),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load experiences: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting experiences: $e');
      return [];
    }
  }
  
  // Add experience
  static Future<Map<String, dynamic>> addExperience(String name, String story) async {
    try {
      final token = await getToken();
      
      final response = await http.post(
        Uri.parse('$serverUrl/api/experiences'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-auth-token': token ?? '',
        },
        body: jsonEncode({'name': name, 'story': story}),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'error': true, 'message': errorData['message'] ?? 'Failed to add experience'};
        } catch (e) {
          return {'error': true, 'message': 'Failed to add experience: HTTP ${response.statusCode}'};
        }
      }
    } catch (e) {
      print('Error adding experience: $e');
      return {'error': true, 'message': 'Error connecting to server: $e'};
    }
  }
  
  // Check if location is in danger area
  static Future<Map<String, dynamic>> checkDangerArea(double latitude, double longitude) async {
    try {
      final token = await getToken();
      
      final response = await http.post(
        Uri.parse('$serverUrl/api/location/check-danger'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-auth-token': token ?? '',
        },
        body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'isDangerous': false, 'error': 'Failed to check danger area'};
      }
    } catch (e) {
      print('Error checking danger area: $e');
      return {'isDangerous': false, 'error': 'Error connecting to server: $e'};
    }
  }
}