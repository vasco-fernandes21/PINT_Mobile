import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pint/api/EstabelecimentosAPI.dart';
import 'package:pint/api/api.dart';
import 'package:pint/models/estabelecimento.dart';
import 'package:pint/navbar.dart';
import 'package:pint/api/postosAreasAPI.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/estabelecimento_card.dart';
import 'package:pint/widgets/verifica_conexao.dart';
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
  List<Estabelecimento> estabelecimentos = [];
  List<Estabelecimento> estabelecimentosFiltrados = [];
  String selectedFilter = 'Todas';
  List<String> subareas = ['Todas'];
  int selectedOrder = 0;
  bool isLoading = true;
  bool isServerOff = false;
  double? classificacaoMedia;

  @override
  void initState() {
    super.initState();
    loadEstabelecimentos();
  }

    void loadEstabelecimentos() async {
    try {
      final fetchedEstabelecimentos =
          await fetchEstabelecimentosPorArea(context, widget.areaID, widget.postoID);
      setState(() {
        estabelecimentos = fetchedEstabelecimentos;
        estabelecimentosFiltrados = estabelecimentos;
        subareas.addAll(estabelecimentos
                .map((e) => e.nomeSubarea.toString())
                .toSet()
                .toList());
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isServerOff = true;
      });
    }
  }

  void filterEstabelecimentos() {
    setState(() {
      if (selectedFilter == 'Todas') {
        estabelecimentosFiltrados = List.from(estabelecimentos);
      } else {
        estabelecimentosFiltrados = estabelecimentos.where((estab) {
          return estab.nomeSubarea == selectedFilter;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.NomeArea),
        actions: [
          PopupMenuButton<int>(
            onSelected: (int result) {
              setState(() {
                selectedOrder = result;
                if (selectedOrder == 0){
                  estabelecimentos.sort((a, b) => double.parse(a.classificacaoMedia ?? '0.00').compareTo(double.parse(b.classificacaoMedia ?? '0.00')));
                } else if (selectedOrder== 1) {
                  estabelecimentos.sort((b, a) => double.parse(a.classificacaoMedia ?? '0.00').compareTo(double.parse(b.classificacaoMedia ?? '0.00')));
                }
              });
            },
            icon: const Icon(Icons.sort),
            itemBuilder: (context) => <PopupMenuEntry<int>>[
          const PopupMenuItem<int>(
          value: null,
          child: Text('Classificação', style: TextStyle(fontWeight: FontWeight.bold)),
          enabled: false,
        ),
        const PopupMenuItem<int>(
          value: 0,
          child: Text('Ordem Crescente',),
        ),
        const PopupMenuItem<int>(
          value: 1,
          child: Text('Ordem Decrescente',),
        ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              setState(() {
                selectedFilter = result;
                filterEstabelecimentos();
              });
            },
            icon: const Icon(Icons.filter_list_alt),
             itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: null,
          child: Text('Filtrar por Subárea', style: TextStyle(fontWeight: FontWeight.bold)),
          enabled: false,
        ),
        ...subareas.map((subarea) => PopupMenuItem<String>(
          value: subarea,
          child: Text(subarea),
        )).toList(),
      ],
          ),
        ],
      ),
      body: VerificaConexao(isLoading: isLoading, isServerOff: isServerOff, child:
      estabelecimentosFiltrados.isEmpty
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
                                estabelecimentoID: estab.id,
                                
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
      ),
      bottomNavigationBar: NavBar(postoID: widget.postoID, index: 1),
    );
  }
}
