import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:pint/utils/colors.dart';

class OfflineIndicator extends StatelessWidget {
  final Widget child;

  OfflineIndicator({required this.child});

  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
      connectivityBuilder: (
        BuildContext context,
        List<ConnectivityResult> connectivity,
        Widget child,
      ) {
        final bool connected = connectivity.contains(ConnectivityResult.mobile) ||
                               connectivity.contains(ConnectivityResult.wifi);

        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (!connected)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  color: errorColor,
                  child: const Center(
                    child: Text(
                      'Estás offline',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      child: child,
    );
  }
}

class ErrorServerWidget extends StatelessWidget {
  const ErrorServerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: const Text(
          'Erro ao comunicar com o servidor',
          style: TextStyle(color: Colors.red,),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class VerificaConexao extends StatelessWidget {
  final bool isLoading;
  final bool isServerOff;
  final Widget child;

  VerificaConexao({
    required this.isLoading,
    required this.isServerOff,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return OfflineIndicator(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isServerOff
              ? const ErrorServerWidget()
              : child,
    );
  }
}