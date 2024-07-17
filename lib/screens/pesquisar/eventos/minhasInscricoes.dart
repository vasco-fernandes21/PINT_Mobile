import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pint/models/evento.dart';
import 'package:pint/models/inscricao.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/screens/pesquisar/eventos/paginaEvento.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/evento_functions.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/verifica_conexao.dart';

class MinhasInscricoesPage extends StatefulWidget {
  final int postoID;

  MinhasInscricoesPage({required this.postoID});

  @override
  State<MinhasInscricoesPage> createState() => _MinhasInscricoesPageState();
}

 class _MinhasInscricoesPageState extends State<MinhasInscricoesPage> {
  bool isLoading = true;
  bool isServerOff = false;
  List<Inscricao> inscricoes = [];
  Utilizador? myUser;

  @override
  void initState() {
    super.initState();
    loadMyUser();
  }

  void loadMyUser() async {
    try {
      final fetchedUser = await fetchUtilizadorCompleto();
      setState(() {
        myUser = fetchedUser;
      });
      loadInscricoes();
    } catch (e) {
      setState(() {
        isLoading = false;
        isServerOff = true;
      });
    }
  }

  void loadInscricoes() async {

    final fetchedInscricoes = await fetchInscricoesUser(context, myUser!.id);
    setState(() {
      inscricoes = ordenarInscricoesPorData(fetchedInscricoes);
      isLoading = false;
    });

    }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscrições'),
      ),
      body: VerificaConexao(isLoading: isLoading, isServerOff: isServerOff, child: 
       inscricoes.isEmpty
              ? const Center(
                  child: Text('Nenhuma inscrição encontrada.'),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: ListView(
                    children: [
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                        },
                        border: TableBorder.all(),
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(color: secondaryColor),
                            children: [
                              Padding(
                                padding:  EdgeInsets.all(8.0),
                                child: Text('Nome do Evento',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, fontSize: 13)),
                              ),
                              Padding(
                                padding:  EdgeInsets.all(8.0),
                                child: Text('Data',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, fontSize: 13)),
                              ),
                              Padding(
                                padding:  EdgeInsets.all(8.0),
                                child: Text('Posto',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, fontSize: 13)),
                              ),
                            ],
                          ),

                          ...inscricoes.map((inscricao) {
                            return 
                            TableRow(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EventoPage(
                                           // Passe o postoID correto aqui
                                          eventoID: inscricao.idEvento,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(inscricao.tituloEvento ?? '-',
                                        overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11),),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                     formatarDataEvento(inscricao.dataEvento),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    inscricao.nomePosto ?? '-',
                                    style: TextStyle(fontSize: 9.6),
                                  ),
                                ),
  
                                    ],
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 15,)
                    ],
                  ),
                ),
      ),
                bottomNavigationBar: NavBar(postoID: widget.postoID, index: 1),
    );
  }

  }

