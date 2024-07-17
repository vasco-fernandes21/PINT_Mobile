import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pint/api/AlbumAPi.dart';
import 'package:pint/models/area.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/utils/form_validators.dart';
import 'package:pint/widgets/custom_button.dart';
import 'package:pint/widgets/dropdown_input.dart';
import 'package:pint/widgets/image_input.dart';
import 'package:pint/widgets/text_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateAlbumPage extends StatefulWidget {
  final int idPosto;

  CreateAlbumPage({required this.idPosto});

  @override
  _CreateAlbumPageState createState() => _CreateAlbumPageState();
}

class _CreateAlbumPageState extends State<CreateAlbumPage> {
  final _formKey = GlobalKey<FormState>();
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    String? token;
    Utilizador? myUser;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _nome = '';
  String _descricao = '';
  File? _image;
  bool isImageNull = false;
  bool isLoading = true;
  List<Area> areas = [];
    int? selectedAreaId;

  final ImagePicker _picker = ImagePicker();

    @override
  void initState() {
    super.initState();
    loadMyUser();
  }

    void loadMyUser() async {
    try {
      final SharedPreferences prefs = await _prefs;
      setState(() {
        token = prefs.getString('token');
        print(token);
      });
      final fetchedUser = await fetchUtilizadorCompleto();
      setState(() {
        myUser = fetchedUser;
      });
      loadAreas();
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
      });
    }

  }

    Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        isImageNull = false;
      });
    }
  }

  void _submitForm() async {

      if(_image == null){
    setState(() {
        isImageNull = true;
      });
    return;
  }

      if (_formKey.currentState?.validate() ?? false) {
      try {
      final api_album = AlbumAPI();
      await api_album.criarAlbum(_nomeController.text, _descriptionController.text, selectedAreaId!, _image!, token, widget.idPosto);
      Fluttertoast.showToast(msg: 'Álbum enviado para aprovação!', fontSize: 12, backgroundColor: successColor);
      } catch (e) {
        Fluttertoast.showToast(msg: 'Erro ao criar álbum', fontSize: 12, backgroundColor: errorColor);
      }
     
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Álbum'),
      ),
      body: isLoading
      ? const Center(child: CircularProgressIndicator(),)
      : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 15,),
              TextInput(controller: _nomeController, label: 'Nome', errorMessage: 'Por favor, insira o nome',),
              const SizedBox(height: 15,),
              TextInput(controller: _descriptionController, label: 'Descrição', errorMessage: 'Por favor, insira a descrição',),
              const SizedBox(height: 15,),
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
                  });
                },
                   label: 'Área',
                   validator: (value) => validateNotEmpty(value?.toString(), errorMessage: 'Por favor, selecione uma área'),
              ),
              const SizedBox(height: 15),
              ImageInput(selectedImage: _image, onPickImage: _pickImage, validator: isImageNull),
              const SizedBox(height: 20,),
              CustomButton(onPressed: _submitForm, title: 'Criar Álbum'),
              const SizedBox(height: 15,),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(postoID: widget.idPosto, index: 1),
    );
  }
}
