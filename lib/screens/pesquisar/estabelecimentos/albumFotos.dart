import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pint/api/AlbumAPi.dart';
import 'package:pint/api/api.dart';
import 'package:pint/models/album.dart';
import 'package:pint/models/foto.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlbumPage extends StatefulWidget {
  final Album album;
  final int idPosto;

   AlbumPage({super.key, required this.album, required this.idPosto});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isLoading = true;
  Utilizador? myUser;
  String? token;
  List<Foto> fotos = [];

  final api = ApiClient();

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
      });
      final fetchedUser = await fetchUtilizadorCompleto();
      setState(() {
        myUser = fetchedUser;
      });
      loadFotos();
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
      final fetchedFotos = await fetchFotosAlbuns(context, widget.album.id);
      setState(() {
        fotos = fetchedFotos;
        isLoading=false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro albuns: $e'),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

    void selectImage() async {
    final ImagePicker _picker = ImagePicker();

    // Seleciona uma imagem da galeria
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      final api = AlbumAPI();
      final response =
          await api.adicionarFotoAlbum(widget.album.id, file, token);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Álbum'),
        actions: [
          IconButton(onPressed: () {
            selectImage();
          }, icon: const Icon(Icons.add_a_photo))
        ],
      ),
      body: isLoading
      ? const Center(child: CircularProgressIndicator(),)
      : fotos.isEmpty
      ? const Center(child: Text('Não existem fotos neste álbum'),)
      : SingleChildScrollView(
        child: Column(
          children: fotos.map((foto) {
           return Card(
              margin: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network('${api.baseUrl}/uploads/albuns/${foto.foto}'), // Usando Image.network para carregar a imagem a partir da URL
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Foto carregada por ${foto.nomeCriador}',
                      style: TextStyle(fontSize: 15,),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: NavBar(postoID: widget.idPosto, index: 1),
    );
  }
}