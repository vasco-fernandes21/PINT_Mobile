import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import '../../api/authAPI.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RecuperarPage extends StatefulWidget {
  @override
  _RecuperarPageState createState() => _RecuperarPageState();
}

class _RecuperarPageState extends State<RecuperarPage> {
  final AuthApi authApi = AuthApi();
  final _formKey = GlobalKey<FormState>();
  String _email = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _recuperarPasse(_email);
    }
  }

  Future<void> _recuperarPasse(String email) async {
    var response = await authApi.recuperarPasse(email);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Verifique o seu email para recuperar a senha",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
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
              SizedBox(height: 100), // Adicione espaço no topo
              SvgPicture.asset(
                'assets/images/softinsa.svg',
                width: 200,
                height: 200,
              ),
              Container(
                width: 380,
                margin: EdgeInsets.only(top: 20),
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
              SizedBox(height: 30),
              SizedBox(
                width: 380,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text('RECUPERAR'),
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
                  child: Text('VOLTAR PARA LOGIN'),
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
      ),
    );
  }
}