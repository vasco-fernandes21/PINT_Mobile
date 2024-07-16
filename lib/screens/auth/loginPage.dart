import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../api/authAPI.dart';
import 'package:pint/screens/selectPosto.dart';
import 'package:http/http.dart' as http; // Importa o pacote http

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthApi authApi = AuthApi();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        var response = await authApi.login(
            _emailController.text, _passwordController.text);
        if (response != null && response.containsKey('statusCode')) {
          print('Response Status Code: ${response['statusCode']}');
          if (response['statusCode'] == 200 && response.containsKey('body')) {
            var data = response['body'];
            print('Response Data: $data');
            var recoveryToken = data['recoveryToken'] ?? '';

            if (recoveryToken.isNotEmpty) {
              Navigator.pushReplacementNamed(context, '/novapass',
                  arguments: {'recoveryToken': recoveryToken});
            } else {
              Fluttertoast.showToast(
                msg: "Login realizado com sucesso",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectPosto(),
                ),
              );
            }
          } else {
            var error = response['body'] != null &&
                    response['body'].containsKey('error')
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

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;
        if (idToken != null) {
          final response = await authApi.googleLogin(idToken);

          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            print('Response Data: $data');

            if (data['token'] != null) {
              // Armazena o token e detalhes do usuário
              String token = data['token'];

              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', true);
              await prefs.setString('token', token);

              // Navega para a página desejada
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectPosto(),
                ),
              );
            } else {
              Fluttertoast.showToast(
                msg: 'Erro ao fazer login. Verifique se a conta foi criada corretamente.',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          } else {
            var errorData = jsonDecode(response.body);
            Fluttertoast.showToast(
              msg: errorData['error'] ?? 'Erro ao fazer login com o Google',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        }
      }
    } catch (error) {
      print('Erro ao fazer login com o Google: $error');
      Fluttertoast.showToast(
        msg: 'Erro ao fazer login com o Google',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.i.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();

        final String email = userData['email'];
        final String nome = userData['name'];
        final String foto = userData['picture']['data']['url'];
        final String id = userData['id'].toString(); 

        print('Email: $email');
        print('Name: $nome');
        print('Foto: $foto');
        print('ID: $id');

        final response = await authApi.facebookLogin(id,nome, email, foto);

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          print('Response Data: $data');

          if (data['token'] != null) {
            // Armazena o token e detalhes do usuário
            String token = data['token'];

            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('token', token);

            // Navega para a página desejada
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SelectPosto(),
              ),
            );
          } else {
            Fluttertoast.showToast(
              msg: 'Erro ao fazer login. Verifique se a conta foi criada corretamente.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } else {
          var errorData = jsonDecode(response.body);
          Fluttertoast.showToast(
            msg: errorData['error'] ?? 'Erro ao fazer login com o Facebook',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Erro ao fazer login com o Facebook',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      print('Erro ao fazer login com o Facebook: $error');
      Fluttertoast.showToast(
        msg: 'Erro ao fazer login com o Facebook',
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
        padding: const EdgeInsets.symmetric(horizontal: 17),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 220),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SvgPicture.asset(
                    'assets/images/softinsa.svg',
                    height: 120,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 380,
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
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
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  width: 380,
                  child: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    controller: _passwordController,
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
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: 380,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 380,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: Text('ENTRAR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1D324F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 380,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/registar');
                          },
                          child: Text('CRIAR CONTA'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1D324F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 380,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _signInWithGoogle,
                          child: Text('ENTRAR COM GOOGLE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Cor padrão para o botão do Google
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 380,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _signInWithFacebook,
                          child: Text('ENTRAR COM FACEBOOK'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800], // Cor padrão para o botão do Facebook
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/recuperar');
                    },
                    child: const Text(
                      'Esqueceste-te da palavra-passe?',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
