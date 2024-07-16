import 'dart:convert';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:intl/intl.dart';
import 'package:pint/api/postosAreasAPI.dart'; 
import 'package:pint/models/estabelecimento.dart';
import 'package:pint/models/evento.dart';
import 'package:pint/models/posto.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/screens/pesquisar/eventos/todosEventos.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/evento_functions.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/custom_button.dart';
import 'package:pint/widgets/estabelecimento_row.dart';
import 'package:pint/widgets/evento_row.dart';
import 'package:pint/widgets/verifica_conexao.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final int postoID;

  HomePage({required this.postoID});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  bool isServerOff = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Utilizador? myUser;
  List<Evento> eventos = [];
  List<Estabelecimento> estabelecimentos = [];
  String saudacao = '';
  Posto? posto;
  

  @override
  void initState() {
    super.initState();
    loadMyUser();
  }

  void loadMyUser() async {
    try {
    final SharedPreferences prefs = await _prefs;
    String? token = prefs.getString('token');
    final fetchedUser = await fetchUtilizadorCompleto();
    setState(() {
      myUser = fetchedUser;
      print(myUser?.nome);
      print(myUser?.ultimoLogin);
      updateSaudacao();
    });
    loadEventos();
    fetchPostoById(widget.postoID);
    loadEstabelecimentos();
    } catch (e) {
      setState(() {
        isLoading= false;
        isServerOff = true;
      });
    }
  }

  void loadEventos() async {
    final fetchedEventos = await fetchEventos(context, widget.postoID);
    setState(() {
      eventos = filtrarEOrdenarEventosFuturos(fetchedEventos);
    });
  }

      void loadEstabelecimentos() async {
    try {
      final fetchedEstabelecimentos =
          await fetchTodosEstabelecimentosPosto(context, widget.postoID);
      setState(() {
        fetchedEstabelecimentos.shuffle(Random());
        estabelecimentos = fetchedEstabelecimentos.take(3).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<Posto?> fetchPostoById(int id) async {
    try {
      final api = PostosAreasAPI();
      final response = await api.listarPostos();

      if (response.statusCode == 200) {
        // Decodificar a resposta JSON
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('data')) {
          // Acessar a lista de postos dentro de 'data'
          List<dynamic> postos = jsonResponse['data'];
          List<Posto> postosList = postos.map<Posto>((item) => Posto.fromJson(item)).toList();

          // Encontrar o posto com o ID fornecido
          setState(() {
            posto = postosList.firstWhere((posto) => posto.id == id);
          });
          return postosList.firstWhere((posto) => posto.id == id);
        } else {
          return null;
        }
      } else {
        throw Exception('Failed to load postos');
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  void updateSaudacao() {
    if (myUser != null) {
      final currentHour = DateTime.now().hour;

      if (myUser!.ultimoLogin != null) {
        final currentDate = DateTime.now();
        final lastLoginDate = DateTime.parse(myUser!.ultimoLogin!);

        final diff = currentDate.difference(lastLoginDate);
        final diffDays = diff.inDays;

        if (diffDays >= 15) {
          setState(() {
            saudacao = 'Seja bem-vindo novamente,\n${myUser!.nome}';
          });
          return;
        }
      }

      if (currentHour >= 6 && currentHour < 13) {
        setState(() {
          saudacao = 'Bom dia,\n${myUser!.nome}';
        });
      } else if (currentHour >= 13 && currentHour < 20) {
        setState(() {
          saudacao = 'Boa tarde,\n${myUser!.nome}';
        });
      } else {
        setState(() {
          saudacao = 'Boa noite,\n${myUser!.nome}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
      ),
      body: VerificaConexao(isLoading: isLoading, isServerOff: isServerOff, child:
           Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [secondaryColor, Colors.lightBlueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: AutoSizeText(
                        saudacao,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Próximos Eventos',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    ...eventos
                        .take(3)
                        .map((evento) => EventoRow(
                              evento: evento,
                              postoID: widget.postoID,
                            )),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TodosEventosPage(postoID: widget.postoID),
                          ),
                        );
                      },
                      title: 'Ver Todos os Eventos',
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                     Text(
                      'Explora ${posto?.nome}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    ...estabelecimentos
                        .map((estabelecimento) => EstabelecimentoRow(
                              estabelecimento: estabelecimento,
                              postoID: widget.postoID,
                            )),
                  ],
                ),
              ),
            ),
      ),
      bottomNavigationBar: NavBar(postoID: widget.postoID, index: 0),
    );
  }
}
