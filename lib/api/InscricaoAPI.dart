import 'package:http/http.dart' as http;
import 'api.dart';

class InscricoesAPI {
  final ApiClient api = ApiClient();

  Future<http.Response> getInscricoesEvento(int eventoId) {
    return api.get('/eventos/$eventoId/inscricao'); 
  }

  Future<http.Response> criarInscricaoEvento(int eventoId) {
    return api.post('/eventos/inscrever/$eventoId');
  }

  Future<http.Response> apagarInscricaoEvento(int eventoId) {
    return api.delete('/eventos/desinscrever/$eventoId');
  }


}