import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pint/api/postosAreasAPI.dart';
import 'dart:convert';
import 'package:pint/navbar.dart';
import 'package:pint/screens/home/homePage.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/widgets/verifica_conexao.dart';

class SelectPosto extends StatefulWidget {
  @override
  _SelectPostoState createState() => _SelectPostoState();
}

class _SelectPostoState extends State<SelectPosto> {
  List<Map<String, dynamic>> options = [];
  Map<String, dynamic>? selectedPosto;
  int selectedPostoId = 0;
  String selectedPostoNome = '';
  bool isLoading = true;
  bool isServerOff = false;
  
  @override
  void initState() {
    super.initState();
    fetchOptions();
  }

  void fetchOptions() async {
    try {
    final api = PostosAreasAPI();
    final response = await api.listarPostos();

  if (response.statusCode == 200) {
      try {
        // Decodificar a resposta JSON
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        // Verificar se a chave 'data' existe na resposta
        if (jsonResponse.containsKey('data')) {
          // Acessar a lista de postos dentro de 'data'
          List<dynamic> postos = jsonResponse['data'];

          setState(() {
            options = postos.map<Map<String, dynamic>>((item) => {
              'id': item['id'],
              'nome': item['nome'],
            }).cast<Map<String, dynamic>>().toList();
            isLoading = false;
          });
        } else {
          // Se 'data' não estiver presente na resposta
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dados de postos não encontrados na resposta')),
          );
        }
      } catch (e) {
        // Capturar e mostrar erros de decodificação JSON
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar os dados: $e')),
        );
      }
    } else {
      // Tratar erros de status HTTP
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: ${response.statusCode}')),
      );
    }
    } catch (e){
      isLoading = false;
      isServerOff = true;
    }

  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VerificaConexao(isLoading: isLoading, isServerOff: isServerOff, child: 
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
          <Widget>[
             SvgPicture.asset('assets/images/softinsa.svg'),
            Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(5),
              ),
            child: DropdownButton<Map<String, dynamic>>(
              underline: SizedBox(),
              dropdownColor: Colors.white,
              hint: Text('Seleciona um posto'),
              value: selectedPosto,
              onChanged: (Map<String, dynamic>? newValue) {
                setState(() {
                  selectedPosto = newValue;
                  selectedPostoId = newValue!['id'];
                });
              },
              items: options.map<DropdownMenuItem<Map<String, dynamic>>>((Map<String, dynamic> value) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: value,
                  child: Text(value['nome']),
                );
              } as DropdownMenuItem<Map<String, dynamic>> Function(Map<String, dynamic> e)).toList(),
            ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedPosto != null) {
                 Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(postoID: selectedPostoId,),
                    ),
                  ); 
                } else {                
                  Fluttertoast.showToast(msg: 'Erro: Nenhum posto selecionado', backgroundColor: Colors.red);
                }
              },
              style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor, // Define a cor de fundo do botão
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Radius da borda
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Padding
                          textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), // Tamanho do texto
                          foregroundColor: Colors.white, // Cor do texto
                        ),
              child: Text('Continuar'),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
