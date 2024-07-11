import 'dart:io';

import 'package:http/http.dart' as http;
import 'api.dart';
import 'package:dio/dio.dart';

class FotosAPI {
  final dio = Dio();
  final ApiClient api = ApiClient();

  Future<http.Response> getFotosEvento(int eventoId) {
    return api.get('/foto/eventos/$eventoId');
  }

  Future<http.Response> getFotosEstabelecimento(int estabelecimentoId) {
    return api.get('/foto/eventos/$estabelecimentoId');
  }

  Future<Response> adicionarFotoEvento(
      int eventoId, int idUtilizador, File foto) async {
    final url = '${api.baseUrl}/foto/eventos/$eventoId';

    var formData = FormData.fromMap({
      'idUtilizador': idUtilizador,
      'foto': await MultipartFile.fromFile(foto.path),
    });
    var response = await dio.post(url, data: formData);
    return response;
  }

    Future<Response> adicionarFotoEstabelecimento(
      int estabelecimentoId, int idUtilizador, File foto) async {
    final url = '${api.baseUrl}/foto/estabelecimentos/$estabelecimentoId';

    var formData = FormData.fromMap({
      'idUtilizador': idUtilizador,
      'foto': await MultipartFile.fromFile(foto.path),
    });
    var response = await dio.post(url, data: formData);
    return response;
  }

}
