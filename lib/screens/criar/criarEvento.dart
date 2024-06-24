import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pint/api/authAPI.dart';
import 'criarEstabelecimento.dart';
import 'package:pint/navbar.dart';
import 'package:pint/api/postosAreasAPI.dart';
import 'package:pint/api/EventosAPI.dart';

class CriarEventosPage extends StatefulWidget {
  final postoID;

  CriarEventosPage({required this.postoID});

  @override
  _CriarEventosPageState createState() => _CriarEventosPageState();
}

class _CriarEventosPageState extends State<CriarEventosPage> {
  List<Map<String, dynamic>> areas = [];
  List<Map<String, dynamic>> subareas = [];
  int? selectedAreaId;
  int? selectedSubareaId;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _moradaController = TextEditingController();
  final TextEditingController _telemovelController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _selectedImage;
  final AuthApi _authApi = AuthApi();

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
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

  Future<void> _createEvent() async {
    /*
    String? token = await _authApi.token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('É preciso estar logado para criar um evento.')),
      );
      return;
    }*/

    if (selectedAreaId == null ||
        selectedSubareaId == null ||
        _titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _moradaController.text.isEmpty ||
        _telemovelController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Por favor, preencha todos os campos e selecione uma imagem')),
      );
      return;
    }

    // Formatar a hora para o formato hh:mm:ss
    final formattedHora =
        '${_selectedTime?.hour.toString().padLeft(2, '0')}:${_selectedTime?.minute.toString().padLeft(2, '0')}:00';

    final api_eventos = EventosAPI();
    final response = await api_eventos.criarEvento(
      titulo: _titleController.text,
      descricao: _descriptionController.text,
      data: _selectedDate!,
      hora: formattedHora,
      morada: _moradaController.text,
      telemovel: int.parse(_telemovelController.text),
      email: _emailController.text,
      areaId: selectedAreaId!,
      subareaId: selectedSubareaId!,
      idPosto: widget.postoID,
      foto: _selectedImage!,
      authToken:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Niwibm9tZSI6IlRlc3RlIiwibmlmIjpudWxsLCJsb2NhbGlkYWRlIjpudWxsLCJ0ZWxlbW92ZWwiOm51bGwsImVtYWlsIjoidGVzdGVAZW1haWwuY29tIiwiY2FyZ28iOm51bGwsImlkUG9zdG8iOjEsImlhdCI6MTcxOTE0NzM5NSwiZXhwIjoxNzE5NzUyMTk1fQ.T4Xoi5hlDQVccsoOYAqrOQvAD2pje2E2cu9IjqCEVks',
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Evento criado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar evento')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              width: 380,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Nome do Evento',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 380,
              margin: const EdgeInsets.symmetric(vertical: 5),
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
            const SizedBox(height: 10),
            Container(
              width: 380,
              margin: const EdgeInsets.symmetric(vertical: 5),
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
            const SizedBox(height: 10),
            Container(
              width: 380,
              margin: const EdgeInsets.symmetric(vertical: 5),
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
            const SizedBox(height: 10),
            Container(
              width: 380,
              margin: const EdgeInsets.symmetric(vertical: 5),
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
            const SizedBox(height: 15),
            Container(
              width: 380,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: const Text('Data'),
                subtitle: Text(_selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                    : 'Selecionar Data'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 380,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: const Text('Hora'),
                subtitle: Text(_selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'Selecionar Hora'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: 380,
              margin: const EdgeInsets.symmetric(vertical: 5),
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
            Container(
              width: 380,
              margin: const EdgeInsets.symmetric(vertical: 15),
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                value: selectedSubareaId,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedSubareaId = newValue;
                  });
                },
                items: subareas
                    .map<DropdownMenuItem<int>>((Map<String, dynamic> subarea) {
                  return DropdownMenuItem<int>(
                    value: subarea['id'],
                    child:
                        Text(subarea['nome'], overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Subárea',
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
            /*_selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    height: 150,
                  )
                :*/
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _selectedImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: _pickImage,
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              color: Colors.grey[700],
                              size: 50,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Insere uma imagem',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createEvent,
              child: const Text('Criar Evento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D324F),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        index: 2,
        postoID: 1,
      ),
    );
  }
}
