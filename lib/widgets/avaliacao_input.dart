import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pint/utils/colors.dart';

class AvaliacaoInput extends StatefulWidget {
  final TextEditingController controller;
  final void Function(double) onRatingUpdate;
  final bool validator;

  const AvaliacaoInput({
    Key? key,
    required this.controller,
    required this.onRatingUpdate,
    required this.validator,
  }) : super(key: key);

  @override
  _AvaliacaoInputState createState() => _AvaliacaoInputState();
}

class _AvaliacaoInputState extends State<AvaliacaoInput> {
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: 'Escreva a sua avaliação...',
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: 3,
        ),
        SizedBox(height: 10),
        Center(
          child: RatingBar(
            minRating: 1,
            ratingWidget: RatingWidget(
              full: Icon(Icons.star, color: Theme.of(context).primaryColor),
              half: Icon(Icons.star_half, color: Theme.of(context).primaryColor),
              empty: Icon(Icons.star, color: Colors.grey[300]),
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
              widget.onRatingUpdate(rating);
            },
          ),
        ),
        if(widget.validator)
        Center(
          child: Text('Por favor, insira uma classificação', style: TextStyle(color: errorColor),)
        )
      ],
    );
  }
}
