import 'package:flutter/material.dart';
import 'package:pint/api/api.dart';
import 'package:pint/models/album.dart';
import 'package:pint/navbar.dart';
import 'package:pint/screens/pesquisar/estabelecimentos/albumFotos.dart';
import 'package:pint/screens/pesquisar/estabelecimentos/criarAlbum.dart';
import 'package:pint/utils/fetch_functions.dart';

class ListAlbumPage extends StatefulWidget {
  final int idPosto;
  final int idArea;

   ListAlbumPage({super.key, required this.idArea, required this.idPosto});

  @override
  State<ListAlbumPage> createState() => _ListAlbumPageState();
}

class _ListAlbumPageState extends State<ListAlbumPage> {
  bool isLoading = true;
  List<Album> albuns = [];

  final api = ApiClient();

    @override
  void initState() {
    super.initState();
    loadAlbuns();
  }


    void loadAlbuns() async {
    try {
      final fetchedAlbuns = await fetchAlbuns(context, widget.idPosto, widget.idArea);
      setState(() {
        albuns = fetchedAlbuns;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Álbuns de Fotos'),
        actions: [
          IconButton(onPressed: () {
          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateAlbumPage(idPosto: widget.idPosto,)
                            ),
                          );
          }, icon: const Icon(Icons.add_photo_alternate_rounded))
        ],
      ),
      body: isLoading
      ? const Center(child: CircularProgressIndicator(),)
      : albuns.isEmpty
      ? const Center(child: Text('Não existem álbuns nesta área'))
      : SingleChildScrollView(
        child: Column(
          children: albuns.map((album) {
            return InkWell(
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network('${api.baseUrl}/uploads/albuns/${album.foto}'), // Usando Image.network para carregar a imagem a partir da URL
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      album.nome,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(album.descricao),
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlbumPage(album: album, idPosto: widget.idPosto,)
                            ),
                          );
            },
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: NavBar(postoID: widget.idPosto, index: 1),
    );
  }
}