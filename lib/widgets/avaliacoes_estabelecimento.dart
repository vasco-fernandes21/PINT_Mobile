import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pint/api/AvaliacoesAPI.dart';
import 'package:pint/models/avaliacao.dart';
import 'package:pint/screens/perfil/outroPerfil.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/evento_functions.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/alert_confirmation.dart';
import 'package:pint/widgets/avaliacao_input.dart';
import 'package:pint/widgets/custom_button.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvaliacoesList extends StatefulWidget {
  final List<Avaliacao> avaliacoes;
  final int estabelecimentoId;
  final int myUserId, postoID;

  AvaliacoesList({required this.avaliacoes, required this.estabelecimentoId, required this.myUserId, required this.postoID});

  @override
  _AvaliacoesListState createState() => _AvaliacoesListState();
}

class _AvaliacoesListState extends State<AvaliacoesList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<Avaliacao> respostas = [];
  final TextEditingController _comentarioController = TextEditingController();
  final api = AvaliacoesAPI();
  int? _rating;
  bool isRatingNull = false;
  bool isUpvoted=false;
  bool isDownvoted=false;
  int? idPai;

  String hintText = 'Escreva o seu comentário...';
  final GlobalKey _targetKey = GlobalKey();


      Future<void> _upvote(Avaliacao avaliacao) async {
        final SharedPreferences prefs = await _prefs;

        try {
        final response = api.adicionarUpvoteEstabelecimento(avaliacao.id, prefs.getString('token'));
        
        } catch (e) {

        }
        }

  Future<void> _downvote(Avaliacao avaliacao) async {
        final SharedPreferences prefs = await _prefs;

        try {
        final response = api.adicionarDownvote(avaliacao.id, prefs.getString('token'));

          setState(() {
            isUpvoted = false;
            isDownvoted = true;
          });
        } catch (e) {

        }
        }


  Future<void> _createComentario() async {
    /*if(_comentarioController.text.isEmpty){
        Fluttertoast.showToast(
          msg: 'Escreve um comentário.',
          backgroundColor: errorColor,
          fontSize: 12);
          return;
    }*/
        if (_rating == null) {
      setState(() {
        isRatingNull = true;
      });
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (idPai == null)
    {
    final response = await api.criarAvaliacaoEstabelecimento(
        widget.estabelecimentoId, widget.myUserId, _rating, _comentarioController.text);

    if (response.statusCode == 200) {
      // Sucesso
      Fluttertoast.showToast(
          msg: 'Avaliação enviado com sucesso!',
          backgroundColor: successColor,
          fontSize: 12);
    } else {
      // Falha
      Fluttertoast.showToast(
          msg: 'Falha ao enviar avaliação.',
          backgroundColor: errorColor,
          fontSize: 12);
    }
    } else {
      try {
        await api.criarRespostaAvaliacao(idPai!, _rating, _comentarioController.text, prefs.getString('token'));
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
    /*TextField(
          key: _targetKey,
          controller: _comentarioController,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: 3,
        ),*/
    AvaliacaoInput(key: _targetKey,
      controller: _comentarioController,  onRatingUpdate: (rating) {
                                setState(() {
                                  _rating = rating.round();
                                  isRatingNull = false;
                                });
                              }, validator: isRatingNull, hintText: hintText,),
    const SizedBox(height: 5,),
    CustomButton(onPressed: _createComentario, title: 'Enviar'),
    const SizedBox(height: 20,),
    widget.avaliacoes.isEmpty
    ? const Center(child: Text('Ainda não existem avaliações'),)
    : ListView.builder(
      itemCount: widget.avaliacoes.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final comentario = widget.avaliacoes[index];
        return _buildComentario(comentario);
      },
    ),
    ]
    );
  }

  Widget _buildComentario(Avaliacao avaliacao) {
    return 
    Padding(padding: (avaliacao.idPai!= null)  ? const EdgeInsets.only(left: 15) : EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: InkWell(child: userCircleAvatar(imageUrl: avaliacao.fotoUtilizador, idGoogle: avaliacao.idGoogle, idFacebook: avaliacao.idFacebook),
          onTap: () {
             Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OutroPerfilPage(userId: avaliacao.idUtilizador, postoID: widget.postoID,)
                            ),
                          );
          },
          ),
          title: AutoSizeText(avaliacao.nomeUtilizador, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14,), maxLines: 1,),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                          children: List.generate(
                            avaliacao.classificacao,
                            (index) => Icon(Icons.star, color: Colors.amber),
                          ),
              ),
              ReadMoreText(avaliacao.comentario ?? '', trimMode: TrimMode.Line,
                              trimLines: 7,
                              colorClickableText: Colors.blue,
                              trimCollapsedText: 'mostrar mais',
                              trimExpandedText: 'mostrar menos',),
              const SizedBox(height: 2),
              Text(formatDataPublicacao(avaliacao.data),
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 3,),
              Row(
        children: [
          GestureDetector(
            onTap: () { _alertaConfirmacaoDenunciar(context, avaliacao.id); },
            child: const Icon(
              Icons.warning_amber,
              color: Colors.red, // Pode escolher outra cor se preferir
              size: 27,
            ),
          ),
          const SizedBox(width: 10,), // Espaço entre o ícone e o texto
          GestureDetector(
            onTap:() { setState(() {
              idPai = avaliacao.id;
              hintText= 'A responder a ${avaliacao.nomeUtilizador}...';
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
                  GestureDetector(onTap: () { _upvote(avaliacao);}, child:  Icon(Icons.thumb_up, color: Colors.grey, size: 20)),
                  const SizedBox(width: 4),
                  Text('${avaliacao.upvotes ?? 0}'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(onTap: () { _downvote(avaliacao);}, child: Icon(Icons.thumb_down, color: Colors.grey, size: 20),
   ),
                  SizedBox(width: 4),
                  Text('${avaliacao.downvotes ?? 0}'),
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
