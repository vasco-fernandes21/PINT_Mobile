import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pint/api/EstabelecimentosAPI.dart';
import 'package:pint/api/api.dart';
import 'package:pint/navbar.dart';
import 'package:pint/api/postosAreasAPI.dart';
import 'package:pint/widgets/estabelecimento_card.dart';
import 'paginaEstabelecimento.dart';

class AreaEstabelecimentos extends StatefulWidget {
  final int postoID;
  final int areaID;
  final String NomeArea;
  AreaEstabelecimentos(
      {required this.postoID, required this.areaID, required this.NomeArea});

  @override
  State<AreaEstabelecimentos> createState() => _AreaEstabelecimentosState();
}

class _AreaEstabelecimentosState extends State<AreaEstabelecimentos> {
  final api = ApiClient();
  List<Map<String, dynamic>> estabelecimentos = [];
  List<Map<String, dynamic>> estabelecimentosFiltrados = [];
  String selectedFilter = 'Todos';
  List<String> subareas = ['Todos'];
  Map<String, dynamic>? Estabelecimento;
  int selectedEstabId = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAreas();
  }

  void fetchAreas() async {
    final api = EstabelecimentosAPI();
    final response =
        await api.listarEstabelecimentosPorArea(widget.postoID, widget.areaID);

    if (response.statusCode == 200) {
      try {
        // Decodificar a resposta JSON
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Verificar se a chave 'data' existe na resposta
        if (jsonResponse.containsKey('data')) {
          // Acessar a lista de postos dentro de 'data'
          List<dynamic> estabsData = jsonResponse['data'];

          setState(() {
            estabelecimentos = estabsData
                .map<Map<String, dynamic>>((item) => {
                      'id': item['id'],
                      'nome': item['nome'],
                      'morada': item['morada'],
                      'descricao': item['descricao'],
                      'foto': item['foto'],
                      'subarea': item['Subarea']['nome'],
                    })
                .toList();
            estabelecimentosFiltrados = List.from(estabelecimentos);
            subareas.addAll(estabelecimentos
                .map((e) => e['subarea'].toString())
                .toSet()
                .toList());
            isLoading = false;
          });
        } else {
          // Se 'data' não estiver presente na resposta
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Dados de postos não encontrados na resposta')),
          );
        }
      } catch (e) {
        // Capturar e mostrar erros de decodificação JSON
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar os dados: $e')),
        );
      }
    } else {
      // Tratar erros de status HTTP
      isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao carregar dados: ${response.statusCode}')),
      );
    }
  }

  void filterEstabelecimentos() {
    setState(() {
      if (selectedFilter == 'Todos') {
        estabelecimentosFiltrados = List.from(estabelecimentos);
      } else {
        estabelecimentosFiltrados = estabelecimentos.where((estab) {
          return estab['subarea'] == selectedFilter;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.NomeArea}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              setState(() {
                selectedFilter = result;
                filterEstabelecimentos();
              });
            },
            icon: Icon(Icons.filter_list_alt),
            itemBuilder: (BuildContext context) => subareas
                .map((subarea) => PopupMenuItem<String>(
                      value: subarea,
                      child: Text(subarea),
                    ))
                .toList(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : estabelecimentosFiltrados.isEmpty
              ? const Center(child: Text('Nenhum estabelecimento encontrado.'))
              : SingleChildScrollView(
                  child: Column(
                    children: estabelecimentosFiltrados.map((estab) {
                      return EstabelecimentoCard(
                        estab: estab,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EstabelecimentoPage(
                                estabelecimentoID: estab['id'],
                                NomeEstabelecimento: estab['nome'],
                                postoID: widget.postoID,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
      bottomNavigationBar: NavBar(postoID: widget.postoID, index: 1),
    );
  }
}
