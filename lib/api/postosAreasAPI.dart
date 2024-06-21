import 'package:http/http.dart' as http;
import 'api.dart';

class PostosAreasAPI {
  final ApiClient api = ApiClient();

  Future<http.Response> listarPostos() {
    return api.get('/postos');
  }

  Future<http.Response> listarAreas() {
    return api.get('/areas');
  }

  Future<http.Response> listarEstabelecimentosPorArea(int idPosto, int areaId) {
  String endpoint = '/estabelecimentos/mobile?idPosto=$idPosto&&areaId=$areaId';
  return api.get(endpoint);
  }

  Future<http.Response> listarEstabelecimento(int idEstabelecimento) {
  String endpoint = '/estabelecimentos/$idEstabelecimento';
  return api.get(endpoint);
  }

}