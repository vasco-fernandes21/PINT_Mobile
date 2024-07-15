import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api.dart';

class AuthApi {
  final ApiClient api = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await api.post('/login/mobile', body: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setBool('isLoggedIn', true);
      if (data['recoveryToken'] != null) {
        await prefs.setString('recoveryToken', data['recoveryToken']);
      }
      if (data['recoveryToken'] != null) {
        await prefs.setString('recoveryToken', data['recoveryToken']);
      }
      return {'statusCode': response.statusCode, 'body': data};
    } else {
      var errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to login');
    }
  }

  Future<http.Response> criarConta(String nome, String email) {
    return api.post('/registar', body: {
      'nome': nome,
      'email': email,
    });
  }

  Future<http.Response> listarUtilizadores() {
    return api.get('/listar');
  }

  Future<http.Response> googleLogin(String token) {
    return api.post('/login/google', body: {
      'token': token,
    });
  }

  Future<http.Response> recuperarPasse(String email) {
    return api.post('/recuperar-passe', body: {
      'email': email,
    });
  }

  Future<http.Response> resetarPasse(String recoveryToken, String novaPass) {
    return api.post('/reset-passe', body: {
      'novaPass': novaPass,
      'token': recoveryToken,
    });
  }
}

class Google {
  static final _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();

  static Future logout() => _googleSignIn.signOut();
}
