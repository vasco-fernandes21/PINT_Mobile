import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth/loginPage.dart';
import 'screens/auth/registarPage.dart';
import 'screens/auth/recuperarPage.dart';
import 'screens/home/homePage.dart';
import 'screens/auth/novapassPage.dart';
import 'screens/selectPosto.dart';
import 'navbar.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env.dev"); 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) { 
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Flutter App',
      theme: ThemeData(
        primaryColor: Color(0xFF1D324F),
        
        scaffoldBackgroundColor: Colors.white,

        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 15
          )
        )
      ),
      initialRoute: '/selecionarposto', // Define the initial route
      routes: {
        '/login': (context) => LoginPage(), // Define the '/login' route
        '/registar': (context) => RegisterPage(), // Define the '/registar' route
        '/recuperar': (context) => RecuperarPage(), // Define the '/recuperar' route
        //'/': (context) => NavBar(postoID: 1), // Define the '/' route
        '/novapass': (context) => NovaPassPage(), // Define the '/novapass' route
        '/selecionarposto': (context) => SelectPosto()
      },
    );
  }
}