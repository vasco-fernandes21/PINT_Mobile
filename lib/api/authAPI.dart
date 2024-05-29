import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

class AuthApi {
  final String apiUrl = dotenv.env['API_URL']!;

  Future<http.Response> login(String email, String password) {
    return http.post(
      Uri.parse('$apiUrl/login/mobile'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
  }

  Future<http.Response> criarConta(String nome, String email) {
    return http.post(
      Uri.parse('$apiUrl/registar'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nome': nome,
        'email': email,
      }),
    );
  }

  Future<http.Response> listarUtilizadores() {
    return http.get(
      Uri.parse('$apiUrl/listar'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }

  Future<http.Response> googleLogin(String token) {
    return http.post(
      Uri.parse('$apiUrl/login/google'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
      }),
    );
  }


  Future<http.Response> recuperarPasse(String email) {
    return http.post(
      Uri.parse('$apiUrl/recuperar-passe'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );
  }

  Future<http.Response> resetarPasse(String token, String novaPass) {
    return http.post(
      Uri.parse('$apiUrl/reset-passe'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
        'novaPass': novaPass,
      }),
    );
  }
}