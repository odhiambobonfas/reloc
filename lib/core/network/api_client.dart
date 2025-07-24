import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'https://your-backend-url.com/api'; // replace with your actual URL
  final Map<String, String> _headers;

  ApiClient({String? token})
      : _headers = {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        };

  // Generic GET request
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(url, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET request error: $e');
    }
  }

  // Generic POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST request error: $e');
    }
  }

  // PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('PUT request error: $e');
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.delete(url, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('DELETE request error: $e');
    }
  }

  // Handle response
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = jsonDecode(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else {
      throw Exception(
          'Request failed\nStatus: $statusCode\nMessage: ${body['message'] ?? 'Unknown error'}');
    }
  }
}
