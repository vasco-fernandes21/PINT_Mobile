import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pint/api/authAPI.dart';
import 'package:pint/models/area.dart';
import 'package:pint/models/subarea.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/utils/form_validators.dart';
import 'package:pint/widgets/date_input.dart';
import 'package:pint/widgets/dropdown_input.dart';
import 'package:pint/widgets/image_input.dart';
import 'package:pint/widgets/text_input.dart';
import 'package:pint/navbar.dart';
import 'package:pint/api/EventosAPI.dart';
import 'package:pint/widgets/verifica_conexao.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CriarEventosPage extends StatefulWidget {
  final postoID;

  CriarEventosPage({required this.postoID});

  @override
  _CriarEventosPageState createState() => _CriarEventosPageState();
}

class _CriarEventosPageState extends State<CriarEventosPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isLoading = true;
  bool isServerOff = false;

  List<Area> areas = [];
  List<Subarea> subareas = [];
  int? selectedAreaId;
  int? selectedSubareaId;

  final _formKeyEvento = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _moradaController = TextEditingController();
  final TextEditingController _telemovelController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _selectedImage;
  bool isImageNull = false;
  bool showValidationDate = false;

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
      isLoading = false;
    }); 
      } catch (e) {
        setState(() {
          isLoading = false;
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

  Future<void> _createEvent() async {
    
    if (showValidationDate == false){
    setState((){
      showValidationDate = true;
    });
    }

    if(_selectedDate == null){
      setState(() {
        showValidationDate = true;
      });
      return;
    }

    if(_selectedImage == null){
       setState(() {
        isImageNull = true;
      });
    return;
    }

    final bool isValidated = _formKeyEvento.currentState?.validate() ?? false;
    if (isValidated) {

      final SharedPreferences prefs = await _prefs;

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
      telemovel: _telemovelController.text.isNotEmpty ? int.tryParse(_telemovelController.text) : null,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      areaId: selectedAreaId!,
      subareaId: selectedSubareaId!,
      idPosto: widget.postoID,
      foto: _selectedImage!,
      authToken: prefs.getString('token')
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: 'Evento enviado para aprovação' , backgroundColor: successColor, toastLength: Toast.LENGTH_LONG, fontSize: 12);
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: 'Erro ao criar evento', fontSize: 12, backgroundColor: errorColor);
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Evento'),
      ),
      body: VerificaConexao(isLoading: isLoading, isServerOff: isServerOff, child: 
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
        key: _formKeyEvento,
         child: SingleChildScrollView(
          child: Column(
          children: [
            const SizedBox(height: 15),
            TextInput(controller: _titleController, label: 'Nome do Evento',keyboardType: TextInputType.text, errorMessage: 'Por favor, insira o nome'),
            const SizedBox(height: 15),
            TextInput(controller: _descriptionController, label: 'Descrição', keyboardType: TextInputType.text, errorMessage: 'Por favor, insira a descrição'),
            const SizedBox(height: 15),
            TextInput(controller: _telemovelController, label: 'Telemóvel', keyboardType: TextInputType.phone, errorMessage: '', isFieldRequired: false,),
            const SizedBox(height: 15),
            TextInput(controller: _emailController, label: 'Email', keyboardType: TextInputType.emailAddress, errorMessage: '', isFieldRequired: false,),
            const SizedBox(height: 15),
            TextInput(controller: _moradaController, label: 'Morada', keyboardType: TextInputType.streetAddress, errorMessage: 'Por favor, insira a morada'),
            const SizedBox(height: 15),
            DateTimeInput(
              onDateChanged: (date) {
              _selectedDate = date;
            },
            onTimeChanged: (time) {
              _selectedTime = time;
            },
            validator: validateDateAndTime,
            showValidation: showValidationDate,
            ),
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
            ImageInput(selectedImage: _selectedImage, onPickImage: _pickImage, validator: isImageNull),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createEvent,
              child: const Text('Criar Evento'),
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
      bottomNavigationBar: NavBar(
        index: 2,
        postoID: 1,
      ),
    );
  }
}
