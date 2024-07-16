import 'package:flutter/material.dart';
import 'package:pint/models/evento.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/screens/pesquisar/eventos/paginaEvento.dart';
import 'package:pint/utils/evento_functions.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/evento_card.dart';
import 'package:pint/widgets/verifica_conexao.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasEventosPage extends StatefulWidget {
  final int postoID;

  PreferenciasEventosPage({required this.postoID});

  @override
  State<PreferenciasEventosPage> createState() =>
      _PreferenciasEventosPageState();
}

class _PreferenciasEventosPageState extends State<PreferenciasEventosPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isLoading = true;
  bool isServerOff = false;
  List<Evento> eventos = [];
  Utilizador? myUser;

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
      });
      loadEventos();
    } catch (e) {
      setState(() {
        isLoading = false;
        isServerOff = true;
      });
    }
  }

  void loadEventos() async {
    final fetchedEventos = await fetchEventos(context, widget.postoID);
    setState(() {
      eventos = filtrarEventosPorPreferencia(fetchedEventos, myUser!);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Para Ti'),
      ),
      body: VerificaConexao(isLoading: isLoading, isServerOff: isServerOff, child: 
      (myUser?.idAreaPreferencia == null &&
                  myUser?.idSubareaPreferencia == null)
              ? Center(child: Text('Não tens nenhuma preferência'))
              : eventos.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Nenhum evento encontrado para as tuas preferências :(',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: eventos.map((evento) {
                          return EventoCard(
                            evento: evento,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventoPage(
                                    eventoID: evento.id,
                                    postoID: widget.postoID,
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
