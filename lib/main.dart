import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/screens/pesquisar/estabelecimentos/paginaEstabelecimento.dart';
import 'package:pint/screens/pesquisar/eventos/paginaEvento.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/widgets/verifica_conexao.dart';
import 'screens/auth/loginPage.dart';
import 'screens/selectPosto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env.dev");
  initializeDateFormatting();
  Intl.defaultLocale = 'pt_PT';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  bool isServerOff = false;

  if (isLoggedIn) {
    try {
      Utilizador? myUser = await fetchUtilizadorCompleto();
      if (myUser == null) {
        isLoggedIn = false;
      }
    } catch (e) {
      isServerOff = true;
    }
  }

  runApp(MyApp(isLoggedIn: isLoggedIn, isServerOff: isServerOff));
}

GoRouter createRouter(bool isLoggedIn, bool isServerOff) {
  return GoRouter(
    initialLocation: isServerOff ? '/error' : isLoggedIn ? '/selectposto' : '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return LoginPage();
        },
      ),
      GoRoute(
        path: '/selectposto',
        builder: (BuildContext context, GoRouterState state) {
          return SelectPosto();
        },
      ),
      GoRoute(
        path: '/error',
        builder: (BuildContext context, GoRouterState state) {
          return ErrorServerWidget();
        },
      ),
      GoRoute(
        path: '/estabelecimentos/:id',
        builder: (BuildContext context, GoRouterState state) {
          int? estabelecimentoID = int.tryParse(state.pathParameters['id'] ?? '');
          return EstabelecimentoPage(estabelecimentoID: estabelecimentoID ?? 0,);
        },
      ),
      GoRoute(
        path: '/eventos/:id',
        builder: (BuildContext context, GoRouterState state) {
          int? eventoID = int.tryParse(state.pathParameters['id'] ?? '');
          return EventoPage(eventoID: eventoID ?? 0,);
        },
      ),
    ],
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isServerOff;

  const MyApp({
    required this.isLoggedIn,
    required this.isServerOff,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final GoRouter _router = createRouter(isLoggedIn, isServerOff);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'The Softshares',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 15),
        ),
      ),
      routerConfig: _router,
    );
  }
}