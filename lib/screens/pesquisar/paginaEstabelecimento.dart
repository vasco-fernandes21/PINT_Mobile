import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pint/api/AvaliacoesAPI.dart';
import 'package:pint/api/postosAreasAPI.dart';
import 'package:pint/navbar.dart';
import 'package:readmore/readmore.dart';
import 'package:rating_summary/rating_summary.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

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
  Map<String, dynamic>? estabelecimento;
  List<dynamic> avaliacoes = [];
  int numAvaliacoes = 1;
  double mediaAvaliacoes = 0;
  int currentPage = 1;
  int itemsPerPage = 3;
  TextEditingController _avaliacaoController = TextEditingController();
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    fetchEstabelecimento();
  }

  void fetchEstabelecimento() async {
    final api = PostosAreasAPI();
    final response = await api.listarEstabelecimento(widget.estabelecimentoID);

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          estabelecimento = jsonResponse['data'];
          isLoading = false;
        });
        fetchAvaliacoes();
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar os dados: $e')),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao carregar dados: ${response.statusCode}')),
      );
    }
  }

  void fetchAvaliacoes() async {
    final api_avaliacoes = AvaliacoesAPI();
    final response = await api_avaliacoes
        .getAvaliacoesEstabelecimento(widget.estabelecimentoID);

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          avaliacoes = jsonResponse['data'];
          mediaAvaliacoes = jsonResponse['media'] != null
              ? (jsonResponse['media'] is String
                  ? double.tryParse(jsonResponse['media']) ?? 0.0
                  : jsonResponse['media'] as double)
              : 0.0;
          isLoading = false;
        });
        numAvaliacoes = avaliacoes.length;
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar os dados: $e')),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao carregar dados: ${response.statusCode}')),
      );
    }
  }

  int ContarAvaliacoesPorEstrela(int estrelas) {
    return avaliacoes
        .where((avaliacao) => avaliacao['classificacao'] == estrelas)
        .length;
  }

  static const CameraPosition _kLake =
      CameraPosition(target: LatLng(40.6698912, -7.9306995), zoom: 15);

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
                            estabelecimento!['foto'] != null
                                ? Image.network(
                                    'http://192.168.1.13:3001/uploads/estabelecimentos/${estabelecimento!['foto']}',
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
                              estabelecimento!['nome'],
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
                              estabelecimento?['descricao'],
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
                          ],
                        ),
                      ),
                      if (avaliacoes.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: RatingSummary(
                            counter: numAvaliacoes,
                            average: mediaAvaliacoes,
                            counterFiveStars: ContarAvaliacoesPorEstrela(5),
                            counterFourStars: ContarAvaliacoesPorEstrela(4),
                            counterThreeStars: ContarAvaliacoesPorEstrela(3),
                            counterTwoStars: ContarAvaliacoesPorEstrela(2),
                            counterOneStars: ContarAvaliacoesPorEstrela(1),
                            label: 'avaliações',
                            averageStyle: const TextStyle(fontSize: 40),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: min(currentPage * itemsPerPage,
                                  avaliacoes.length),
                              itemBuilder: (context, index) {
                                if (index >= (currentPage - 1) * itemsPerPage &&
                                    index < currentPage * itemsPerPage) {
                                  Map<String, dynamic> avaliacao =
                                      avaliacoes[index];
                                  return ListTile(
                                    leading:
                                        Icon(Icons.star, color: Colors.amber),
                                    title: Text(
                                        '${avaliacao['utilizador']['nome']}'),
                                    subtitle: Text(
                                        '${avaliacao['classificacao']} estrelas'),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                            RatingBarIndicator(
                              rating: 3.4,
                              itemCount: 5,
                              itemSize: 30,
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(height: 10),
                             Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                totalPages,
                                (pageIndex) => TextButton(
                                  onPressed: () {
                                    setState(() {
                                      currentPage = pageIndex + 1;
                                    });
                                  },
                                  child: Text((pageIndex + 1).toString()),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all<Color>(
                                            Colors.grey[200]!),
                                    foregroundColor: WidgetStateProperty.all(
                                        currentPage == pageIndex + 1
                                            ? Colors.blue
                                            : Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: _avaliacaoController,
                              decoration: InputDecoration(
                                hintText: 'Escreva a sua avaliação...',
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: SizedBox(
                                width: 380,
                                child: ElevatedButton(
                                  onPressed: () {},
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
                              'Morada: ${estabelecimento?['morada']}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Telefone: ${estabelecimento?['telemovel']}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Email: ${estabelecimento?['email']}',
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
                            SizedBox(
                              width: double.infinity,
                              height: 200,
                              child: GoogleMap(
                                initialCameraPosition: _kLake,
                                markers: {
                                  Marker(
                                    markerId: MarkerId('restaurant'),
                                    position: LatLng(40.6698912, -7.9306995),
                                  ),
                                },
                                mapType: MapType.normal,
                                onMapCreated: (GoogleMapController controller) {
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
