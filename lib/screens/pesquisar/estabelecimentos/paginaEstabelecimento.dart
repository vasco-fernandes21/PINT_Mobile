import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pint/api/AvaliacoesAPI.dart';
import 'package:pint/models/avaliacao.dart';
import 'package:pint/models/estabelecimento.dart';
import 'package:pint/navbar.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/alert_confirmation.dart';
import 'package:pint/widgets/avaliacao_input.dart';
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
  bool isLoading = true;
  Estabelecimento? estabelecimento;
  List<Avaliacao> avaliacoes = [];
  int numAvaliacoes = 1;
  double mediaAvaliacoes = 0;
  bool isRatingNull = false;
  int currentPage = 1;
  int itemsPerPage = 3;
  final TextEditingController _avaliacaoController = TextEditingController();

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  CameraPosition? _localizacao;
  double? latitude;
  double? longitude;

  int? _rating;

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
        });

        _localizacao =
            CameraPosition(target: LatLng(latitude!, longitude!), zoom: 15);
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

  @override
  Widget build(BuildContext context) {
    int totalPages = (avaliacoes.length / itemsPerPage).ceil();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.NomeEstabelecimento),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : estabelecimento == null
              ? Center(child: Text('Estabelecimento não encontrado.'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            estabelecimento!.foto != null
                                ? Image.network(
                                    '${api.baseUrl}/uploads/estabelecimentos/${estabelecimento!.foto}',
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
