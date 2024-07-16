import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api.dart';

class EstabelecimentosAPI {
  final ApiClient api = ApiClient();

  Future<http.Response> listarEstabelecimento(int idEstabelecimento) {
    String endpoint = '/estabelecimentos/$idEstabelecimento';
    return api.get(endpoint);
  }

  Future<http.Response> listarEstabelecimentosPorArea(int idPosto, int areaId) {
    String endpoint =
        '/estabelecimentos/mobile?idPosto=$idPosto&&areaId=$areaId';
    return api.get(endpoint);
  }

    Future<http.Response> getEstabelecimentosPosto(int idPosto) {
    String endpoint =
        '/estabelecimentos/mobile?idPosto=$idPosto';
    return api.get(endpoint);
  }

  Future<http.Response> criarEstabelecimento({
    required String nome,
    required String descricao,
    required String morada,
    int? telemovel,
    required int idPosto,
    String? email,
    required int areaId,
    required int subareaId,
    required File foto,
    required String? authToken,
  }) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('${api.baseUrl}/estabelecimentos/mobile'));

    //Campos obrigatórios
    request.fields['nome'] = nome;
    request.fields['descricao'] = descricao;
    request.fields['morada'] = morada;
    request.fields['idPosto'] = idPosto.toString();
    request.fields['idArea'] = areaId.toString();
    request.fields['idSubarea'] = subareaId.toString();

    //Campos Opcionais
    if (email != null && email.isNotEmpty) {
      request.fields['email'] = email;
    }
    if (telemovel != null) {
      request.fields['telemovel'] = telemovel.toString();
    }

    //Foto
    request.files.add(await http.MultipartFile.fromPath('foto', foto.path));

    //Token
    request.headers['Authorization'] = 'Bearer $authToken';

    var response = await request.send();
    return http.Response.fromStream(response);
  }

Future<http.Response> editarPrecoEstabelecimento(int idEstabelecimento, double preco) async {
  final String url = '${api.baseUrl}/estabelecimentos/$idEstabelecimento/precos';
  
  final response = await http.put(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, double>{
      'preco': preco,
    }),
  );

  return response;
}

}


