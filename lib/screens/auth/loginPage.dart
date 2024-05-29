import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../api/authAPI.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthApi authApi = AuthApi();
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        var response = await authApi.login(_email, _password);
        if (response != null && response.containsKey('statusCode')) {
          print('Response Status Code: ${response['statusCode']}');
          if (response['statusCode'] == 200 && response.containsKey('body')) {
            var data = response['body'];
            print('Response Data: $data');
            var recoveryToken = data['recoveryToken'];

            if (recoveryToken != null && recoveryToken.isNotEmpty) {
              // If recoveryToken is present, redirect to password reset page
              Navigator.pushReplacementNamed(context, '/novapass', arguments: {'recoveryToken': recoveryToken});
            } else {
              Fluttertoast.showToast(
                msg: "Login realizado com sucesso",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              Navigator.pushReplacementNamed(context, '/');
            }
          } else {
            var error = response['body'] != null && response['body'].containsKey('error')
                ? response['body']['error']
                : 'Unknown error';
            print('Error: $error');
            Fluttertoast.showToast(
              msg: error,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } else {
          print('Response is null or does not contain statusCode');
          Fluttertoast.showToast(
            msg: 'Erro na resposta do servidor',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        print('Exception: $e');
        Fluttertoast.showToast(
          msg: 'Erro inesperado',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
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
                padding: EdgeInsets.only(top: 100), // Ajuste este valor para controlar o espaço no topo
                child: SvgPicture.asset(
                  'assets/images/softinsa.svg',
                  width: 200,
                  height: 200,
                ),
              ),
              Container(
                width: 380, // Ajuste este valor para controlar a largura do TextFormField
                margin: EdgeInsets.symmetric(vertical: 5), // Adiciona margem vertical entre os campos
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
              SizedBox(height: 10),
              Container(
                width: 380, // Ajuste este valor para controlar a largura do TextFormField
                margin: EdgeInsets.symmetric(vertical: 5), // Adiciona margem vertical entre os campos
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a sua palavra-passe.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
              ),
              SizedBox(height: 12), // Adiciona um espaço entre os botões
              Container(
                width: 380,
                margin: EdgeInsets.symmetric(vertical: 10), // Adiciona margem vertical entre o botão e os campos
                child: Column(
                  children: [
                    SizedBox(
                      width: 380, // Define a largura do botão
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Text('ENTRAR'),
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
                    SizedBox(height: 10), // Adiciona um espaço entre os botões
                    SizedBox(
                      width: 380, // Define a largura do botão
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to the registration page
                          Navigator.pushNamed(context, '/registar');
                        },
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
                  ],
                ),
              ),
              Spacer(), // Adds a flexible space before the TextButton
              Container(
                margin: EdgeInsets.only(bottom: 20), // Adds a bottom margin
                child: TextButton(
                  onPressed: () {
                    // Navigate to the password recovery page
                    Navigator.pushNamed(context, '/recuperar');
                  },
                  child: Text('Esqueceu a palavra-passe?'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}