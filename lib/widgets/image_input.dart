import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';



class ImageInput extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onPickImage;
  final bool validator;

  const ImageInput({
    Key? key,
    required this.selectedImage,
    required this.onPickImage,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
    children: [
    InkWell(
      onTap: onPickImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: selectedImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      icon: Icon(Icons.edit, color: Colors.white),
                      onPressed: onPickImage,
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      color: Colors.grey[700],
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Insere uma imagem',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
      ),
    ),
    if (validator)
          Text(
            'Por favor, insira uma foto',
            style: TextStyle(color: Colors.red),
          ),
    ],
    );
  }
}
