import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pint/models/avaliacao.dart';
import 'package:pint/utils/evento_functions.dart';
import 'package:rating_summary/rating_summary.dart';

class SumarioAvaliacoesWidget extends StatelessWidget {
  final int numAvaliacoes;
  final double mediaAvaliacoes;
  final List<Avaliacao> avaliacoes;

  const SumarioAvaliacoesWidget({
    required this.numAvaliacoes,
    required this.mediaAvaliacoes,
    required this.avaliacoes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: RatingSummary(
            counter: numAvaliacoes,
            counterFiveStars: contarAvaliacoesPorEstrela(avaliacoes, 5),
            counterFourStars: contarAvaliacoesPorEstrela(avaliacoes, 4),
            counterThreeStars: contarAvaliacoesPorEstrela(avaliacoes, 3),
            counterTwoStars: contarAvaliacoesPorEstrela(avaliacoes, 2),
            counterOneStars: contarAvaliacoesPorEstrela(avaliacoes, 1),
            showAverage: false,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                mediaAvaliacoes.toStringAsFixed(1),
                style: const TextStyle(fontSize: 40),
              ),
              RatingBarIndicator(
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                rating: mediaAvaliacoes,
                itemSize: 26,
                unratedColor: Colors.grey[300],
              ),
              Text(
                '$numAvaliacoes avaliações',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
