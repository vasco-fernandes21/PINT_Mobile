import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth/loginPage.dart';
import 'screens/auth/registarPage.dart';
import 'screens/auth/recuperarPage.dart';
import 'screens/homePage.dart';

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
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue, // Use um MaterialColor para primarySwatch
        ).copyWith(
          primary: Color(0xFF1D324F), // Defina primary para a sua cor personalizada
          secondary: Colors.blue, // Defina secondary (cor de destaque) para azul
        ),
      ),
      initialRoute: '/login', // Define the initial route
      routes: {
        '/login': (context) => LoginPage(), // Define the '/login' route
        '/registar': (context) => RegisterPage(), // Define the '/registar' route
        '/recuperar': (context) => RecuperarPage(), // Define the '/recuperar' route
        '/': (context) => HomePage(), // Define the '/' route
      },
    );
  }
}