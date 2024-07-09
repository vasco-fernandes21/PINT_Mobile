import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pint/api/postosAreasAPI.dart';
import 'package:pint/models/area.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/eventos_grid.dart';
import 'estabelecimentos/EstabelecimentosPorArea.dart';
import 'package:pint/navbar.dart';

class Pesquisar extends StatefulWidget {
  final int postoID;
  Pesquisar({required this.postoID});

  @override
  _PesquisarState createState() => _PesquisarState();
}

class _PesquisarState extends State<Pesquisar> {
  List<Area> areas = [];
  bool isLoading = true;
  bool showEstabelecimentos = true;

  @override
  void initState() {
    super.initState();
    loadAreas();
  }

  void loadAreas() async {
    final fetchedAreas = await fetchAreas(context);
    setState(() {
      areas = fetchedAreas;
      isLoading = false;
    });
  }

  void handleFilterToggle(int item) {
    setState(() {
      if (item == 1) {
        showEstabelecimentos = true;
      } else if (item == 2) {
        showEstabelecimentos = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesquisar'),
        actions: [
          PopupMenuButton<int>(
            icon: Icon(Icons.filter_list),
            onSelected: (item) => handleFilterToggle(item),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(
                      Icons.store,
                      color:
                          showEstabelecimentos ? secondaryColor : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Estabelecimentos',
                      style: TextStyle(
                        color:
                            showEstabelecimentos ? secondaryColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem<int>(
                value: 2,
                child: Row(
                  children: [
                    Icon(
                      Icons.event,
                      color:
                          showEstabelecimentos ? Colors.grey : secondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Eventos',
                      style: TextStyle(
                        color:
                            showEstabelecimentos ? Colors.grey : secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : showEstabelecimentos
              ? Padding(
                  padding: EdgeInsets.fromLTRB(
                      20.0, 0.0, 20.0, 8.0), // left, top, right, bottom
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15.0,
                      mainAxisSpacing: 15.0,
                    ),
                    itemCount: areas.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          // Implemente o que deseja fazer ao clicar no quadrado aqui
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AreaEstabelecimentos(
                                        postoID: widget.postoID,
                                        areaID: areas[index].id,
                                        NomeArea: areas[index].nome,
                                      )));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  areas[index].nome,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(Icons.local_taxi,
                                    color: Colors.white, size: 70),
                              ]),
                        ),
                      );
                    },
                  ),
                )
              : EventosGridView(postoID: widget.postoID,),
      bottomNavigationBar: NavBar(postoID: widget.postoID, index: 1),
    );
  }
}
