import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

class AuthApi {
  final String apiUrl = dotenv.env['API_URL']!;

  // Variáveis globais para armazenar os tokens
  String? token;
  String? recoveryToken;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/login/mobile'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      token = data['token'];
      recoveryToken = data['recoveryToken'];
      print('Token: $token');
      print('Recovery Token: $recoveryToken');
      return {'statusCode': response.statusCode, 'body': data};
    } else {
      throw Exception('Failed to login');
    }
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

  Future<http.Response> resetarPasse(String recoveryToken, String novaPass) async {
    final url = Uri.parse('$apiUrl/reset-passe');

    return await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'novaPass': novaPass,
        'token': recoveryToken,  // Add recoveryToken to the request body
      }),
    );
  }
}