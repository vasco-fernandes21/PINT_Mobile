import 'package:flutter/material.dart';
import 'package:pint/utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final double width;
  final Function()? onPressed;
  final Color backgroundColor;
  final Color textColor;

  CustomButton(
      {required this.onPressed,
      required this.title,
      this.width = 380,
      this.backgroundColor = primaryColor,
      this.textColor = Colors.white,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 380,
        child: ElevatedButton(
          onPressed: () {
            if (onPressed != null) {
              onPressed!();
            }
          },
          child: Text(title),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor
          ),
        ),
      ),
    );
  }
}
