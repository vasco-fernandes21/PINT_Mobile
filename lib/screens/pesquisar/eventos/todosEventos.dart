import 'package:flutter/material.dart';
import 'package:pint/models/evento.dart';
import 'package:pint/navbar.dart';
import 'package:pint/screens/pesquisar/eventos/paginaEvento.dart';
import 'package:pint/utils/evento_functions.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/evento_card.dart';

class TodosEventosPage extends StatefulWidget {
  final int postoID;

  TodosEventosPage({required this.postoID});

  @override
  State<TodosEventosPage> createState() => _TodosEventosPageState();
}

class _TodosEventosPageState extends State<TodosEventosPage> {
  bool isLoading = true;
  List<Evento> eventos = [];

  @override
  void initState() {
    super.initState();
    loadEventos();
  }

  void loadEventos() async {
    final fetchedEventos = await fetchEventos(context, widget.postoID);
    setState(() {
      eventos = filtrarEOrdenarEventosFuturos(fetchedEventos);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Próximos Eventos'),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : eventos.isEmpty
                ? Center(
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
                  bottomNavigationBar: NavBar(postoID: widget.postoID, index: 1),
                  );
  }
}
