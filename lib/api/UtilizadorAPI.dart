import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api.dart';

class UtilizadorAPI {
  final ApiClient api = ApiClient();

  Future<http.Response> getUtilizadorCompleto() {
    return api.get('/utilizador/completo');
  }

    Future<http.Response> getUtilizador(int idUtilizador) {
    return api.get('/utilizador/$idUtilizador');
  }

  Future<http.Response> editarUtilizador(
      int userId,
      String? nome,
      String? email,
      String? cargo,
      String? nif,
      String? telemovel,
      File? foto) async {
    final url = '${api.baseUrl}/utilizador/$userId';

    var request = http.MultipartRequest('PUT', Uri.parse(url));

    if (nome != null) request.fields['nome'] = nome;
    if (email != null) request.fields['email'] = email;
    if (cargo != null) request.fields['cargo'] = cargo;
    if (nif != null) request.fields['nif'] = nif;
    if (telemovel != null) request.fields['telemovel'] = telemovel;

    if (foto != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          foto.path,
        ),
      );
    }

    var streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);

  }

Future<http.Response> editarPreferenciaUtilizador(
  int userId,
  int? areaId,
  int? subareaId,
) async {
  final url = '${api.baseUrl}/utilizador/$userId/preferencias';

  final response = await http.put(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, int?>{
      'idArea': areaId,
      'idSubarea': subareaId,
    }),
  );

  return response;
}

}
