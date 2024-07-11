import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pint/api/NotificacoesAPI.dart';
import 'package:pint/models/notificacao.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificacoesPage extends StatefulWidget {
  final int postoID;

  NotificacoesPage({required this.postoID});

  @override
  _NotificacoesPageState createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late String? token;
  List<Notificacao> notificacoes = [];
  List<Notificacao> notificacoesLidas = [];
  Utilizador? myUser;
  bool isLoading = true;
  bool mostrarNaoLidas = true;

  @override
  void initState() {
    super.initState();
          loadMyUser();
    loadNotificacoes();
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
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro user: $e'),
        ),
      );
    }
  }

  Future<void> loadNotificacoes() async {
    try {
      final fetchedNotificacoes = await fetchNotificacoes(context);
      setState(() {
        notificacoes = filtrarNotificacoesPorEstado(fetchedNotificacoes, false);
        notificacoesLidas = filtrarNotificacoesPorEstado(fetchedNotificacoes, true);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Tratar erro ao carregar notificações, se necessário
      print('Erro ao carregar notificações: $e');
    }
  }

  List<Notificacao> filtrarNotificacoesPorEstado(
      List<Notificacao> listaNotificacoes, bool estadoFiltrar) {
    // Filtra as notificações com base no estado especificado
    return listaNotificacoes
        .where((notificacao) => notificacao.estado == estadoFiltrar)
        .toList();
  }

  Future<void> _marcarComoLida(Notificacao notificacao) async {
    final api = NotificacoesAPI();
    final response = await api.marcarNotificacaoComoLida(notificacao.id, token);

    if (response.statusCode == 200){
      loadNotificacoes();
      Fluttertoast.showToast(
          msg: 'Notificação marcada como lida',
          backgroundColor: successColor,
          fontSize: 12
          );
    }
    else{
      Fluttertoast.showToast(
          msg: 'Erro ao marcar notificação como lida.',
          backgroundColor: errorColor,
          fontSize: 12);
    }
  }

  Future<void> _apagarNotificacao(Notificacao notificacao) async {
    final api = NotificacoesAPI();
    final response = await api.apagarNotificacao(notificacao.id, token);

    if (response.statusCode == 200){
      loadNotificacoes();
      Fluttertoast.showToast(
          msg: 'Notificação apagada com sucesso',
          backgroundColor: successColor,
          fontSize: 12
          );
    }
    else{
      Fluttertoast.showToast(
          msg: 'Erro ao apagar notificação',
          backgroundColor: errorColor,
          fontSize: 12);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          if (notificacoes.isNotEmpty || notificacoesLidas.isNotEmpty)
          IconButton(
              onPressed: () {
                setState(() {
                  if (mostrarNaoLidas) {
                    mostrarNaoLidas = false;
                  } else {
                    mostrarNaoLidas = true;
                  }
                });
              },
              icon: Icon(mostrarNaoLidas
                  ? Icons.remove_red_eye_outlined
                  : Icons.remove_red_eye))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificacoes.isEmpty && notificacoesLidas.isEmpty
              ? const Center(child: Text('Nenhuma notificação encontrada'))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: mostrarNaoLidas
                  ?Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Não Lidas',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 15,),
                      notificacoes.isEmpty
                      ? const Center(child: Text('Não existem notifcações não lidas.'),)
                      : Expanded(
                        child: ListView.builder(
                          itemCount: notificacoes.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            Notificacao notificacao = notificacoes[index];
                            return Column(children: [
                              ListTile(
                                title: Text(
                                  notificacao.titulo,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                subtitle: Text(notificacao.descricao),
                                trailing: 
                                    // Notificação lida
                                    IconButton(
                                        icon: const Icon(Icons
                                            .mark_email_read), // Marcar como lida
                                        onPressed: () {
                                          _marcarComoLida(notificacao);
                                        },
                                      ),
                              ),
                              const Divider()
                            ]);
                          },
                        ),
                      ),
                    ],
                  )
                  :Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lidas',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 15,),
                      notificacoesLidas.isEmpty
                      ? const Center(child: Text('Não existem notifcações lidas.'),)
                      : Expanded(
                        child: ListView.builder(
                          itemCount: notificacoesLidas.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            Notificacao notificacaoLida = notificacoesLidas[index];
                            return Column(children: [
                              ListTile(
                                title: Text(
                                  notificacaoLida.titulo,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                subtitle: Text(notificacaoLida.descricao),
                                trailing: 
                                     IconButton(
                                        icon: const Icon(Icons
                                            .delete), 
                                        onPressed: () {
                                          _apagarNotificacao(notificacaoLida);
                                        },
                                      ),
                              ),
                              const Divider()
                            ]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: NavBar(postoID: widget.postoID, index: 3),
    );
  }
}
