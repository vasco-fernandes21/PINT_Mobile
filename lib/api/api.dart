import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  final String baseUrl = dotenv.env['API_URL']!;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } else {
      return {
        'Content-Type': 'application/json',
      };
    }
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return http.post(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> put(String endpoint, {dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return http.put(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return http.delete(url, headers: headers);
  }
}
