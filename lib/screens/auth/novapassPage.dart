import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pint/screens/auth/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api.dart'; // Certifique-se de que o caminho está correto

class NovaPassPage extends StatefulWidget {
  @override
  _NovaPassPageState createState() => _NovaPassPageState();
}

class _NovaPassPageState extends State<NovaPassPage> {
  final ApiClient api = ApiClient();
  final _formKey = GlobalKey<FormState>();
  String _password = '';
  String _confirmPassword = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_password != _confirmPassword) {
        Fluttertoast.showToast(
          msg: "As palavras-passe não coincidem.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }
      _changePassword(_password);
    }
  }

  Future<String?> getRecoveryToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('recoveryToken');
}

  Future<void> _changePassword(String password) async {
    String? recoveryToken = await getRecoveryToken();
    try {
      var response = await api.post('/reset-passe', body: {
        'novaPass': password,
        'token': recoveryToken,
      });

      Fluttertoast.showToast(
        msg: "Palavra-passe redefinida com sucesso",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('recoveryToken');
        Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
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
                padding: EdgeInsets.only(top: 100),
                child: SvgPicture.asset(
                  'assets/images/softinsa.svg',
                  width: 200,
                  height: 200,
                ),
              ),
              Container(
                width: 380,
                margin: EdgeInsets.symmetric(vertical: 5),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nova palavra-passe',
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
                      return 'Por favor, insira a nova palavra-passe.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 380,
                margin: EdgeInsets.symmetric(vertical: 5),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Confirmar palavra-passe',
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
                      return 'Por favor, confirme a nova palavra-passe.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _confirmPassword = value!;
                  },
                ),
              ),
              SizedBox(height: 12),
              Container(
                width: 380,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    SizedBox(
                      width: 380,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Text('ALTERAR PALAVRA-PASSE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1D324F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 380,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('CANCELAR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Color(0xFF1D324F)),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          foregroundColor: Color(0xFF1D324F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
