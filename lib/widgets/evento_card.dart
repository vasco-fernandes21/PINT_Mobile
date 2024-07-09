import 'package:flutter/material.dart';
import 'package:pint/api/api.dart';
import 'package:pint/models/evento.dart';

class EventoCard extends StatelessWidget {
  final Evento evento;
  final Function onTap;
  final api = ApiClient();

   EventoCard({
    Key? key,
    required this.evento,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            evento.foto != null
                ? Image.network(
                    '${api.baseUrl}/uploads/eventos/${evento.foto}',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (evento.estado == false)
                  const Text('Evento pendente à espera de aprovação', style: TextStyle(color: Colors.amber , fontSize: 11.5),),
                  const SizedBox(height: 5),
                  Text(evento.data),
                  const SizedBox(height: 5),
                  Text(evento.morada),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
