import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pint/api/api.dart';
import 'package:pint/models/avaliacao.dart';
import 'package:pint/utils/colors.dart';
import 'package:readmore/readmore.dart';

class AvaliacoesWidget extends StatefulWidget {
  final List<Avaliacao> avaliacoes;

  AvaliacoesWidget({required this.avaliacoes});

  @override
  _AvaliacoesWidgetState createState() => _AvaliacoesWidgetState();
}

class _AvaliacoesWidgetState extends State<AvaliacoesWidget> {
  final api = ApiClient();
  int itemsPerPage = 3;
  int itemsToShow = 3;

  String formatDataPublicacao(String dataPublicacao) {
    // Formata a data de publicação no formato desejado
    DateTime parsedDate = DateTime.parse(dataPublicacao);
    Duration difference = DateTime.now().difference(parsedDate);

    if (difference.inMinutes < 1) {
      return 'agora';
    } else if (difference.inMinutes < 60) {
      int minutes = difference.inMinutes;
      return 'há ${minutes == 1 ? '1 minuto' : '$minutes minutos'}';
    } else if (difference.inHours < 24) {
      int hours = difference.inHours;
      return 'há ${hours == 1 ? '1 hora' : '$hours horas'}';
    } else {
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemsToShow,
          itemBuilder: (context, index) {
            if (index < widget.avaliacoes.length) {
              Avaliacao avaliacao = widget.avaliacoes[index];
              int classificacao = avaliacao.classificacao;

              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: avaliacao.fotoUtilizador != null
                          ? NetworkImage(
                              '${api.baseUrl}/uploads/utilizador/${avaliacao.fotoUtilizador}')
                          : AssetImage('assets/images/default-avatar.jpg')
                              as ImageProvider,
                      // Exibe uma imagem padrão caso não haja foto disponível
                      radius: 25, // Tamanho do círculo da foto do usuário
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          avaliacao.nomeUtilizador,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Row(
                          children: List.generate(
                            classificacao,
                            (index) => Icon(Icons.star, color: Colors.amber),
                          ),
                        ),
                        SizedBox(height: 4.0),
                      ],
                    ),
                    titleAlignment: ListTileTitleAlignment.top,
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (avaliacao.comentario != null)
                          ReadMoreText(
                            '${avaliacao.comentario}',
                            style: const TextStyle(fontSize: 12),
                            trimMode: TrimMode.Line,
                            trimLines: 5,
                            colorClickableText: Colors.blue,
                            trimCollapsedText: 'mostrar mais',
                            trimExpandedText: 'mostrar menos',
                          ),
                        SizedBox(height: 4.0),
                        if (avaliacao.data.isNotEmpty)
                          Text(
                            formatDataPublicacao(avaliacao.data),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          )
                      ],
                    ),
                  ),
                  const Divider(color: Colors.grey),
                ],
              );
            } else {
              return Container();
            }
          },
        ),
        const SizedBox(height: 10),
        if (itemsToShow < widget.avaliacoes.length)
          OutlinedButton(
            onPressed: () {
              setState(() {
                itemsToShow = (itemsToShow + itemsPerPage)
                    .clamp(0, widget.avaliacoes.length);
              });
            },
            child: Text("Carregar mais"),
          ),
      ],
    );
  }
}
