import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setBool('isLoggedIn', true);
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

  Future<http.Response> facebookLogin(String id, String nome, String email, String foto) {
    return api.post('/login/facebook', body: {
      'id': id,
      'nome': nome, 
      'email': email,
      'foto': foto,
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

Future<void> fetchFacebookUserInfo(String accessToken) async {
  final url = 'https://graph.facebook.com/me?fields=id,name,picture&access_token=$accessToken';
  
  try {
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      print('User Info: $data');
      
      // Acesse o userId do mapa decodificado
      final userId = data['id'];
      print('User ID: $userId');
      
      // Caso queira acessar outros campos como nome ou imagem:
      final name = data['name'];
      final picture = data['picture']['data']['url'];
      print('Name: $name');
      print('Picture URL: $picture');
    } else {
      print('Erro na solicitação: ${response.statusCode}');
      print('Resposta: ${response.body}');
    }
  } catch (error) {
    print('Erro ao fazer a solicitação: $error');
  }
}
}


class Google {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();

  static Future<void> logout() => _googleSignIn.signOut();
}


class Facebook {
  static Future<String?> login() async {
    final LoginResult result = await FacebookAuth.i.login(
      permissions: ['email', 'public_profile'],
    );

    if (result.status == LoginStatus.success) {
      return result.message;
    } else {
      throw Exception('Failed to login with Facebook: ${result.message}');
    }
  }

  static Future<void> logout() async {
    await FacebookAuth.i.logOut();
  }
}
