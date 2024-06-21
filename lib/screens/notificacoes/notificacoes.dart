import 'package:flutter/material.dart';
import 'package:pint/navbar.dart';

class Notificacoes extends StatelessWidget {
  final int postoID;
  Notificacoes({required this.postoID});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificações'),
      ),
      body: Center(
        child: Text('This is the notifications page'),
      ),
      bottomNavigationBar: NavBar(postoID: postoID, index: 3),
    );
  }
}
