import 'package:flutter/material.dart';
import 'package:pint/navbar.dart';

class Perfil extends StatelessWidget {
  final int postoID;
  Perfil({required this.postoID});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: Center(
        child: Text('This is profile'),
      ),
            bottomNavigationBar: NavBar(postoID: postoID, index: 4),
    );
  }
}
