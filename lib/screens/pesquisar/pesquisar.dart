import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pint/models/area.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/eventos_grid.dart';
import 'package:pint/widgets/verifica_conexao.dart';
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
  bool isServerOff = false;

  @override
  void initState() {
    super.initState();
    loadAreas();
  }

  void loadAreas() async {
    try{
    final fetchedAreas = await fetchAreas(context);
    setState(() {
      areas = fetchedAreas;
      isLoading = false;
    });}
    catch (e){
      setState(() {
        isLoading=false;
        isServerOff = true;
      });
    }
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

  final Map<String, IconData> iconMap = {
    'LocalHospitalOutlined': Icons.local_hospital,
    'SportsSoccerOutlined': Icons.sports_soccer,
    'SchoolOutlined': Icons.school,
    'RestaurantOutlined': Icons.restaurant,
    'BedOutlined': Icons.bed,
    'DirectionsCarOutlined': Icons.directions_car,
    'DeckOutlined': Icons.deck,
    'AccountBalanceOutlined': Icons.account_balance,
    'PublicOutlined': Icons.public,
    'BuildOutlined': Icons.build,
    'ScienceOutlined': Icons.science,
    'PaletteOutlined': Icons.palette,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
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
              const PopupMenuDivider(),
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
      body: VerificaConexao(isLoading: isLoading, isServerOff: isServerOff, child: showEstabelecimentos
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(
                      20.0, 0.0, 20.0, 8.0), // left, top, right, bottom
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15.0,
                      mainAxisSpacing: 15.0,
                    ),
                    itemCount: areas.length,
                    itemBuilder: (BuildContext context, int index) {
                      String areaIconName =
                          areas[index].icone ?? ''; // Nome do ícone da área

                      IconData? areaIcon = iconMap[areaIconName];
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
                                AutoSizeText(
                                  areas[index].nome,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                // Mostra o ícone correspondente, se disponível
                                areaIcon != null
                                    ? Icon(
                                        areaIcon,
                                        color: Colors.white,
                                        size: 90,
                                      )
                                    : const Icon(
                                        Icons.settings,
                                        color: Colors.white,
                                        size: 90,
                                      ), // fazer mapa de icons dinamico
                              ]),
                        ),
                      );
                    },
                  ),
                )
              : EventosGridView(
                  postoID: widget.postoID,
                ),
      ),
      bottomNavigationBar: NavBar(postoID: widget.postoID, index: 1),
    );
  }
}
