import 'package:flutter/material.dart';
import 'package:pint/utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final double width;
  final Function()? onPressed;


  CustomButton({required this.onPressed, required this.title, this.width=380, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 380,
        child: ElevatedButton(
          onPressed: () {
            if (onPressed!=null){
            onPressed!();}
          },
          child: Text(title),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
