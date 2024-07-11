import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'screens/home/homePage.dart';
import 'screens/pesquisar/pesquisar.dart';
import 'screens/notificacoes/paginaNotificacoes.dart';
import 'screens/perfil/meuperfil.dart';
import 'screens/criar/criarEvento.dart';
import 'screens/criar/criarEstabelecimento.dart';
import 'package:badges/badges.dart' as badges;

class NavBar extends StatefulWidget {
  final int postoID;
  final int index;

  NavBar({required this.postoID, required this.index});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int contadorNotificacoes = 0;

  @override
  void initState() { 
    super.initState();
    // Carregar o contador de notificações quando a NavBar for inicializada
    atualizarContadorNotificacoes();
  }

  Future<void> atualizarContadorNotificacoes() async {
    int contador = await fetchContadorNotificacoes();
    setState(() {
      contadorNotificacoes = contador;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: badges.Badge(
            showBadge: contadorNotificacoes > 0,
            badgeContent: Text(
              contadorNotificacoes > 9 ?'9+' : '$contadorNotificacoes',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              size: 30,
            ),
          ),
          activeIcon:  badges.Badge(
            showBadge: contadorNotificacoes > 0,
            badgeContent: Text(
              contadorNotificacoes > 9 ?'9+' : contadorNotificacoes.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: const Icon(
              Icons.notifications,
              size: 30,
            ),
          ),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '',
        ),
      ],
      currentIndex: widget.index,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(postoID: widget.postoID),
              ),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Pesquisar(postoID: widget.postoID),
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
                                    CriarEventosPage(postoID: widget.postoID),
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
                                builder: (context) => CriarEstabelecimentoPage(
                                    postoID: widget.postoID),
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
                builder: (context) => NotificacoesPage(postoID: widget.postoID),
              ),
            );
            break;
          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PerfilPage(postoID: widget.postoID,),
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
