import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pint/api/AvaliacoesAPI.dart';
import 'package:pint/api/EstabelecimentosAPI.dart';
import 'package:pint/api/FotosAPI.dart';
import 'package:pint/models/avaliacao.dart';
import 'package:pint/models/estabelecimento.dart';
import 'package:pint/models/foto.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/screens/auth/loginPage.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/alert_confirmation.dart';
import 'package:pint/widgets/avaliacao_input.dart';
import 'package:pint/widgets/avaliacoes_estabelecimento.dart';
import 'package:pint/widgets/comentarios_evento.dart';
import 'package:pint/widgets/image_carousel.dart';
import 'package:pint/widgets/share_options.dart';
import 'package:pint/widgets/show_avaliacoes.dart';
import 'package:pint/widgets/sumario_avaliacoes.dart';
import 'package:pint/widgets/verifica_conexao.dart';
import 'package:readmore/readmore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pint/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EstabelecimentoPage extends StatefulWidget {
  final int estabelecimentoID;

  EstabelecimentoPage(
      {required this.estabelecimentoID,
      });

  @override
  State<EstabelecimentoPage> createState() => _EstabelecimentoPageState();
}

class _EstabelecimentoPageState extends State<EstabelecimentoPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? token;
  bool isLoading = true;
  bool isServerOff = false;
  Estabelecimento? estabelecimento;
  List<Avaliacao> avaliacoes = [];
  List<Avaliacao> todasAvaliacoesOrdenadas = [];
  int numAvaliacoes = 1;
  double mediaAvaliacoes = 0;
  bool isRatingNull = false;
  int currentPage = 1;
  int itemsPerPage = 3;
  final TextEditingController _precoController = TextEditingController();
  Utilizador? myUser;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  CameraPosition? _localizacao;
  double? latitude;
  double? longitude;

  List<Foto> fotos = [];
  List<String> urlFotos = [];

  final api = ApiClient();

  @override
  void initState() {
    super.initState();
    checkLoginAndNavigate(context);
    loadEstabelecimento();
  }

  Future<void> checkLoginAndNavigate(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (!isLoggedIn) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
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
        isServerOff = true;
      });
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
      final fetchedFotos =
          await fetchFotosEvento(context, widget.estabelecimentoID);
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
      await _carregarTodosComentarios();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _carregarTodosComentarios() async {
    List<Avaliacao> comentariosOrdenados = [];

    for (Avaliacao comentarioPai in avaliacoes) {
      await _adicionarComentarioERepostasRecursivamente(
          comentariosOrdenados, comentarioPai);
    }
    setState(() {
      todasAvaliacoesOrdenadas = comentariosOrdenados;
    });
  }

  Future<void> _adicionarComentarioERepostasRecursivamente(
      List<Avaliacao> lista, Avaliacao comentario) async {
    // Adiciona o comentário atual na lista
    lista.add(comentario);

    // Carrega as respostas para o comentário atual
    final fetchedRespostas =
        await fetchRespostasAvaliacoes(context, comentario.id);

    // Adiciona todas as respostas e suas sub-respostas de forma recursiva
    if (fetchedRespostas.isNotEmpty) {
      for (Avaliacao resposta in fetchedRespostas) {
        await _adicionarComentarioERepostasRecursivamente(lista, resposta);
      }
    }
  }

  Future<void> setLatitudeLongitude(String morada) async {
    if (morada.isEmpty) {
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

        _localizacao =
            CameraPosition(target: LatLng(latitude!, longitude!), zoom: 15);
      }
    } catch (e) {
      print('Erro ao obter localização: $e');
      isLoading = false;
    }
  }

  void editarPrecoMedio() async {
    if (_precoController.text.isEmpty) {
      return;
    }
    double novoPreco = 0;
    try {
      novoPreco = double.parse(_precoController.text);
    } catch (e) {
      return;
    }

    final api = EstabelecimentosAPI();
    final response =
        await api.editarPrecoEstabelecimento(estabelecimento!.id, novoPreco);

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: 'Preço médio enviado!',
          backgroundColor: successColor,
          fontSize: 12);
    } else {
      Fluttertoast.showToast(
          msg: 'Erro ao enviar preço médio.',
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
      final response =
          await api.adicionarFotoEvento(estabelecimento!.id, myUser!.id, file);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: 'Foto enviada para aprovação!',
            backgroundColor: successColor,
            fontSize: 12);
      } else {
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
      appBar: isLoading ? null : isServerOff ? null :AppBar(
        title: Text(estabelecimento!.nome),
        actions: [
          IconButton(
              onPressed: selectImage, icon: const Icon(Icons.add_a_photo))
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : VerificaConexao(
              isLoading: isLoading,
              isServerOff: isServerOff,
              child: estabelecimento == null
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
                                    ? ImageCarousel(
                                        imageUrls: urlFotos,
                                        isEstabelecimento: true)
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
                                AutoSizeText(
                                  estabelecimento!.nome,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                ),
                                IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ShareOptions(url: '${api.baseUrl}/estabelecimentos/${estabelecimento!.id}', msg: 'Achei este estabelecimento interessante!');
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.share)),
                                if (estabelecimento!.precoMedio != null &&
                                    estabelecimento!.precoMedio != 'NaN')
                                  Text(
                                      'Preço médio : ${estabelecimento!.precoMedio} €'),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  controller: _precoController,
                                  decoration: InputDecoration(
                                    hintText: "Preço Médio p/pessoa",
                                    suffixText: '€',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    suffixIcon: Container(
                                      margin: EdgeInsets.all(8),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                        ),
                                        onPressed: editarPrecoMedio,
                                      ),
                                    ),
                                  ),
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
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20),
                                      child: Center(
                                          child: Text(
                                              'Ainda não existem avaliações'))),
                                if (avaliacoes.isNotEmpty)
                                  SumarioAvaliacoesWidget(
                                    numAvaliacoes: numAvaliacoes,
                                    mediaAvaliacoes: mediaAvaliacoes,
                                    avaliacoes: avaliacoes,
                                  ),
                                const SizedBox(height: 10),
                                //if(avaliacoes.isNotEmpty)
                                //AvaliacoesWidget(avaliacoes: avaliacoes),
                                /*const SizedBox(height: 15),
                            AvaliacaoInput(
                              controller: _avaliacaoController,
                              onRatingUpdate: (rating) {
                                setState(() {
                                  _rating = rating.round();
                                  isRatingNull = false;
                                });
                              },
                              validator: isRatingNull,
                            ),*/
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
                                    child: GoogleMap(
                                      initialCameraPosition: _localizacao!,
                                      markers: {
                                        Marker(
                                          markerId: const MarkerId('marker'),
                                          position:
                                              LatLng(latitude!, longitude!),
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
                                AvaliacoesList(
                                    avaliacoes: todasAvaliacoesOrdenadas,
                                    estabelecimentoId: widget.estabelecimentoID,
                                    myUserId: myUser!.id)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
      bottomNavigationBar: isLoading ? null :NavBar(postoID: estabelecimento!.idPosto, index: 1),
    );
  }
}
