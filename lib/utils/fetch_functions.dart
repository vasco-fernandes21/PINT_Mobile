import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pint/api/AvaliacoesAPI.dart';
import 'package:pint/api/EstabelecimentosAPI.dart';
import 'package:pint/api/EventosAPI.dart';
import 'package:pint/api/UtilizadorAPI.dart';
import 'package:pint/api/postosAreasAPI.dart';
import 'package:pint/models/avaliacao.dart';
import 'package:pint/models/estabelecimento.dart';
import 'package:pint/models/evento.dart';
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

Future<Utilizador?> fetchUtilizadorCompleto(String token) async {
  final api = UtilizadorAPI();
  final response = await api.getUtilizadorCompleto(token);

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return Utilizador.fromJson(jsonResponse);
  } else {
    throw Exception('Erro ao carregar utilizador: ${response.statusCode}');
  }
}