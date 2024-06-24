import 'package:http/http.dart' as http;
import 'api.dart';

class AvaliacoesAPI {
  final ApiClient api = ApiClient();

  Future<http.Response> getAvaliacoesEstabelecimento(int estabelecimentoId) {
    return api.get('/avaliacao/estabelecimentos/$estabelecimentoId');
    
  }

}