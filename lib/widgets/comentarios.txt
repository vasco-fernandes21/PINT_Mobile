import 'package:flutter/material.dart';
import 'package:pint/api/api.dart';
import 'package:pint/models/avaliacao.dart';
import 'package:pint/utils/evento_functions.dart';
import 'package:pint/utils/fetch_functions.dart';

class ComentariosList extends StatelessWidget {
  final List<Avaliacao> comentarios;
  final api = ApiClient();

  ComentariosList({required this.comentarios});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: comentarios.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final comentario = comentarios[index];

        return Column(
          children: [
          ListTile(
            leading: userCircleAvatar(imageUrl: comentario.fotoUtilizador, idGoogle: null),
            title: Text(comentario.nomeUtilizador, style: TextStyle(fontSize: 13),),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comentario.comentario ?? ''),
                SizedBox(height: 2),
                Text(formatDataPublicacao(comentario.data), style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.thumb_up, color: Colors.grey, size: 20),
                    SizedBox(width: 4),
                    Text('${comentario.upvotes ?? 0}'),
                  ],
                ),
                const SizedBox(height: 7,),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.thumb_down, color: Colors.grey, size: 20),
                    SizedBox(width: 4),
                    Text('${comentario.downvotes ?? 0}'),
                  ],
                ),
              ],
            ),
            titleAlignment: ListTileTitleAlignment.top,
          ),
          const Divider()
          ]
        );
      },
    );
  }
}