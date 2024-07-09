import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pint/api/AvaliacoesAPI.dart';
import 'package:pint/api/EstabelecimentosAPI.dart';
import 'package:pint/api/EventosAPI.dart';
import 'package:pint/api/InscricaoAPI.dart';
import 'package:pint/api/UtilizadorAPI.dart';
import 'package:pint/api/postosAreasAPI.dart';
import 'package:pint/models/avaliacao.dart';
import 'package:pint/models/estabelecimento.dart';
import 'package:pint/models/evento.dart';
import 'package:pint/models/inscricao.dart';
import 'package:pint/models/utilizador.dart';
import '../models/area.dart';
import '../models/subarea.dart';

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