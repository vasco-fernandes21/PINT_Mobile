import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pint/navbar.dart';
import 'package:pint/api/postosAreasAPI.dart';

class CriarEstabelecimentoPage extends StatefulWidget {
  final int postoID;
  CriarEstabelecimentoPage({required this.postoID});

  @override
  State<CriarEstabelecimentoPage> createState() =>
      _CriarEstabelecimentoPageState();
}

class _CriarEstabelecimentoPageState extends State<CriarEstabelecimentoPage> {
  List<Map<String, dynamic>> areas = [];
  List<Map<String, dynamic>> subareas = [];
  int? selectedAreaId;
  int? selectedSubareaId;
  bool _isSubareaEnabled = false;
  File? _selectedImage;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _moradaController = TextEditingController();
  final TextEditingController _telemovelController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAreas();
  }

  void fetchAreas() async {
    final api_areas = PostosAreasAPI();
    final response = await api_areas.listarAreas();

    if (response.statusCode == 200) {
      try {
        // Decodificar a resposta JSON
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Verificar se a chave 'data' existe na resposta
        if (jsonResponse.containsKey('data')) {
          // Acessar a lista de postos dentro de 'data'
          List<dynamic> areasData = jsonResponse['data'];

          setState(() {
            areas = areasData
                .map<Map<String, dynamic>>((item) => {
                      'id': item['id'],
                      'nome': item['nome'],
                    })
                .toList();
            //isLoading = false;
          });
        } else {
          // Se 'data' não estiver presente na resposta
          //isLoading =false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Dados de postos não encontrados na resposta')),
          );
        }
      } catch (e) {
        // Capturar e mostrar erros de decodificação JSON
        //isLoading =false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar os dados: $e')),
        );
      }
    } else {
      // Tratar erros de status HTTP
      //isLoading =false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao carregar dados: ${response.statusCode}')),
      );
    }
  }

  void fetchSubareas(int areaID) async {
    final api_areas = PostosAreasAPI();
    final response = await api_areas.listarSubareasPorArea(areaID);

    if (response.statusCode == 200) {
      try {
        // Decodificar a resposta JSON
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Verificar se a chave 'data' existe na resposta
        if (jsonResponse.containsKey('data')) {
          // Acessar a lista de subáreas dentro de 'data'
          List<dynamic> subareasData = jsonResponse['data'];

          setState(() {
            subareas = subareasData
                .map<Map<String, dynamic>>((item) => {
                      'id': item['id'],
                      'nome': item['nome'],
                    })
                .toList();
            //isLoading = false;
          });
        } else {
          // Se 'data' não estiver presente na resposta
          setState(() {
            subareas = [];
            //isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Dados de subáreas não encontrados na resposta')),
          );
        }
      } catch (e) {
        // Capturar e mostrar erros de decodificação JSON
        setState(() {
          subareas = [];
          //isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar os dados: $e')),
        );
      }
    } else {
      // Tratar erros de status HTTP
      setState(() {
        subareas = [];
        //isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao carregar dados: ${response.statusCode}')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _createEsatabelecimento() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Todos os campos obrigatórios são válidos.
      // Submeter o formulário.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Estabelecimento'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 15),
              Container(
                width: 380,
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Estabelecimento',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o título';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: 380,
                child: DropdownButtonFormField<int>(
                  value: selectedAreaId,
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedAreaId = newValue;
                      selectedSubareaId = null;
                      subareas = [];
                      if (newValue != null) {
                        fetchSubareas(newValue);
                      }
                    });
                  },
                  items: areas
                      .map<DropdownMenuItem<int>>((Map<String, dynamic> area) {
                    return DropdownMenuItem<int>(
                      value: area['id'],
                      child: Text(area['nome']),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Área',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: 380,
                child: DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: selectedSubareaId,
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedSubareaId = newValue;
                    });
                  },
                  items: subareas.map<DropdownMenuItem<int>>(
                      (Map<String, dynamic> subarea) {
                    return DropdownMenuItem<int>(
                      value: subarea['id'],
                      child: Text(
                        subarea['nome'],
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Subárea',
                    labelStyle: TextStyle(
                      color: selectedAreaId == null
                          ? Colors.grey
                          : Colors.grey[800],
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: 380,
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: 380,
                child: TextFormField(
                  controller: _telemovelController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Telemóvel',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: 380,
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: 380,
                child: TextFormField(
                  controller: _moradaController,
                  keyboardType: TextInputType.streetAddress,
                  decoration: InputDecoration(
                    labelText: 'Morada',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createEsatabelecimento,
                child: const Text('Criar Evento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D324F),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(postoID: widget.postoID, index: 2),
    );
  }
}
