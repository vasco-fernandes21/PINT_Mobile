import 'package:flutter/material.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
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

  @override
  void initState() {
    super.initState();
    loadMyUser();
  }

  void loadMyUser() async {
    final SharedPreferences prefs = await _prefs;
    String? token = prefs.getString('token');
    final fetchedUser = await fetchUtilizadorCompleto(token!);
    setState(() {
      myUser = fetchedUser;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Início'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                  35) // Set the text color to white to see the gradient
                          ),
                    ),

                    
                  ],
                ),
              ),
            ),
      bottomNavigationBar: NavBar(postoID: widget.postoID, index: 0),
    );
  }
}
