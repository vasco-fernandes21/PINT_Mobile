import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> areas = [
    {'name': 'Saúde', 'icon': Icons.local_hospital},
    {'name': 'Desporto', 'icon': Icons.sports_soccer},
    {'name': 'Formação', 'icon': Icons.school},
    {'name': 'Gastronomia', 'icon': Icons.restaurant},
    {'name': 'Habitação/Alojamento', 'icon': Icons.home},
    {'name': 'Transportes', 'icon': Icons.directions_bus},
    {'name': 'Lazer', 'icon': Icons.beach_access},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: List.generate(areas.length, (index) {
          return Center(
            child: Card(
              child: InkWell(
                onTap: () {
                  // Handle your tap here.
                  print('Tapped on ${areas[index]['name']}');
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      areas[index]['icon'],
                      size: 50.0,
                    ),
                    SizedBox(height: 20),
                    Text(
                      areas[index]['name'],
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}