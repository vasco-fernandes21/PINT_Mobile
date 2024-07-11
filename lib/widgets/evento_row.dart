import 'package:flutter/material.dart';
import 'package:pint/api/api.dart';
import 'package:pint/models/evento.dart';
import 'package:pint/screens/pesquisar/eventos/paginaEvento.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/evento_functions.dart';

class EventoRow extends StatelessWidget {
  final Evento evento;
  final int postoID;
  final api = ApiClient();

  EventoRow({required this.evento, required this.postoID});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventoPage(
                  postoID: postoID,
                  eventoID: evento.id,
                ),
              ),
            );
        },
      child: Container(
        height: 100,
        padding: EdgeInsets.all(10), // Altura fixa para todos os cards
        child: Row(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(10), // Raio de borda para a imagem
                child: evento.foto != null
                    ? Image.network(
                        '${api.baseUrl}/uploads/eventos/${evento.foto}',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.event,
                          color: Colors.grey[600],
                        ),
                      ),
              ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    evento.titulo,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                        diasAte(evento.data), // Ajuste conforme o formato de data
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      )
    );
  }
}