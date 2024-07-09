import 'package:flutter/material.dart';
import 'package:pint/models/evento.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/screens/criar/criarEvento.dart';
import 'package:pint/screens/perfil/perfil.dart';
import 'package:pint/screens/pesquisar/eventos/todosEventos.dart';
import 'package:pint/utils/colors.dart';
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

  @override
  void initState() {
    super.initState();
    loadMyUser();
    loadEventos();
  }

  void loadMyUser() async {
    final SharedPreferences prefs = await _prefs;
    String? token = prefs.getString('token');
    final fetchedUser = await fetchUtilizadorCompleto(token!);
    setState(() {
      myUser = fetchedUser;
      
    });
  }

  void loadEventos() async {
    final fetchedEventos = await fetchEventos(context, widget.postoID);
    setState(() {
      eventos = fetchedEventos;
      isLoading = false;
    });
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
                    //Text('Olá, ${myUser?.nome}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35, ))
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [primaryColor, Colors.lightBlueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text('Olá, ${myUser?.nome}',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  30),
                                  maxLines: 1, // Set the text color to white to see the gradient
                          ),
                    ),  
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Próximos Eventos',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    ...eventos.map((evento) => EventoRow(evento: evento)).toList(),
                    const SizedBox(height: 15,),
                    CustomButton(onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TodosEventosPage(postoID: widget.postoID),
                            ),
                          );
                        } , title: 'Ver Todos os Eventos'),
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
