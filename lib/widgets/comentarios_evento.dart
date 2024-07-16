import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pint/api/AvaliacoesAPI.dart';
import 'package:pint/models/avaliacao.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/evento_functions.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/alert_confirmation.dart';
import 'package:pint/widgets/avaliacao_input.dart';
import 'package:pint/widgets/custom_button.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComentariosList extends StatefulWidget {
  final List<Avaliacao> comentarios;
  final int eventoId;
  final int myUserId;

  ComentariosList({required this.comentarios, required this.eventoId, required this.myUserId});

  @override
  _ComentariosListState createState() => _ComentariosListState();
}

class _ComentariosListState extends State<ComentariosList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<Avaliacao> respostas = [];
  List<Avaliacao> todosComentariosOrdenados = [];
  final TextEditingController _comentarioController = TextEditingController();
  final api = AvaliacoesAPI();
  int? _rating;
  bool isRatingNull = false;
  bool isUpvoted=false;
  bool isDownvoted=false;
  int? idPai;

  String hintText = 'Escreva o seu comentário...';
  final GlobalKey _targetKey = GlobalKey();


      Future<void> _upvote(Avaliacao comentario) async {
        final SharedPreferences prefs = await _prefs;

        try {
        final response = api.adicionarUpvote(comentario.id, prefs.getString('token'));
        
        } catch (e) {

        }
        }

Future<void> _downvote(int idComentario) async {
        final SharedPreferences prefs = await _prefs;

        try {
        final response = api.adicionarDownvote(idComentario, prefs.getString('token'));

          setState(() {
            isUpvoted = false;
            isDownvoted = true;
          });
        } catch (e) {

        }
        }


  Future<void> _createComentario() async {
    if (_rating == null) {
      setState(() {
        isRatingNull = true;
      });
      return;
    }
    
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (idPai == null)
    {
    final response = await api.criarComentarioEvento(
        widget.eventoId, widget.myUserId, 3, _comentarioController.text);

    if (response.statusCode == 200) {
      // Sucesso
      Fluttertoast.showToast(
          msg: 'Comentário enviado com sucesso!',
          backgroundColor: successColor,
          fontSize: 12);
    } else {
      // Falha
      Fluttertoast.showToast(
          msg: 'Falha ao enviar comentário.',
          backgroundColor: errorColor,
          fontSize: 12);
    }
    } else {
      try {
        await api.criarRespostaComentario(idPai!, 3, _comentarioController.text, prefs.getString('token'));
        Fluttertoast.showToast(
          msg: 'Comentário respondido com sucesso!',
          backgroundColor: successColor,
          fontSize: 12);
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Falha ao responder comentário.',
          backgroundColor: errorColor,
          fontSize: 12);
      }
    }
  }

    void _alertaConfirmacaoDenunciar(BuildContext context, int comentario) {
    ConfirmationAlert.show(
        context: context,
        onConfirm: (){ _denunciarComentario(comentario);},
        desc: 'Pretende denunciar este comentário?');
  }

  Future<void> _denunciarComentario(int idComentario) async {
    final SharedPreferences prefs = await _prefs;
    try {
    await api.denunciarComentario(idComentario, prefs.getString('token'));

    Fluttertoast.showToast(
          msg: 'Comentário denunciado com sucesso!',
          backgroundColor: successColor,
          fontSize: 12);

    } catch (e) {
              Fluttertoast.showToast(
          msg: 'Falha ao denunciar comentário.',
          backgroundColor: errorColor,
          fontSize: 12);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
    children: [
    const SizedBox(height: 10,),
    AvaliacaoInput(key: _targetKey, controller: _comentarioController, onRatingUpdate: (rating) {
                                setState(() {
                                  _rating = rating.round();
                                  isRatingNull = false;
                                });
                              }, validator: isRatingNull, hintText: hintText,),
    const SizedBox(height: 5,),
    CustomButton(onPressed: _createComentario, title: 'Enviar'),
    const SizedBox(height: 20,),
    widget.comentarios.isEmpty
    ? const Center(child: Text('Ainda não existem comentários'),)
    : ListView.builder(
      itemCount: widget.comentarios.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final comentario = widget.comentarios[index];
        return _buildComentario(comentario);
      },
    ),
    ]
    );
  }

  Widget _buildComentario(Avaliacao comentario) {
    return 
    Padding(padding: (comentario.idPai!= null)  ? const EdgeInsets.only(left: 15) : EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: userCircleAvatar(imageUrl: comentario.fotoUtilizador, idGoogle: comentario.idGoogle, idFacebook: comentario.idFacebook),
          title: AutoSizeText(comentario.nomeUtilizador, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14,), maxLines: 1,),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                          children: List.generate(
                            comentario.classificacao,
                            (index) => const Icon(Icons.star, color: Colors.amber),
                          ),
              ),
              ReadMoreText(comentario.comentario ?? '', trimMode: TrimMode.Line,
                              trimLines: 7,
                              colorClickableText: Colors.blue,
                              trimCollapsedText: 'mostrar mais',
                              trimExpandedText: 'mostrar menos',),
              const SizedBox(height: 2),
              Text(formatDataPublicacao(comentario.data),
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 3,),
              Row(
        children: [
          GestureDetector(
            onTap: () { _alertaConfirmacaoDenunciar(context, comentario.id); },
            child: const Icon(
              Icons.warning_amber,
              color: Colors.red, // Pode escolher outra cor se preferir
              size: 27,
            ),
          ),
          const SizedBox(width: 10,), // Espaço entre o ícone e o texto
          GestureDetector(
            onTap:() { setState(() {
              idPai = comentario.id;
              hintText= 'A responder a ${comentario.nomeUtilizador}...';
            });
            final context = _targetKey.currentContext;
             if (context != null) {
             Scrollable.ensureVisible(context,
             duration: const Duration(seconds: 1), curve: Curves.easeInOut);
            }
            },
            child: const Text(
              'Responder',
              style: TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(onTap: () { _upvote(comentario);}, child:  const Icon(Icons.thumb_up, color: Colors.grey, size: 20)),
                  const SizedBox(width: 4),
                  Text('${comentario.upvotes ?? 0}'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(onTap: () { _downvote(comentario.id);}, child: const Icon(Icons.thumb_down, color: Colors.grey, size: 20),
   ),
                  SizedBox(width: 4),
                  Text('${comentario.downvotes ?? 0}'),
                ],
              ),
            ],
          ),
          titleAlignment: ListTileTitleAlignment.top,
        ),
        const Divider(),
      ],
    ),
    );
  }
}
