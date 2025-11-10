import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:reloc/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = ApiConstants.baseUrl;
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
    // If the response body is empty or not valid JSON, handle it gracefully
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Successful request but empty response, might be valid for some endpoints (e.g., DELETE)
        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': {}, // Return empty map for consistency
        };
      } else {
        // Error response with empty body
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': 'Server Error',
          'message': 'Received status code ${response.statusCode} with an empty response body.',
        };
      }
    }

    try {
      final dynamic body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': body,
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': body is Map ? body['error'] ?? 'Request failed' : 'Request failed',
          'message': body is Map ? body['message'] ?? 'An error occurred' : response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'statusCode': response.statusCode,
        'error': 'Invalid response format',
        'message': 'Failed to parse response body: ${response.body}',
      };
    }
  }

  /// Handle errors
  static Map<String, dynamic> _handleError(dynamic error) {
    String errorMessage = 'An unexpected error occurred';
    
    if (error is SocketException) {
      errorMessage = 'No internet connection. Please check your network settings.';
    } else if (error is HttpException) {
      errorMessage = 'HTTP error occurred. Could not find the requested resource.';
    } else if (error is FormatException) {
      errorMessage = 'Data format error. The server response was not in the expected format.';
    } else if (error is TimeoutException) {
      errorMessage = 'Request timeout. The server took too long to respond.';
    } else if (error is http.ClientException) { // Specifically handle http.ClientException
      errorMessage = 'Failed to connect to the server. This might be due to the server being offline, a firewall, or a CORS issue.';
    } else if (error.toString().contains('CORS')) {
      errorMessage = 'Cross-origin request blocked. Please check server CORS configuration.';
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