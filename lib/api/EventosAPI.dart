import 'dart:io';
import 'package:http/http.dart' as http;
import 'api.dart';


class EventosAPI {

  final ApiClient api = ApiClient();

  Future<http.Response> criarEvento({
    required String titulo,
    required String descricao,
    required DateTime data,
    required String hora,
    required String morada,
    int? telemovel,
    required int idPosto,
    String? email,
    required int areaId,
    required int subareaId,
    required File foto,
    required String? authToken,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('${api.baseUrl}/eventos/mobile'));


    //Campos obrigatórios
    request.fields['titulo'] = titulo;
    request.fields['descricao'] = descricao;
    request.fields['data'] = data.toIso8601String();
    request.fields['hora'] = hora;
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

    request.headers['Authorization'] = 'Bearer $authToken';

    var response = await request.send();
    return http.Response.fromStream(response);
  }

  Future<http.Response> listarEvento(int eventoId) {
  String endpoint = '/eventos/$eventoId';
  return api.get(endpoint);
  }

  Future<http.Response> listarEventosPorPosto(int idPosto) {
    String endpoint ='/eventos/mobile?idPosto=$idPosto';
    return api.get(endpoint);
  }

}