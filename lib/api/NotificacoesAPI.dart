import 'dart:convert';

import 'package:http/http.dart' as http;
import 'api.dart';

class NotificacoesAPI {
  final ApiClient api = ApiClient();

  Future<http.Response> getNotificacoes() {
    return api.get('/notificacao');
  }

  Future<http.Response> getContadorNotificacoes() {
    return api.get('/notificacao/contador');
  }

  Future<http.Response> marcarNotificacaoComoLida(int idNotificacao, String? token) async {
    final String apiUrl = '${api.baseUrl}/notificacao/lido';

    Map<String, dynamic> body = {
      'ids': idNotificacao,
    };

    final http.Response response = await http.put(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Token de autenticação
      },
      body: jsonEncode(body),
    );

  return response;
  }

    Future<http.Response> apagarNotificacao(int idNotificacao, String? token) async {
    final String apiUrl = '${api.baseUrl}/notificacao/';

    Map<String, dynamic> body = {
      'ids': idNotificacao,
    };

    final http.Response response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Token de autenticação
      },
      body: jsonEncode(body),
    );

  return response;
  }


}
