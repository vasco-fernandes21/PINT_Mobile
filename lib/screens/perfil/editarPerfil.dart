import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pint/api/UtilizadorAPI.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/screens/perfil/meuperfil.dart';
import 'package:pint/utils/colors.dart';
import 'dart:io';

import 'package:pint/widgets/custom_button.dart';
import 'package:pint/widgets/text_input.dart';

class editPerfil extends StatefulWidget {
  final int postoID;
  final Utilizador? myUser;
  final String? token;

  editPerfil(
      {required this.postoID, required this.myUser, required this.token});

  @override
  _EditPerfilState createState() => _EditPerfilState();
}

class _EditPerfilState extends State<editPerfil> {
  final TextEditingController NameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController nifController = TextEditingController();
  final TextEditingController cargoController = TextEditingController();

  File? _image;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() {
    NameController.text = widget.myUser!.nome;
    emailController.text = widget.myUser!.email ?? '';
    telefoneController.text = widget.myUser!.telemovel ?? '';
    cargoController. text = widget.myUser!.cargo ?? '';
    nifController.text = widget.myUser!.nif ?? '';
  }



  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateUser() async {
    final api = UtilizadorAPI();
    final response = await api.editarUtilizador(
        widget.myUser!.id,
        NameController.text.isNotEmpty ? NameController.text : null,
        emailController.text.isNotEmpty ? emailController.text : null,
        cargoController.text.isNotEmpty ? cargoController.text : null,
        nifController.text.isNotEmpty ? nifController.text : null,
        telefoneController.text.isNotEmpty ? telefoneController.text : null,
        _image);

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: 'Utilizador editado com sucesso',
          backgroundColor: successColor,
          fontSize: 12);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PerfilPage(
            postoID: widget.postoID,
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(
            msg: 'Erro ao editar perfil',
            fontSize: 12,
            backgroundColor: errorColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: _image == null
                          ? const Image(
                              image: AssetImage(
                                  'assets/images/default-avatar.jpg')) // adicione a imagem padrão aqui
                          : Image.file(_image!, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: primaryColor,
                        ),
                        child: const Icon(
                          Icons.camera,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Form(
                child: Column(
                  children: [
                    TextInput(controller: NameController, label: 'Nome', errorMessage: '', keyboardType: TextInputType.name,),
                    const SizedBox(height: 20),
                    TextInput(controller: cargoController, label: 'Cargo', errorMessage: '', keyboardType: TextInputType.text,),
                    const SizedBox(height: 20),
                    TextInput(controller: emailController, label: 'Email', errorMessage: '', keyboardType: TextInputType.emailAddress,),
                    const SizedBox(height: 20),
                    TextInput(controller: telefoneController, label: 'Número de Telemóvel', errorMessage: '', keyboardType: TextInputType.phone,), 
                     const SizedBox(height: 20),
                    TextInput(controller: nifController, label: 'NIF', errorMessage: '', keyboardType: TextInputType.number,),          
                    const SizedBox(height: 20),
                    CustomButton(onPressed: _updateUser, title: 'Guardar'),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(postoID: widget.postoID, index: 4),
    );
  }
}
