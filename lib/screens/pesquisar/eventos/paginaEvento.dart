import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pint/api/InscricaoAPI.dart';
import 'package:pint/api/api.dart';
import 'package:pint/models/evento.dart';
import 'package:pint/models/inscricao.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/alert_confirmation.dart';
import 'package:pint/widgets/custom_button.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pint/utils/evento_functions.dart';

class EventoPage extends StatefulWidget {
  final int postoID;
  final int eventoID;
  final String nomeEvento;

  EventoPage(
      {required this.postoID,
      required this.eventoID,
      required this.nomeEvento});

  @override
  State<EventoPage> createState() => _EventoPageState();
}

class _EventoPageState extends State<EventoPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final api = ApiClient();
  bool isLoading = true;
  Evento? evento;
  Utilizador? myUser;
  List<Inscricao> inscricoes = [];
  bool isMyUserTheOwner = false;
  bool isMyUserRegistered = false;

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
      String? token = prefs.getString('token');
      final fetchedUser = await fetchUtilizadorCompleto(token!);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inscricoes: $e'),
        ),
      );
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
          onConfirm: () {},
          desc: 'Tens a certeza que queres te desinscrever?');
    } else {
      ConfirmationAlert.show(
          context: context,
          onConfirm: _createInscricao,
          desc: 'Tens a certeza que queres te inscrever?');
    }
  }

  Future<void> _createInscricao() async {
    final api = InscricoesAPI();
    final response = await api.criarInscricaoEvento(widget.eventoID);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomeEvento),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : evento == null
              ? Center(
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
                            evento?.foto != null
                                ? Image.network(
                                    '${api.baseUrl}/uploads/eventos/${evento!.foto}',
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
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              evento!.titulo,
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
                            /*if (latitude != null &&
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
                              ),*/
                            const SizedBox(
                              height: 15,
                            ),
                            isMyUserRegistered
                                ? CustomButton(
                                    onPressed: () {
                                      _alertaConfirmacao(context, true);
                                    },
                                    title: 'Desinscrever',
                                    backgroundColor: Colors.grey.shade200,
                                    textColor: primaryColor,
                                  )
                                : CustomButton(
                                    onPressed: () {
                                      _alertaConfirmacao(context, false);
                                    },
                                    title: 'Inscrever'),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
      bottomNavigationBar: NavBar(postoID: widget.postoID, index: 1),
    );
  }
}
