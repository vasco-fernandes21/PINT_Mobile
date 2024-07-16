import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'api.dart';

class AvaliacoesAPI {
  final ApiClient api = ApiClient();
  final Dio dio = Dio();

  Future<http.Response> getAvaliacoesEstabelecimento(int estabelecimentoId) {
    return api.get('/avaliacao/estabelecimentos/$estabelecimentoId');
    
  }

  Future<http.Response> getAvaliacoesEvento(int eventoId) {
    return api.get('/avaliacao/eventos/$eventoId');
    
  }

    Future<http.Response>  criarAvaliacaoEstabelecimento(int estabelecimentoId, int idUtilizador, int? classificacao, String? comentario) {
    return api.post('/avaliacao/estabelecimentos/criar/$estabelecimentoId', body: {
      'idUtilizador': idUtilizador,
      'classificacao': classificacao,
      'comentario': comentario
    });


  }

    Future<Response> criarComentarioEvento(int eventoId, int idUtilizador, int? classificacao, String? comentario) async {
    final url = '${api.baseUrl}/avaliacao/eventos/criar/$eventoId';

    final response = await dio.post(
      url,
      data: {'idUtilizador': idUtilizador,
      'classificacao': classificacao,
      'comentario' : comentario},
      options: Options(headers: {'Content-Type': 'application/json'})
    );

    return response;
  }

  Future<http.Response> getRespostaComentario(int avaliacaoId) {
    return api.get('/avaliacao/eventos/respostas/$avaliacaoId');
    
  }

    Future<Response>  criarRespostaComentario(int idAvaliacao, int? classificacao, String? comentario, String? token) async {
    final url = '${api.baseUrl}/avaliacao/eventos/responder/$idAvaliacao';

    final response = await dio.post(
      url,
      data: {
      'classificacao': classificacao,
      'comentario' : comentario},
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'})
    );

    return response;
  }

  Future<http.Response> getRespostaAvaliacao(int avaliacaoId) {
    return api.get('/avaliacao/estabelecimentos/respostas/$avaliacaoId');
    
  }

    Future<Response>  criarRespostaAvaliacao(int idAvaliacao, int? classificacao, String? comentario, String? token) async {
    final url = '${api.baseUrl}/avaliacao/estabelecimentos/responder/$idAvaliacao';

    final response = await dio.post(
      url,
      data: {
      'classificacao': classificacao,
      'comentario' : comentario},
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'})
    );

    return response;
  }

Future<Response> adicionarUpvote(int eventoId, String? token) async {
    final url = '${api.baseUrl}/avaliacao/$eventoId/upvote';

    var response = await dio.post(
      url,
      data: {
      'tipoEntidade': 'eventos',
      'idEntidade': eventoId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    return response;
  }

 Future<Response> denunciarComentario(int idAvaliacaoEvento, String? token) async {
    final url = '${api.baseUrl}/denuncia';

    var response = await dio.post(
      url,
      data: {
      'idAvaliacaoEvento': idAvaliacaoEvento,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return response;
  } 

Future<Response> adicionarDownvote(int eventoId, String? token) async {
    final url = '${api.baseUrl}/avaliacao/$eventoId/downvote';

    var response = await dio.post(
      url,
      data: {
      'tipoEntidade': 'eventos',
      'idEntidade': eventoId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    return response;
  }

}