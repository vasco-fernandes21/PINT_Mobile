import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pint/api/postosAreasAPI.dart';


class EstabelecimentoPage extends StatefulWidget {
  final int estabelecimentoID;
  final String NomeEstabelecimento;

  EstabelecimentoPage({required this.estabelecimentoID, required this.NomeEstabelecimento});

  @override
  State<EstabelecimentoPage> createState() => _EstabelecimentoPageState();
}

class _EstabelecimentoPageState extends State<EstabelecimentoPage> {
  bool isLoading = true;
  Map<String, dynamic>? estabelecimento;

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
        SnackBar(content: Text('Erro ao carregar dados: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.NomeEstabelecimento),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : estabelecimento == null
              ? Center(child: Text('Estabelecimento não encontrado.'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
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
                        SizedBox(height: 10),
                        Text(
                          estabelecimento!['nome'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          estabelecimento!['descricao'],
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Morada: ${estabelecimento!['morada']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Subárea: ${estabelecimento!['Subarea']['nome']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Latitude: ${estabelecimento!['latitude']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Longitude: ${estabelecimento!['longitude']}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}