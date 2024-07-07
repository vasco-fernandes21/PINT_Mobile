import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ConfirmationAlert {
  static void show({
    required BuildContext context,
    required VoidCallback onConfirm,
    required String desc,
  }) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "CONFIRMAÇÃO",
      desc: desc,
      style: const AlertStyle(
        descStyle: TextStyle(fontSize: 14),
        titleStyle: TextStyle(fontSize: 20),
        alertPadding: EdgeInsets.symmetric(horizontal: 20),
      ),
      buttons: [
        DialogButton(
          child: const Text(
            "Sim",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          color: const Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: const Text(
            "Cancelar",
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
          onPressed: () => Navigator.pop(context),
          border: Border.all(color: Colors.red),
          highlightColor: Colors.red,
          color: Colors.white,
        ),
      ],
    ).show();
  }
}