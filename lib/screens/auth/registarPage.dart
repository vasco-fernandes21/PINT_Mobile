import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import '../../api/authAPI.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthApi authApi = AuthApi();
  final _formKey = GlobalKey<FormState>();
  String _nome = '';
  String _email = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _register(_nome, _email,);
    }
  }

  Future<void> _register(String nome, String email) async {
    try {
      var response = await authApi.criarConta(nome, email);
      if (response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: "Registro bem-sucedido!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        var error = jsonDecode(response.body)['error'];
        Fluttertoast.showToast(
          msg: error,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Erro ao registar. Por favor, tente novamente.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 100), // Adjust this value to control the space at the top
                child: SvgPicture.asset(
                  'assets/images/softinsa.svg',
                  width: 200,
                  height: 200,
                ),
              ),
              SizedBox(height: 4), // Adds space between the logo and text fields
              Container(
                width: 380, // Adjust this value to control the width of the text fields
                margin: EdgeInsets.symmetric(vertical: 5), // Adds vertical margin between text fields
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o seu nome.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _nome = value!;
                  },
                ),
              ),
              SizedBox(height: 10), // Adds space between text fields
              Container(
                width: 380, // Adjust this value to control the width of the text fields
                margin: EdgeInsets.symmetric(vertical: 5), // Adds vertical margin between text fields
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o seu email.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value!;
                  },
                ),
              ),
              SizedBox(height: 10), // Adds space between text fields
              SizedBox(
                width: 380, // Define a largura do botão
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text('CRIAR CONTA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1D324F), // Define a cor de fundo do botão
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Radius da borda
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Padding
                    textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), // Tamanho do texto
                    foregroundColor: Colors.white, // Cor do texto
                  ),
                ),
              ),
              SizedBox(height: 10), // Adds space between buttons
              SizedBox(
                width: 380, // Define a largura do botão
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to the login page
                  },
                  child: Text('VOLTAR PARA LOGIN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Define a cor de fundo do botão
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Radius da borda
                      side: BorderSide(color: Color(0xFF1D324F)), // Define a cor da borda do botão
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Padding
                    textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), // Tamanho do texto
                    foregroundColor: Color(0xFF1D324F), // Cor do texto
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}