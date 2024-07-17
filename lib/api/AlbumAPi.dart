import 'dart:io';

import 'package:http/http.dart' as http;
import 'api.dart';
import 'package:dio/dio.dart';

class AlbumAPI {
  final dio = Dio();
  final ApiClient api = ApiClient();

    Future<http.Response> listarAlbuns(int idArea, int idPosto) {
    String endpoint = '/album?idPosto=$idPosto&&areaId=$idArea';
    return api.get(endpoint);
  }

  Future<http.Response> getAlbum(int idAlbum) {
    String endpoint = '/album/$idAlbum';
    return api.get(endpoint);
  }

    Future<http.Response> getAlbumFotos(int idAlbum) {
    String endpoint = '/album/$idAlbum/fotos';
    return api.get(endpoint);
  }

      Future<Response> criarAlbum(
      String? nome, String? descricao, int idArea,File foto, String? token, int idPosto) async {
    final url = '${api.baseUrl}/album/';

    var formData = FormData.fromMap({
      'nome' : nome,
      'descricao' : descricao,
      'idArea' : idArea,
      'foto': await MultipartFile.fromFile(foto.path),
      'idPosto': idPosto
    });
    var response = await dio.post(url, data: formData, options: Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }
    ));
    return response;
  }

    Future<Response> adicionarFotoAlbum(
      int idAlbum ,File foto, String? token) async {
    final url = '${api.baseUrl}/album/$idAlbum/fotos';

    var formData = FormData.fromMap({
      'foto': await MultipartFile.fromFile(foto.path),
    });
    var response = await dio.post(url, data: formData, options: Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }
    ));
    return response;
  }

}