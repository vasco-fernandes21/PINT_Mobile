import 'dart:io';
import 'package:flutter/material.dart';

String? validateNotEmpty(String? value, {required String errorMessage}) {
  if (value == null || value.isEmpty) {
    return errorMessage;
  }
  return null;
}

String? validateImage(File? image, {required String errorMessage}) {
  if (image == null) {
    return errorMessage;
  }
  return null;
}

String? validateDateAndTime(DateTime? date, TimeOfDay? time) {
  if (date == null) {
    return 'Por favor, selecione uma data';
  }
  if (time == null) {
    return 'Por favor, selecione uma hora';
  }

 DateTime now = DateTime.now();
  DateTime selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

  if (selectedDateTime.isBefore(now) || selectedDateTime.isAtSameMomentAs(now)) {
    return 'Por favor, selecione uma data no futuro';
  }

  return null;
}


/*String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor, insira um email';
  }
  // Adicione aqui regex para validação de email
  return null;
}*/
