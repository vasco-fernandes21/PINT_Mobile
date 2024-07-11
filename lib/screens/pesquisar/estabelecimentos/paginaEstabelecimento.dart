import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pint/api/AvaliacoesAPI.dart';
import 'package:pint/api/FotosAPI.dart';
import 'package:pint/models/avaliacao.dart';
import 'package:pint/models/estabelecimento.dart';
import 'package:pint/models/foto.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/alert_confirmation.dart';
import 'package:pint/widgets/avaliacao_input.dart';
import 'package:pint/widgets/image_carousel.dart';
import 'package:pint/widgets/show_avaliacoes.dart';
import 'package:pint/widgets/sumario_avaliacoes.dart';
import 'package:readmore/readmore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pint/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EstabelecimentoPage extends StatefulWidget {
  final int postoID;
  final int estabelecimentoID;
  final String NomeEstabelecimento;

  EstabelecimentoPage(
      {required this.estabelecimentoID,
      required this.NomeEstabelecimento,
      required this.postoID});

  @override
  State<EstabelecimentoPage> createState() => _EstabelecimentoPageState();
}

class _EstabelecimentoPageState extends State<EstabelecimentoPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? token;
  bool isLoading = true;
  Estabelecimento? estabelecimento;
  List<Avaliacao> avaliacoes = [];
  int numAvaliacoes = 1;
  double mediaAvaliacoes = 0;
  bool isRatingNull = false;
  int currentPage = 1;
  int itemsPerPage = 3;
  final TextEditingController _avaliacaoController = TextEditingController();
  Utilizador? myUser;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  CameraPosition? _localizacao;
  double? latitude;
  double? longitude;

  int? _rating;

  List<Foto> fotos = [];
  List<String> urlFotos = [];


  final api = ApiClient();

  @override
  void initState() {
    super.initState();
    loadEstabelecimento();
  }

  void loadEstabelecimento() async {
    try {
      final fetchedEstabelecimentos =
          await fetchEstabelecimento(widget.estabelecimentoID);
      setState(() {
        estabelecimento = fetchedEstabelecimentos;
      });
      setLatitudeLongitude(estabelecimento!.morada);
      loadMyUser();
      loadFotos();
      loadAvaliacoes();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro user: $e'),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

    void loadFotos() async {
    try {
      final fetchedFotos = await fetchFotosEvento(context, widget.estabelecimentoID);
      setState(() {
        fotos = fetchedFotos;
        if (estabelecimento?.foto != null) {
          urlFotos.add(estabelecimento!.foto!);
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

  void loadAvaliacoes() async {
    try {
      final response = await fetchAvaliacoes(widget.estabelecimentoID);
      setState(() {
        avaliacoes = response['avaliacoes'] as List<Avaliacao>;
        numAvaliacoes = avaliacoes.length;
        mediaAvaliacoes = response['mediaAvaliacoes'] as double; 
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );*/
    }
  }

  Future<void> setLatitudeLongitude(String morada) async {
    if (morada.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      List<Location> locations = await locationFromAddress(morada);

      if (locations.isNotEmpty) {
        setState(() {
          latitude = locations.first.latitude;
          longitude = locations.first.longitude;
          print(latitude);
          print(longitude);
        });

        _localizacao = CameraPosition(target: LatLng(latitude!, longitude!), zoom: 15);
      }
    } catch (e) {
      print('Erro ao obter localização: $e');
      isLoading = false;
    }

  }

  void _alertaConfirmacao(BuildContext context) {
    if (_rating == null) {
      setState(() {
        isRatingNull = true;
      });
      return;
    }
    ConfirmationAlert.show(
        context: context,
        onConfirm: _createAvaliacao,
        desc: 'Tens a certeza que queres criar uma avaliação?');
  }

  Future<void> _createAvaliacao() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int estabelecimentoId = widget.estabelecimentoID;
    int idUtilizador =
        1; // Substitua pelo ID real do utilizador assssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
    int? classificacao = _rating;
    String? comentario =
        _avaliacaoController.text.isNotEmpty ? _avaliacaoController.text : null;

    // Chame a função para criar a avaliação
    final api_avaliacoes = AvaliacoesAPI();
    final response = await api_avaliacoes.criarAvaliacaoEstabelecimento(
        estabelecimentoId, idUtilizador, classificacao, comentario);

    if (response.statusCode == 200) {
      // Sucesso
      Fluttertoast.showToast(
          msg: 'Avaliação enviada com sucesso!',
          backgroundColor: successColor,
          fontSize: 12);
    } else {
      // Falha
      Fluttertoast.showToast(
          msg: 'Falha ao enviar a avaliação.',
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
    final response = await api.adicionarFotoEvento(estabelecimento!.id, myUser!.id, file);

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
    int totalPages = (avaliacoes.length / itemsPerPage).ceil();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.NomeEstabelecimento),
        actions: [
          IconButton(onPressed: selectImage, icon: const Icon(Icons.add_a_photo))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : estabelecimento == null
              ? const Center(child: Text('Estabelecimento não encontrado.'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            urlFotos.isNotEmpty
                            ? ImageCarousel(imageUrls: urlFotos, isEstabelecimento: true)
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
                            const SizedBox(height: 10),
                            Text(
                              estabelecimento!.nome,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Descrição',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ReadMoreText(
                              estabelecimento!.descricao,
                              trimMode: TrimMode.Line,
                              trimLines: 7,
                              colorClickableText: Colors.blue,
                              trimCollapsedText: 'mostrar mais',
                              trimExpandedText: 'mostrar menos',
                            ),
                            SizedBox(height: 15),
                            const Text(
                              'Avaliações',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            if (avaliacoes.isEmpty)
                              const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                      child: Text(
                                          'Ainda não existem avaliações'))),
                            if (avaliacoes.isNotEmpty)
                              SumarioAvaliacoesWidget(
                                  numAvaliacoes: numAvaliacoes,
                                  mediaAvaliacoes: mediaAvaliacoes,
                                  avaliacoes: avaliacoes,),
                            const SizedBox(height: 10),
                            if(avaliacoes.isNotEmpty)
                            AvaliacoesWidget(avaliacoes: avaliacoes),
                            const SizedBox(height: 15),
                            AvaliacaoInput(
                              controller: _avaliacaoController,
                              onRatingUpdate: (rating) {
                                setState(() {
                                  _rating = rating.round();
                                  isRatingNull = false;
                                });
                              },
                              validator: isRatingNull,
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: SizedBox(
                                width: 380,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _alertaConfirmacao(context);
                                  },
                                  child: const Text('Enviar Avaliação'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1D324F),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Detalhes',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Morada: ${estabelecimento?.morada}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Telefone: ${estabelecimento?.telemovel ?? ' -'}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Email: ${estabelecimento?.email ?? ' -'}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 15),
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
                                      markerId: const MarkerId('marker'),
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
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: NavBar(postoID: widget.postoID, index: 1),
    );
  }
}
