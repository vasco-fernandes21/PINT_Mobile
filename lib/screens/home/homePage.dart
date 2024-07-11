import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pacote para lidar com formatação de datas
import 'package:pint/models/evento.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/screens/criar/criarEvento.dart';
import 'package:pint/screens/perfil/meuperfil.dart';
import 'package:pint/screens/pesquisar/eventos/todosEventos.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/evento_functions.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/custom_button.dart';
import 'package:pint/widgets/evento_row.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final int postoID;

  HomePage({required this.postoID});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Utilizador? myUser;
  List<Evento> eventos = [];
  String saudacao = '';

  @override
  void initState() {
    super.initState();
    loadMyUser();
    loadEventos();
  }

  void loadMyUser() async {
    final SharedPreferences prefs = await _prefs;
    String? token = prefs.getString('token');
    final fetchedUser = await fetchUtilizadorCompleto();
    setState(() {
      myUser = fetchedUser;
      updateSaudacao();
    });
  }

  void loadEventos() async {
    final fetchedEventos = await fetchEventos(context, widget.postoID);
    setState(() {
      eventos = filtrarEOrdenarEventosFuturos(fetchedEventos);
      isLoading = false;
    });
  }

  void updateSaudacao() {
    if (myUser != null && myUser!.ultimoLogin != null) {
      final currentHour = DateTime.now().hour;
      final currentDate = DateTime.now();
      final lastLoginDate = DateTime.parse(myUser!.ultimoLogin!); // Converter para DateTime

      final diff = currentDate.difference(lastLoginDate);
      final diffDays = diff.inDays;

      if (diffDays >= 15) {
        setState(() {
          saudacao = 'Seja bem-vindo novamente, ${myUser!.nome}';
        });
      } else {
        if (currentHour >= 6 && currentHour < 13) {
          setState(() {
            saudacao = 'Bom dia, ${myUser!.nome}';
          });
        } else if (currentHour >= 13 && currentHour < 20) {
          setState(() {
            saudacao = 'Boa tarde, ${myUser!.nome}';
          });
        } else {
          setState(() {
            saudacao = 'Boa noite, ${myUser!.nome}';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [secondaryColor, Colors.lightBlueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: AutoSizeText(
                        saudacao,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Próximos Eventos',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    ...eventos
                        .take(3)
                        .map((evento) => EventoRow(
                              evento: evento,
                              postoID: widget.postoID,
                            )),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TodosEventosPage(postoID: widget.postoID),
                          ),
                        );
                      },
                      title: 'Ver Todos os Eventos',
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: NavBar(postoID: widget.postoID, index: 0),
    );
  }
}
