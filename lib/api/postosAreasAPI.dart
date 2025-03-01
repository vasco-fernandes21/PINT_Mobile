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

  Future<http.Response> listarSubareasPorArea(int areaId) {
  String endpoint = '/areas/$areaId';
  return api.get(endpoint);
  }

}