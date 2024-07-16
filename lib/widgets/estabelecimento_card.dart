import 'package:flutter/material.dart';
import 'package:pint/api/api.dart';
import 'package:pint/models/estabelecimento.dart';
import 'package:pint/utils/colors.dart';

class EstabelecimentoCard extends StatelessWidget {
  Estabelecimento estab;
  final Function onTap;
  final api = ApiClient();

  EstabelecimentoCard({
    Key? key,
    required this.estab,
    required this.onTap,
  }) : super(key: key);

  String convertAndRound(String originalString) {
  try {
    // Converter a string para um double
    double value = double.parse(originalString);
    
    // Arredondar o valor para uma casa decimal
    double roundedValue = double.parse(value.toStringAsFixed(1));
    
    // Converter de volta para string
    String finalString = roundedValue.toString();
    
    return finalString;
  } catch (e) {
    return '';
  }
}

    String convertToEuroSymbols(double value) {
  if (value.isNaN) {
    return 'Valor inválido';
  } else if (value >= 0 && value < 10) {
    return '€';
  } else if (value >= 10 && value < 100) {
    return '€€';
  } else if (value >= 100 && value < 1000) {
    return '€€€';
  } else if (value >= 1000 && value < 10000) {
    return '€€€€';
  } else if (value >= 10000) {
    return '€€€€+';
  } else {
    return 'Valor inválido';
  }
}

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Card( 
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            estab.foto != null
                ? Image.network(
                    '${api.baseUrl}/uploads/estabelecimentos/${estab.foto}',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    estab.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(estab.nomeSubarea.toString()),
                  const SizedBox(height: 5),
                  Text(
                    estab.morada,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  if ((estab.classificacaoMedia != null && estab.classificacaoMedia != '0.00') || (estab.precoMedio != null && estab.precoMedio != '0.00'))
                  Row(
                    children: [
                      if(estab.classificacaoMedia !=null && estab.classificacaoMedia != '0.00')
                      const Icon(Icons.star, color: secondaryColor,),
                      Text(convertAndRound(estab.classificacaoMedia ?? ''), style: TextStyle(fontWeight: FontWeight.bold),),
                      if (estab.classificacaoMedia != null  && estab.precoMedio != null && estab.precoMedio != '0.00')
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (estab.precoMedio != null && estab.precoMedio != '0.00')
                      Text(convertToEuroSymbols(double.parse(estab.precoMedio!)), style: const TextStyle(),),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
