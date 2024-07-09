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

    Future<http.Response> listarMeusEventos() {
  String endpoint = '/eventos/criados';
  return api.get(endpoint);
  }



Future<http.Response> editarEvento({
  required int id,
  String? titulo,
  String? descricao,
  DateTime? data,
  String? hora,
  String? morada,
  int? telemovel,
  int? idPosto,
  String? email,
  int? areaId,
  int? subareaId,
  File? foto,
  required String? authToken,
}) async {
  var request = http.MultipartRequest('PUT', Uri.parse('${api.baseUrl}/eventos/$id'));

  // Campos obrigatórios (id do evento e token de autenticação)
  request.headers['Authorization'] = 'Bearer $authToken';

  // Campos opcionais
  if (titulo != null) request.fields['titulo'] = titulo;
  if (descricao != null) request.fields['descricao'] = descricao;
  if (data != null) request.fields['data'] = data.toIso8601String();
  if (hora != null) request.fields['hora'] = hora;
  if (morada != null) request.fields['morada'] = morada;
  if (idPosto != null) request.fields['idPosto'] = idPosto.toString();
  if (areaId != null) request.fields['idArea'] = areaId.toString();
  if (subareaId != null) request.fields['idSubarea'] = subareaId.toString();
  if (email != null && email.isNotEmpty) request.fields['email'] = email;
  if (telemovel != null) request.fields['telemovel'] = telemovel.toString();

  // Foto é opcional na edição
  if (foto != null) {
    request.files.add(await http.MultipartFile.fromPath('foto', foto.path));
  }

  var response = await request.send();
  return http.Response.fromStream(response);
}


}