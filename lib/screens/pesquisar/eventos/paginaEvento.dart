import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pint/api/FotosAPI.dart';
import 'package:pint/api/InscricaoAPI.dart';
import 'package:pint/api/api.dart';
import 'package:pint/models/avaliacao.dart';
import 'package:pint/models/evento.dart';
import 'package:pint/models/foto.dart';
import 'package:pint/models/inscricao.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/screens/pesquisar/eventos/editarEvento.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/utils/image_picker.dart';
import 'package:pint/widgets/alert_confirmation.dart';
import 'package:pint/widgets/comentarios_evento.dart';
import 'package:pint/widgets/custom_button.dart';
import 'package:pint/widgets/image_carousel.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pint/utils/evento_functions.dart';

class EventoPage extends StatefulWidget {
  final int postoID;
  final int eventoID;

  EventoPage({
    required this.postoID,
    required this.eventoID,
  });

  @override
  State<EventoPage> createState() => _EventoPageState();
}

class _EventoPageState extends State<EventoPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late String? token;
  final api = ApiClient();
  bool isLoading = true;
  Evento? evento;
  Utilizador? myUser;
  List<Inscricao> inscricoes = [];
  bool isMyUserTheOwner = false;
  bool isMyUserRegistered = false;
  List<Avaliacao> comentarios = [];
  List<Avaliacao>todosComentariosOrdenados = [];
  List<Foto> fotos = [];
  List<String> urlFotos = [];

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  CameraPosition? _localizacao;
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    loadMyUser();
  }

  void loadMyUser() async {
    try {
      final SharedPreferences prefs = await _prefs;
      setState(() {
        token = prefs.getString('token');
      });
      final fetchedUser = await fetchUtilizadorCompleto();
      setState(() {
        myUser = fetchedUser;
      });
      loadEvento();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro user: $e'),
        ),
      );
    }
  }

  void loadEvento() async {
    try {
      final fetchedEvento = await fetchEvento(widget.eventoID);
      setState(() {
        evento = fetchedEvento;
        isMyUserTheOwner = verificaCriador(myUser!.id, evento!);
      });
      setLatitudeLongitude(evento!.morada);
      loadComentarios();
      loadFotos();
      loadInscricoes();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro evento: $e'),
        ),
      );
    }
  }

  void loadInscricoes() async {
    try {
      final fetchedInscricoes = await fetchInscricoes(context, widget.eventoID);
      setState(() {
        inscricoes = fetchedInscricoes;
        isMyUserRegistered = verificaInscricao(myUser!.id, inscricoes);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void loadComentarios() async {
    try {
      final fetchedComentarios =
          await fetchComentarios(context, widget.eventoID);
      setState(() {
        comentarios = fetchedComentarios;
      });
      await _carregarTodosComentarios();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro comments: $e'),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

    Future<void> _carregarTodosComentarios() async {
    List<Avaliacao> comentariosOrdenados = [];

    for (Avaliacao comentarioPai in comentarios) {
      await _adicionarComentarioERepostasRecursivamente(
          comentariosOrdenados, comentarioPai);
    }

    setState(() {

      todosComentariosOrdenados = filtrarComentariosNaoNulos(comentariosOrdenados);
    });
  }

  Future<void> _adicionarComentarioERepostasRecursivamente(
      List<Avaliacao> lista, Avaliacao comentario) async {
    // Adiciona o comentário atual na lista
    lista.add(comentario);

    // Carrega as respostas para o comentário atual
    final fetchedRespostas =
        await fetchRespostasComentario(context, comentario.id);

    // Adiciona todas as respostas e suas sub-respostas de forma recursiva
    if (fetchedRespostas.isNotEmpty) {
      for (Avaliacao resposta in fetchedRespostas) {
        await _adicionarComentarioERepostasRecursivamente(lista, resposta);
      }
    }
  }

  void loadFotos() async {
    try {
      final fetchedFotos = await fetchFotosEvento(context, widget.eventoID);
      setState(() {
        fotos = fetchedFotos;
        if (evento?.foto != null) {
          urlFotos.add(evento!.foto!);
        }
        for (var foto in fotos) {
          urlFotos.add(foto.foto);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro fotos: $e'),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> setLatitudeLongitude(String morada) async {
    try {
      List<Location> locations = await locationFromAddress(morada);
      if (locations.isNotEmpty) {
        setState(() {
          latitude = locations.first.latitude;
          longitude = locations.first.longitude;
        });

        _localizacao =
            CameraPosition(target: LatLng(latitude!, longitude!), zoom: 15);
      }
    } catch (e) {
      print('Erro ao obter localização: $e');
      isLoading = false;
    }
  }

  void _alertaConfirmacao(BuildContext context, bool inscrito) {
    if (inscrito) {
      ConfirmationAlert.show(
          context: context,
          onConfirm: _destroyInscricao,
          desc: 'Tens a certeza que te queres desinscrever?');
    } else {
      ConfirmationAlert.show(
          context: context,
          onConfirm: _createInscricao,
          desc: 'Tens a certeza que te queres inscrever?');
    }
  }

  Future<void> _createInscricao() async {
    final api = InscricoesAPI();
    final response = await api.criarInscricaoEvento(widget.eventoID, token);

    if (response.statusCode == 200) {
      // Sucesso
      setState(() {
        isMyUserRegistered = true;
      });

      Fluttertoast.showToast(
          msg: 'Inscrição efetuada com sucesso!',
          backgroundColor: successColor,
          fontSize: 12);
    } else {
      // Falha
      Fluttertoast.showToast(
          msg: 'Erro ao efetuar inscrição.',
          backgroundColor: errorColor,
          fontSize: 12);
    }
  }

  Future<void> _destroyInscricao() async {
    final api = InscricoesAPI();
    final response = await api.apagarInscricaoEvento(widget.eventoID);

    if (response.statusCode == 200) {
      // Sucesso
      setState(() {
        isMyUserRegistered = false;
      });

      Fluttertoast.showToast(
          msg: 'Inscrição cancelada com sucesso!',
          backgroundColor: successColor,
          fontSize: 12);
    } else {
      // Falha
      Fluttertoast.showToast(
          msg: 'Erro ao desinscrever.',
          backgroundColor: errorColor,
          fontSize: 12);
    }
  }

void selectImage() async {
  final ImagePicker _picker = ImagePicker();
  
  // Seleciona uma imagem da galeria
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    final file = File(image.path);
    final api = FotosAPI();
    final response = await api.adicionarFotoEvento(evento!.id, myUser!.id, file);

    if (response.statusCode == 200){
Fluttertoast.showToast(
          msg: 'Foto enviada para aprovação!',
          backgroundColor: successColor,
          fontSize: 12);
    } else{
      Fluttertoast.showToast(
          msg: 'Erro ao enviar foto.',
          backgroundColor: errorColor,
          fontSize: 12);
    }
  
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isLoading
            ? const Text('Evento')
            : AutoSizeText(
                evento!.titulo,
              ),
        actions: [
          if (isLoading == false)
            IconButton(
                onPressed: selectImage, icon: const Icon(Icons.add_a_photo)),
          if (isLoading == false)
            if (evento!.estado == false && isMyUserTheOwner)
              IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditarEventoPage(
                              postoID: widget.postoID, evento: evento!)),
                    );
                  },
                  icon: const Icon(Icons.edit))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : evento == null
              ? const Center(
                  child: Text('Nenhum evento encontrado.'),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              urlFotos.isNotEmpty
                                  ? ImageCarousel(imageUrls: urlFotos, isEstabelecimento: false,)
                                  : Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: Colors.grey,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                              const SizedBox(
                                height: 10,
                              ),
                              AutoSizeText(
                                evento!.titulo,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                              ),
                              Text(
                                  '${evento?.nomeArea} >> ${evento?.nomeSubarea}'),
                              if (evento!.estado == false)
                                const Text(
                                  'Evento pendente à espera de aprovação',
                                  style: TextStyle(
                                      color: Colors.amber, fontSize: 12),
                                ),
                              const SizedBox(
                                height: 15,
                              ),
                              const Text(
                                'Descrição',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              ReadMoreText(
                                evento!.descricao,
                                trimMode: TrimMode.Line,
                                trimLines: 7,
                                colorClickableText: Colors.blue,
                                trimCollapsedText: 'mostrar mais',
                                trimExpandedText: 'mostrar menos',
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              const Text(
                                'Data',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                formatarDataHora(evento!.data, evento!.hora),
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              const Text(
                                'Localização',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              if (latitude != null &&
                                longitude != null &&
                                _localizacao != null)
                              SizedBox(
                                width: double.infinity,
                                height: 200,
                                child: 
                                GoogleMap(
                                  initialCameraPosition: _localizacao!,
                                  markers: {
                                    Marker(
                                      markerId: MarkerId('restaurant'),
                                      position: LatLng(latitude!, longitude!),
                                    ),
                                  },
                                  mapType: MapType.normal,
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    _controller.complete(controller);
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              if (evento!.estado && evento!.inscricaoAberta)
                                isMyUserRegistered
                                    ? CustomButton(
                                        onPressed: () {
                                          _alertaConfirmacao(context, true);
                                        },
                                        title: 'Desinscrever',
                                        backgroundColor: Colors.grey.shade200,
                                        textColor: secondaryColor,
                                      )
                                    : CustomButton(
                                        onPressed: () {
                                          _alertaConfirmacao(context, false);
                                        },
                                        title: 'Inscrever'),
                              const SizedBox(
                                height: 15,
                              ),
                              const Text(
                                'Comentários',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              comentarios.isEmpty
                                  ? const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20),
                                      child: Center(
                                          child: Text(
                                              'Ainda não existem comentários')))
                                  : ComentariosList(comentarios: todosComentariosOrdenados, eventoId: evento!.id,),
                            ]),
                      )
                    ],
                  ),
                ),
      bottomNavigationBar: NavBar(postoID: widget.postoID, index: 1),
    );
  }
}
