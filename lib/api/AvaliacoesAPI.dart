import 'package:http/http.dart' as http;
import 'api.dart';

class AvaliacoesAPI {
  final ApiClient api = ApiClient();

  Future<http.Response> getAvaliacoesEstabelecimento(int estabelecimentoId) {
    return api.get('/avaliacao/estabelecimentos/$estabelecimentoId');
    
  }

    Future<http.Response> criarAvaliacaoEstabelecimento(int estabelecimentoId, int idUtilizador, int? classificacao, String? comentario) {
    return api.post('/avaliacao/estabelecimentos/criar/$estabelecimentoId', body: {
      'idUtilizador': idUtilizador,
      'classificacao': classificacao,
      'comentario': comentario
    });
  }

}