import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pint/screens/pesquisar/eventos/calendario.dart';
import 'package:pint/screens/pesquisar/eventos/meusEventos.dart';
import 'package:pint/screens/pesquisar/eventos/minhasInscricoes.dart';
import 'package:pint/screens/pesquisar/eventos/preferenciasEventos.dart';
import 'package:pint/screens/pesquisar/eventos/todosEventos.dart';
import 'package:pint/utils/colors.dart';

class EventosGridView extends StatelessWidget {
  final int postoID;

  const EventosGridView({
    Key? key,
    required this.postoID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 8.0),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      crossAxisCount: 2,
      children: <Widget>[
        _buildEventoTile(
          titulo: 'Para Ti',
          iconData: Icons.favorite,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreferenciasEventosPage(
                  postoID: postoID,
                ),
              ),
            );
          },
        ),
        _buildEventoTile(
          titulo: 'Próximos Eventos',
          iconData: Icons.event_note_sharp,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TodosEventosPage(
                  postoID: postoID,
                ),
              ),
            ); // Navegar para a página 'Todos os Eventos'
          },
        ),
        _buildEventoTile(
          titulo: 'Calendário',
          iconData: Icons.calendar_month,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Calendario(
                  postoID: postoID,
                ),
              ),
            ); // Navegar para a página 'Calendário'
          },
        ),
        _buildEventoTile(
          titulo: 'Os Meus Eventos',
          iconData: Icons.edit_calendar,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MeusEventosPage(
                  postoID: postoID,
                ),
              ),
            ); // Navegar para a página 'Todos os Eventos'
          },
        ),
        _buildEventoTile(
          titulo: 'Minhas Inscrições',
          iconData: Icons.check_box,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MinhasInscricoesPage(
                  postoID: postoID,
                ),
              ),
            ); // Navegar para a página 'Minhas Inscrições'
          },
        ),
      ],
    );
  }

  Widget _buildEventoTile({
    required String titulo,
    required IconData iconData,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: primaryColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              titulo,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize:
                    titulo.length > 12 ? 11 : 14, // Ajuste de tamanho de fonte
              ),
            ),
            Icon(
              iconData,
              color: Colors.white,
              size: 90,
            ),
          ],
        ),
      ),
    );
  }
}
