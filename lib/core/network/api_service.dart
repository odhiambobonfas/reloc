import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.20.58:5000/api';
  static const Duration _timeout = Duration(seconds: 30);
  static final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
  };

  /// Fetch data from the API
  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers, bool requiresAuth = false}) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final requestHeaders = Map<String, String>.from(_defaultHeaders);
      
      if (requiresAuth) {
        final token = await _getAuthToken();
        if (token != null) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      }
      
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      final response = await http.get(url, headers: requestHeaders)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Post request with authentication
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final requestHeaders = Map<String, String>.from(_defaultHeaders);
      
      if (requiresAuth) {
        final token = await _getAuthToken();
        if (token != null) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      }
      
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      final response = await http.post(
        url,
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Put request with authentication
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final requestHeaders = Map<String, String>.from(_defaultHeaders);
      
      if (requiresAuth) {
        final token = await _getAuthToken();
        if (token != null) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      }
      
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      final response = await http.put(
        url,
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete request with authentication
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final requestHeaders = Map<String, String>.from(_defaultHeaders);
      
      if (requiresAuth) {
        final token = await _getAuthToken();
        if (token != null) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      }
      
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      final response = await http.delete(url, headers: requestHeaders)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Upload file with multipart/form-data
  static Future<Map<String, dynamic>> uploadFile(
    String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, String>? additionalFields,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final request = http.MultipartRequest('POST', url);
      
      // Add headers
      request.headers.addAll(_defaultHeaders);
      if (requiresAuth) {
        final token = await _getAuthToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }
      if (headers != null) {
        request.headers.addAll(headers);
      }
      
      // Add file
      final file = File(filePath);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath(fieldName, filePath),
        );
      }
      
      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        return {
          'success': false,
          'error': body['error'] ?? 'Request failed',
          'message': body['message'] ?? 'An error occurred',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Invalid response format',
        'message': 'Failed to parse response',
        'statusCode': response.statusCode,
      };
    }
  }

  /// Handle errors
  static Map<String, dynamic> _handleError(dynamic error) {
    String errorMessage = 'An unexpected error occurred';
    
    if (error is SocketException) {
      errorMessage = 'No internet connection';
    } else if (error is HttpException) {
      errorMessage = 'HTTP error occurred';
    } else if (error is FormatException) {
      errorMessage = 'Data format error';
    } else if (error is TimeoutException) {
      errorMessage = 'Request timeout';
    } else if (error.toString().contains('CORS')) {
      errorMessage = 'Cross-origin request blocked';
    }

    if (kDebugMode) {
      print('API Error: $error');
    }

    return {
      'success': false,
      'error': 'Network Error',
      'message': errorMessage,
      'statusCode': 0,
    };
  }

  /// Get authentication token from shared preferences
  static Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      if (kDebugMode) {
        print('Error getting auth token: $e');
      }
      return null;
    }
  }

  /// Save authentication token to shared preferences
  static Future<bool> saveAuthToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString('auth_token', token);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving auth token: $e');
      }
      return false;
    }
  }

  /// Remove authentication token from shared preferences
  static Future<bool> removeAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('auth_token');
    } catch (e) {
      if (kDebugMode) {
        print('Error removing auth token: $e');
      }
      return false;
    }
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await _getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Get base URL for external use
  static String get baseUrl => _baseUrl;
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException([this.message = 'Request timeout']);
  
  @override
  String toString() => message;
}