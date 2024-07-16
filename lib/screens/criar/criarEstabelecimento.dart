import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pint/api/EstabelecimentosAPI.dart';
import 'package:pint/models/area.dart';
import 'package:pint/models/subarea.dart';
import 'package:pint/navbar.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/utils/form_validators.dart';
import 'package:pint/widgets/dropdown_input.dart';
import 'package:pint/widgets/image_input.dart';
import 'package:pint/widgets/text_input.dart';
import 'package:pint/widgets/verifica_conexao.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CriarEstabelecimentoPage extends StatefulWidget {
  final int postoID;
  CriarEstabelecimentoPage({required this.postoID});

  @override
  State<CriarEstabelecimentoPage> createState() =>
      _CriarEstabelecimentoPageState();
}

class _CriarEstabelecimentoPageState extends State<CriarEstabelecimentoPage> {
  bool isLoading = true;
  bool isServerOff = false;

  List<Area> areas = [];
  List<Subarea> subareas = [];
  int? selectedAreaId;
  int? selectedSubareaId;
  bool _isSubareaEnabled = false;
  File? _selectedImage;
  bool isImageNull = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _moradaController = TextEditingController();
  final TextEditingController _telemovelController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
    final TextEditingController _precoController = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    loadAreas();
  }

    void loadAreas() async {
    try {
    final fetchedAreas = await fetchAreas(context);
    setState(() {
      areas = fetchedAreas;
      isLoading=false;
    });
    } catch (e) {
      setState(() {
        isLoading=false;
        isServerOff=true;
      });
    }

  }
  
    void loadSubareas(int areaId) async {
      try {
      final fetchedSubareas = await fetchSubareas(context, areaId);
      setState(() {
        subareas = fetchedSubareas;
      });
      } catch (e) {
        setState(() {
          isServerOff = true;
        });
      }

  }

    Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        isImageNull = false;
      });
    }
  }

Future<void> _createEstabelecimento() async {
  
  if(_selectedImage == null){
    setState(() {
        isImageNull = true;
      });
    return;
  }
  if (_formKey.currentState?.validate() ?? false) {
    final api_estabelecimentos = EstabelecimentosAPI();
    
    SharedPreferences prefs = await SharedPreferences.getInstance();


    // Chame a função criarEstabelecimento
    final response = await api_estabelecimentos.criarEstabelecimento(
      nome: _nomeController.text,
      descricao: _descriptionController.text,
      morada: _moradaController.text,
      telemovel:  _telemovelController.text.isNotEmpty ? int.tryParse(_telemovelController.text) : null,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      areaId: selectedAreaId!,
      subareaId: selectedSubareaId!,
      idPosto: widget.postoID,
      foto: _selectedImage!,
      authToken: prefs.getString('token')
    );

    // Manipule a resposta da API
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Sucesso
     Fluttertoast.showToast(msg: 'Estabelecimento enviado para aprovação' , backgroundColor: successColor, toastLength: Toast.LENGTH_LONG, fontSize: 11,);
      Navigator.pop(context);  // Volte para a tela anterior ou vá para outra tela
    } else {
      // Erro
      Fluttertoast.showToast(msg: 'Erro ao criar estabelecimento', fontSize: 12, backgroundColor: errorColor); 
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Estabelecimento'),
      ),
      body: VerificaConexao(isLoading: isLoading, isServerOff: isServerOff, child: 
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
            children: [
              const SizedBox(height: 15),
              TextInput(controller: _nomeController, label: 'Nome do Estabelecimento', keyboardType: TextInputType.text, errorMessage: 'Por favor, insira o nome'),
              const SizedBox(height: 15),
              DropdownInput<int>(
                value: selectedAreaId,
                 items: areas.map((area) {
                  return DropdownMenuItem<int>(
                    value: area.id,
                    child: Text(area.nome, overflow: TextOverflow.ellipsis,),
                  );
                }).toList(),
                  onChanged: (int? newValue) {
                  setState(() {
                    selectedAreaId = newValue;
                    selectedSubareaId = null;
                    subareas = [];
                    if (newValue != null) {
                      loadSubareas(newValue);
                    }
                  });
                },
                   label: 'Área',
                   validator: (value) => validateNotEmpty(value?.toString(), errorMessage: 'Por favor, selecione uma área'),
              ), 
              const SizedBox(height: 15),
              DropdownInput<int>(
                value: selectedSubareaId, 
                items:subareas.map((subarea) {
                  return DropdownMenuItem<int>(
                    value: subarea.id,
                    child: Text(subarea.nome, overflow: TextOverflow.ellipsis,),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    selectedSubareaId = newValue;
                  });
                },
                label: 'Subárea',
                validator: (value) => validateNotEmpty(value?.toString(), errorMessage: 'Por favor, selecione uma subárea'),
                ),
              const SizedBox(height: 15),
              TextInput(controller: _descriptionController, label: 'Descrição', keyboardType: TextInputType.text, errorMessage: 'Por favor, insira a descrição'),
              const SizedBox(height: 15),
              TextInput(controller: _telemovelController, label: 'Telemóvel', keyboardType: TextInputType.phone, isFieldRequired: false,),
              const SizedBox(height: 15),
              TextInput(controller: _emailController, label: 'Email', keyboardType: TextInputType.emailAddress, isFieldRequired: false,),
              const SizedBox(height: 15),
              TextInput(controller: _moradaController, label: 'Morada', keyboardType: TextInputType.streetAddress, errorMessage: 'Por favor, insira a morada'),
              const SizedBox(height: 15),
              TextInput(controller: _precoController, label: 'Preço médio p/pessoa', keyboardType: TextInputType.number, isFieldRequired: false, suffixText: '€',),
              const SizedBox(height: 15),
              ImageInput(selectedImage: _selectedImage, onPickImage: _pickImage, validator: isImageNull,),         
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createEstabelecimento,
                child: const Text('Criar Estabelecimento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
          ),
        ),
      ),
      ),
      bottomNavigationBar: NavBar(postoID: widget.postoID, index: 2),
    );
  }
}
