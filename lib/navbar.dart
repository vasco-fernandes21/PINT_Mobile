import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pint/utils/colors.dart';
import 'screens/home/homePage.dart';
import 'screens/pesquisar/pesquisar.dart';
import 'screens/notificacoes/notificacoes.dart';
import 'screens/perfil/perfil.dart';
import 'screens/criar/criarEvento.dart';
import 'screens/criar/criarEstabelecimento.dart';
import 'screens/pesquisar/EstabelecimentosPorArea.dart';

class NavBar extends StatelessWidget {
  final int postoID;
  final int index;

  NavBar({required this.postoID, required this.index});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          activeIcon: Icon(Icons.notifications),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '',
        ),
      ],
      currentIndex: index,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(postoID: postoID),
              ),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Pesquisar(postoID: postoID),
              ),
            );
            break;
          case 2:
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Color(0xFF1D324F), width: 0.5),
                  ),
                  title: Text(
                    'Escolha uma opção',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        GestureDetector(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade300)),
                            ),
                            child: Text('Criar Evento',
                                style: TextStyle(fontSize: 16)),
                          ),
                          onTap: () {
                            Navigator.pop(context); // Fechar o popup
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CriarEventosPage(postoID: postoID),
                              ),
                            );
                          },
                        ),
                        GestureDetector(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text('Criar Estabelecimento',
                                style: TextStyle(fontSize: 16)),
                          ),
                          onTap: () {
                            Navigator.pop(context); // Fechar o popup
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CriarEstabelecimentoPage(postoID: postoID),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Notificacoes(postoID: postoID),
              ),
            );
            break;
          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Perfil(postoID: postoID),
              ),
            );
            break;
        }
      },
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      backgroundColor: primaryColor,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      selectedIconTheme: IconThemeData(size: 30),
      unselectedIconTheme: IconThemeData(size: 30),
    );
  }
}
