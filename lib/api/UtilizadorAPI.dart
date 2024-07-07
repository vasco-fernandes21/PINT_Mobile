import 'dart:io';
import 'package:http/http.dart' as http;
import 'api.dart';

class UtilizadorAPI {
  final ApiClient api = ApiClient();

  Future<http.Response> getUtilizadorCompleto(String token) {
    return api.get('/utilizador/completo');
  }
}
