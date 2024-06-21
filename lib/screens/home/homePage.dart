import 'package:flutter/material.dart';
import 'package:pint/navbar.dart';

class HomePage extends StatelessWidget {
  final int postoID;
  HomePage({required this.postoID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Text('ID do Posto: $postoID')
      ),
      bottomNavigationBar: NavBar(postoID: postoID, index: 0),
    );
  }
}