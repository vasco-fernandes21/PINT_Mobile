import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pint/calendario.dart';
import 'package:pint/utils/colors.dart';
import 'screens/auth/loginPage.dart';
import 'screens/auth/registarPage.dart';
import 'screens/auth/recuperarPage.dart';
import 'screens/home/homePage.dart';
import 'screens/auth/novapassPage.dart';
import 'screens/selectPosto.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env.dev"); 
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  var isLoggedIn;
  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) { 
    SystemChrome.setPreferredOrientations([ //Apenas permita usar a app em vertical
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Flutter App',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,

        colorScheme: ColorScheme.fromSeed(seedColor:primaryColor),

        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 15
          )
        )
      ),
      home: Calendario(), 
      routes: {
        '/login': (context) => LoginPage(), // Define the '/login' route
        '/registar': (context) => RegisterPage(), // Define the '/registar' route
        '/recuperar': (context) => RecuperarPage(), // Define the '/recuperar' route
        //'/': (context) => NavBar(postoID: 1), // Define the '/' route
        '/novapass': (context) => NovaPassPage(), // Define the '/novapass' route
        '/selecionarposto': (context) => SelectPosto(),
      },
    );
  }
}

