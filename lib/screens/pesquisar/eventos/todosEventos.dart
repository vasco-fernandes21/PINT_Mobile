import 'package:flutter/material.dart';
import 'package:pint/models/evento.dart';
import 'package:pint/navbar.dart';
import 'package:pint/screens/pesquisar/eventos/paginaEvento.dart';
import 'package:pint/utils/evento_functions.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/evento_card.dart';
import 'package:pint/widgets/verifica_conexao.dart';

class TodosEventosPage extends StatefulWidget {
  final int postoID;

  TodosEventosPage({required this.postoID});

  @override
  State<TodosEventosPage> createState() => _TodosEventosPageState();
}

class _TodosEventosPageState extends State<TodosEventosPage> {
  bool isLoading = true;
  bool isServerOff = false;
  List<Evento> eventos = [];

  @override
  void initState() {
    super.initState();
    loadEventos();
  }

  void loadEventos() async {
    try {
      final fetchedEventos = await fetchEventos(context, widget.postoID);
      setState(() {
      eventos = filtrarEOrdenarEventosFuturos(fetchedEventos);
      isLoading = false;
    }); 
    } catch (e) {
      setState(() {
        isLoading = false;
        isServerOff = true;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Próximos Eventos'),
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
