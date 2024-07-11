import 'package:flutter/material.dart';
import 'package:pint/utils/form_validators.dart';

class TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String errorMessage;
  final bool isFieldRequired;
  final int minLines;

  TextInput({
    required this.controller,
    required this.label,
    this.keyboardType,
    required this.errorMessage,
    this.isFieldRequired = true,
    this.minLines = 1, // por padrão, o campo é obrigatório
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: isFieldRequired
          ? (value) => validateNotEmpty(value, errorMessage: errorMessage)
          : null,
      keyboardType: keyboardType,
    );
  }
}
