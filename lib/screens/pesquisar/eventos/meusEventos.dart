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

class MeusEventosPage extends StatefulWidget {
  final int postoID;

  MeusEventosPage({required this.postoID});

  @override
  State<MeusEventosPage> createState() => _MeusEventosPagePageState();
}

class _MeusEventosPagePageState extends State<MeusEventosPage> {
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
    final fetchedEventos = await fetchMyEventos(context);
    setState(() {
      eventos = fetchedEventos;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Eventos'),
      ),
      body: VerificaConexao(isLoading: isLoading, isServerOff: isServerOff, child: 
       eventos.isEmpty
              ? const Center(
                  child: Text('Nenhum evento encontrado.'),
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
