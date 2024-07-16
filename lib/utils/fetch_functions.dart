import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pint/api/AvaliacoesAPI.dart';
import 'package:pint/api/EstabelecimentosAPI.dart';
import 'package:pint/api/EventosAPI.dart';
import 'package:pint/api/FotosAPI.dart';
import 'package:pint/api/InscricaoAPI.dart';
import 'package:pint/api/NotificacoesAPI.dart';
import 'package:pint/api/UtilizadorAPI.dart';
import 'package:pint/api/api.dart';
import 'package:pint/api/postosAreasAPI.dart';
import 'package:pint/models/avaliacao.dart';
import 'package:pint/models/estabelecimento.dart';
import 'package:pint/models/evento.dart';
import 'package:pint/models/foto.dart';
import 'package:pint/models/inscricao.dart';
import 'package:pint/models/notificacao.dart';
import 'package:pint/models/utilizador.dart';
import '../models/area.dart';
import '../models/subarea.dart';

final api = ApiClient();

Future<List<Area>> fetchAreas(BuildContext context) async {
  final api = PostosAreasAPI();
  final response = await api.listarAreas();
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    return data.map((json) => Area.fromJson(json)).toList();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar áreas: ${response.statusCode}')),
    );
    return [];
  }
}

Future<List<Subarea>> fetchSubareas(BuildContext context, int areaId) async {
  final api = PostosAreasAPI();
  final response = await api.listarSubareasPorArea(areaId);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    return data.map((json) => Subarea.fromJson(json)).toList();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar subareas: ${response.statusCode}')),
    );
    return [];
  }
}

Future<List<Evento>> fetchEventos(BuildContext context, int postoID) async {
  final api = EventosAPI();
  final response = await api.listarEventosPorPosto(postoID);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    return data.map((json) => Evento.fromJson(json)).toList();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar eventos: ${response.statusCode}')),
    );
    return [];
  }
}

Future<List<Evento>> fetchMyEventos(BuildContext context) async {
  final api = EventosAPI();
  final response = await api.listarMeusEventos();
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    return data.map((json) => Evento.fromJson(json)).toList();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar eventos: ${response.statusCode}')),
    );
    return [];
  }
}

Future<List<Estabelecimento>> fetchTodosEstabelecimentosPosto(BuildContext context, int idPosto) async {
  final api = EstabelecimentosAPI();
  final response = await api.getEstabelecimentosPosto(idPosto);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    return data.map((json) => Estabelecimento.fromJson(json)).toList();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar eventos: ${response.statusCode}')),
    );
    return [];
  }
}

Future<Estabelecimento?> fetchEstabelecimento(int estabelecimentoID) async {
  final api = EstabelecimentosAPI();
  final response = await api.listarEstabelecimento(estabelecimentoID);
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return Estabelecimento.fromJson(jsonResponse['data']);
  } else {
    throw Exception('Erro ao carregar estabelecimento: ${response.statusCode}');
  }
}

Future<List<Estabelecimento>> fetchEstabelecimentosPorArea(BuildContext context, int areaId, int idPosto) async {
  final api = EstabelecimentosAPI();
  final response = await api.listarEstabelecimentosPorArea(idPosto, areaId);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    return data.map((json) => Estabelecimento.fromJson(json)).toList();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar eventos: ${response.statusCode}')),
    );
    return [];
  }
}


Future<Evento?> fetchEvento (int eventoID) async {
  final api = EventosAPI();
  final response = await api.listarEvento(eventoID);
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return Evento.fromJson(jsonResponse['data']);
  } else {
    throw Exception('Erro ao carregar evento: ${response.statusCode}');
  }
}

Future<Map<String, Object>> fetchAvaliacoes(int estabelecimentoID) async {
  final api = AvaliacoesAPI();
  final response = await api.getAvaliacoesEstabelecimento(estabelecimentoID);
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    List<Avaliacao> avaliacoes = (jsonResponse['data'] as List)
        .map((avaliacaoJson) => Avaliacao.fromJson(avaliacaoJson))
        .toList();
    double mediaAvaliacoes = double.parse(jsonResponse['media']);
    return {
      'avaliacoes': avaliacoes,
      'mediaAvaliacoes': mediaAvaliacoes,
    };
  } else {
    throw Exception('Erro ao carregar avaliacoes: ${response.statusCode}');
  }
}

Future<List<Avaliacao>> fetchComentarios(BuildContext context, int eventoId) async {
  final api = AvaliacoesAPI();
  final response = await api.getAvaliacoesEvento(eventoId);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    return data.map((json) => Avaliacao.fromJson(json)).toList();
  } else {
    /*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar eventos: ${response.statusCode}')),
    );*/
    return [];
  }
}

Future<List<Avaliacao>> fetchRespostasComentario(BuildContext context, int comentarioId) async {
  final api = AvaliacoesAPI();
  final response = await api.getRespostaComentario(comentarioId);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    return data.map((json) => Avaliacao.fromJson(json)).toList();
  } else {
    /*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar eventos: ${response.statusCode}')),
    );*/
    return [];
  }
}

Future<List<Avaliacao>> fetchRespostasAvaliacoes(BuildContext context, int comentarioId) async {
  final api = AvaliacoesAPI();
  final response = await api.getRespostaAvaliacao(comentarioId);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    return data.map((json) => Avaliacao.fromJson(json)).toList();
  } else {
    /*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar eventos: ${response.statusCode}')),
    );*/
    return [];
  }
}

Future<List<Inscricao>> fetchInscricoes(BuildContext context, int eventoID) async {
  final api = InscricoesAPI();
  final response = await api.getInscricoesEvento(eventoID);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    return data.map((json) => Inscricao.fromJson(json)).toList();
  } else {
    /*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar eventos: ${response.statusCode}')),
    );*/
    return [];
  }
}

Future<List<Inscricao>> fetchInscricoesUser(BuildContext context, int userID) async {
  final api = InscricoesAPI();
  final response = await api.getInscricoesUser(userID);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['inscricoes'];
    return data.map((json) => Inscricao.fromJson(json)).toList();
  } else {
    /*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar eventos: ${response.statusCode}')),
    );*/
    return [];
  }
}

Future<List<Notificacao>> fetchNotificacoes(BuildContext context) async {
  final api = NotificacoesAPI();
  final response = await api.getNotificacoes();
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data']['notificacoes'];
    return data.map((json) => Notificacao.fromJson(json)).toList();
  } else {
    /*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar eventos: ${response.statusCode}')),
    );*/
    return [];
  }
}

Future<int> fetchContadorNotificacoes() async {
  try {
    final api = NotificacoesAPI();
    var response = await api.getContadorNotificacoes();
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        int contador = responseData['data']['contador'];
        return contador;
      } else {
        // Tratar caso o status seja diferente de 'success'
        return 0;
      }
    } else {
      // Tratar outros códigos de status HTTP, se necessário
      return 0;
    }
  } catch (e) {
    // Tratar exceções, como falha na conexão
    return 0;
  }
}

Future<Utilizador?> fetchUtilizadorCompleto() async {
  final api = UtilizadorAPI();
  final response = await api.getUtilizadorCompleto();

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return Utilizador.fromJson(jsonResponse);
  } else {
    print ('Erro ao carregar utilizador: ${response.statusCode}');
    return null;
  }
}

Future<List<Foto>> fetchFotosEvento(BuildContext context, int eventoID) async {
  final api = FotosAPI();
  final response = await api.getFotosEvento(eventoID);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    return data.map((json) => Foto.fromJson(json)).toList();
  } else {
    /*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar eventos: ${response.statusCode}')),
    );*/
    return [];
  }
}
Widget buildUserAvatar(String? imageUrl, String? idGoogle, String? idFacebook, {double width = 120, double height = 120}) {
  String? finalImageUrl;

  // Verifica se há um idGoogle ou idFacebook e usa diretamente o URL fornecido
  if (idGoogle != null || idFacebook != null) {
    finalImageUrl = imageUrl ?? 'assets/images/default-avatar.jpg';
  }
  // Caso contrário, usa o caminho para /uploads/utilizador/
  else if (imageUrl != null) {
    finalImageUrl = '${api.baseUrl}/uploads/utilizador/$imageUrl';
  }
  // Se nenhum URL estiver disponível, usa a imagem padrão
  else {
    finalImageUrl = 'assets/images/default-avatar.jpg';
  }

  return Image.network(
    finalImageUrl,
    fit: BoxFit.cover,
    width: width,
    height: height,
    errorBuilder: (context, error, stackTrace) {
      return Image.asset(
        'assets/images/default-avatar.jpg',
        fit: BoxFit.cover,
        width: width,
        height: height,
      );
    },
  );
}

ImageProvider<Object> buildUserAvatarImageProvider(String? imageUrl, String? idGoogle, String? idFacebook) {
  // Verifica se há um idGoogle ou idFacebook e usa diretamente o URL fornecido
  if (idGoogle != null || idFacebook != null) {
    return NetworkImage(imageUrl ?? 'assets/images/default-avatar.jpg');
  }
  // Caso contrário, usa o caminho para /uploads/utilizador/
  else if (imageUrl != null) {
    return NetworkImage('${api.baseUrl}/uploads/utilizador/$imageUrl');
  }
  // Se nenhum URL estiver disponível, usa a imagem padrão
  else {
    return const AssetImage('assets/images/default-avatar.jpg');
  }
}

Widget userCircleAvatar({required String? imageUrl, required String? idGoogle, required String? idFacebook, double radius = 20}) {
  return CircleAvatar(
    radius: radius,
    backgroundImage: buildUserAvatarImageProvider(imageUrl, idGoogle, idFacebook),
    onBackgroundImageError: (exception, stackTrace) {
      const AssetImage('assets/images/default-avatar.jpg');
    },
  );
}