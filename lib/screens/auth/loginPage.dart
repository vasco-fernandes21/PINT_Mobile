import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../api/authAPI.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pint/screens/selectPosto.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthApi authApi = AuthApi();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
            print('Solicitando permissões...');
            await requestPermissions();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectPosto(),
                ));
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
  }else {
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

  Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.photos,
  ].request();

  statuses.forEach((permission, status) {
    if (status.isDenied) {
      Fluttertoast.showToast(
        msg: 'Permissão ${permission.toString()} foi negada.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else if (status.isPermanentlyDenied) {
      Fluttertoast.showToast(
        msg: 'Permissão ${permission.toString()} foi permanentemente negada. Por favor, permita nas configurações.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  });
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
                  padding: EdgeInsets.symmetric(
                      horizontal: 10), // Ajuste este valor para controlar o espaço no topo
                  child: SvgPicture.asset(
                    'assets/images/softinsa.svg',
                    height: 120,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                SizedBox(
                    height:
                        20), // Adiciona espaço entre o logo e o primeiro campo
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
                  width:
                      380, // Adiciona margem vertical entre o botão e os campos
                  child: Column(
                    children: [
                      SizedBox(
                        width: 380, // Define a largura do botão
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: Text('ENTRAR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(
                                0xFF1D324F), // Define a cor de fundo do botão
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Radius da borda
                            ),
                            // Padding
                            textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.bold), // Tamanho do texto
                            foregroundColor: Colors.white, // Cor do texto
                          ),
                        ),
                      ),
                      SizedBox(
                          height: 10), // Adiciona um espaço entre os botões
                      SizedBox(
                        width: 380,
                        height: 40, // Define a largura do botão
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to the registration page
                            Navigator.pushNamed(context, '/registar');
                          },
                          child: Text('CRIAR CONTA'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(
                                0xFF1D324F), // Define a cor de fundo do botão
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Radius da borda
                            ),
                            // Padding
                            textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.bold), // Tamanho do texto
                            foregroundColor: Colors.white, // Cor do texto
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Adds a flexible space before the TextButton
                Container(
                  child: TextButton(
                    onPressed: () {
                      // Navigate to the password recovery page
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
