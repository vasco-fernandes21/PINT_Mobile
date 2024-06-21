import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pint/api/postosAreasAPI.dart';
import 'EstabelecimentosPorArea.dart';
import 'package:pint/navbar.dart';

class Pesquisar extends StatefulWidget {
  final int postoID;
  Pesquisar({required this.postoID});

  @override
  _PesquisarState createState() => _PesquisarState();
}

class _PesquisarState extends State<Pesquisar> {
  List<Map<String, dynamic>> areas = [];
  Map<String, dynamic>? Area;
  int selectedAreaId = 0;
  bool isLoading = true;

  

 @override
  void initState() {
    super.initState();
    fetchAreas();
  }

  void fetchAreas() async {
    final api = PostosAreasAPI();
    final response = await api.listarAreas();

  if (response.statusCode == 200) {
      try {
        // Decodificar a resposta JSON
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        // Verificar se a chave 'data' existe na resposta
        if (jsonResponse.containsKey('data')) {
          // Acessar a lista de postos dentro de 'data'
          List<dynamic> areasData = jsonResponse['data'];

          setState(() {
            areas = areasData.map<Map<String, dynamic>>((item) => {
              'id': item['id'],
              'nome': item['nome'],
            }).cast<Map<String, dynamic>>().toList();
            isLoading = false;
          });
        } else {
          // Se 'data' não estiver presente na resposta
          isLoading =false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dados de postos não encontrados na resposta')),
          );
        }
      } catch (e) {
        // Capturar e mostrar erros de decodificação JSON
        isLoading =false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar os dados: $e')),
        );
      }
    } else {
      // Tratar erros de status HTTP
      isLoading =false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: ${response.statusCode}')),
      );
    }
  }


@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesquisar'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
               padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 8.0), // left, top, right, bottom
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
                        MaterialPageRoute(builder: (context) => AreaEstabelecimentos(postoID: widget.postoID, areaID: areas[index]['id'], NomeArea: areas[index]['nome'],))
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [ 
                         Text(
                          areas[index]['nome'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                            ),
                        ),
                        Icon(
                            Icons.sports_soccer,
                            color: Colors.white,
                            size: 70
                          ),
                        ]
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomNavigationBar: NavBar(postoID: widget.postoID, index: 1),
    );

  }

}