import 'package:http/http.dart' as http;
import 'api.dart';

class InscricoesAPI {
  final ApiClient api = ApiClient();

  Future<http.Response> getInscricoesEvento(int eventoId) {
    return api.get('/eventos/$eventoId/inscricao');
  }

  Future<http.Response> getInscricoesUser(int userId) {
    return api.get('/utilizador/inscricao/$userId');
  }

  Future<http.Response> criarInscricaoEvento(
      int eventoId, String? token) async {
    final String url = '${api.baseUrl}/eventos/inscrever/$eventoId';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response;
  }

  Future<http.Response> apagarInscricaoEvento(int eventoId) {
    return api.delete('/eventos/desinscrever/$eventoId');
  }
}
