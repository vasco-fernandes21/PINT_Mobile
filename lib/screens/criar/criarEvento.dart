import 'package:flutter/material.dart';
import 'package:pint/navbar.dart';

class CriarEvento extends StatelessWidget {
  final int postoID;
  CriarEvento({required this.postoID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Evento'),
      ),
      body: Center(
        child: Text('This is add'),
      ),
    bottomNavigationBar: NavBar(postoID: postoID, index: 2),
    );
  }
}
