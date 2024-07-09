import 'package:flutter/material.dart';
import 'package:pint/models/evento.dart';
import 'package:pint/screens/pesquisar/eventos/paginaEvento.dart';

class TableEventos extends StatelessWidget {
  final List<Evento> eventos;

  TableEventos({required this.eventos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Eventos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Nome do Evento')),
            DataColumn(label: Text('Data do Evento')),
          ],
          rows: eventos.map((evento) {
            return DataRow(
              cells: [
                DataCell(
                  Text(evento.titulo),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventoPage(
                          postoID: 1, // Passe o postoID correto aqui
                          eventoID: evento.id,
                        ),
                      ),
                    );
                  },
                ),
                DataCell(
                  Text(
                    evento.data,
                  ),                  
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
