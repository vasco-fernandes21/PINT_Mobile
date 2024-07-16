import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/screens/auth/loginPage.dart';
import 'package:pint/screens/perfil/editarPerfil.dart';
import 'package:pint/screens/perfil/selecionarPreferencia.dart';
import 'package:pint/screens/pesquisar/eventos/meusEventos.dart';
import 'package:pint/screens/pesquisar/eventos/minhasInscricoes.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/alert_confirmation.dart';
import 'package:pint/widgets/verifica_conexao.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilPage extends StatefulWidget {
  final int postoID;

  PerfilPage({required this.postoID});

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  bool isLoading = true;
  bool isServerOff = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late String? token;
  Utilizador? myUser;
  

  @override
  void initState() {
    super.initState();
    loadMyUser();
  }

  void loadMyUser() async {
    try {
      final SharedPreferences prefs = await _prefs;
      setState(() {
        token = prefs.getString('token');
      });
      final fetchedUser = await fetchUtilizadorCompleto();
      setState(() {
        myUser = fetchedUser;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isServerOff = true;
      });
    }
  }

  void _alertaConfirmacaoLogout(BuildContext context) {
    ConfirmationAlert.show(
        context: context,
        onConfirm: _logout,
        desc: 'Pretende terminar a sua sessão?');
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.clear();

    // Navegar para a LoginPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: isLoading
      ? const Center(child: CircularProgressIndicator(),)
      : VerificaConexao(isLoading: isLoading, isServerOff: isServerOff, child:
       SingleChildScrollView(
        child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: buildUserAvatar(myUser?.foto, myUser?.idGoogle, myUser?.idFacebook)
                           
                    ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      myUser!.nome,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      myUser!.email ?? '-',
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => editPerfil(postoID: widget.postoID, token: token, myUser: myUser,)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            side: BorderSide.none,
                            shape: const StadiumBorder()),
                        child: const Text(
                          "Editar Perfil",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 10),
                    PerfilMenuWidget(
                      title: 'Selecionar Preferência',
                      icon: CupertinoIcons.star,
                      onPress: () {
                        Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PreferenciasPage(
                                    postoID: widget.postoID,
                                    myUser: myUser!),
                                    
                              ),
                            );
                      },
                    ),
                    PerfilMenuWidget(
                      title: "Minhas Inscrições",
                      icon: CupertinoIcons.list_bullet,
                      onPress: () {
                         Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MinhasInscricoesPage(
                                    postoID: widget.postoID),
                              ),
                            );
                      },
                    ),
                    PerfilMenuWidget(
                      title: "Meus Eventos",
                      icon: CupertinoIcons.book,
                      onPress: () {
                         Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MeusEventosPage(
                                    postoID: widget.postoID),
                              ),
                            );
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    PerfilMenuWidget(
                        title: "Logout",
                        icon: CupertinoIcons.square_arrow_left,
                        textColor: Colors.red,
                        endIcon: false,
                        onPress: () {
                          _alertaConfirmacaoLogout(context);
                        }),
                  ],
                )),
      ),
      ),
      bottomNavigationBar: NavBar(postoID: widget.postoID, index: 4),
    );
  }
}

class PerfilMenuWidget extends StatelessWidget {
  const PerfilMenuWidget({
    Key? key,
    required this.title,
    required this.icon,
    this.onPress,
    this.trailingWidget,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback? onPress;
  final Widget? trailingWidget;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        child: Icon(
          icon,
          color: secondaryColor,
          size: 27,
        ),
      ),
      title: Text(title,
          style:
              Theme.of(context).textTheme.bodySmall?.apply(color: textColor)),
      trailing: trailingWidget,
    );
  }
}
