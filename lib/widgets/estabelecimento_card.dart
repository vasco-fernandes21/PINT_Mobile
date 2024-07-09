import 'package:flutter/material.dart';
import 'package:pint/api/api.dart';

class EstabelecimentoCard extends StatelessWidget {
  final Map<String, dynamic> estab;
  final Function onTap;
  final api = ApiClient();

   EstabelecimentoCard({
    Key? key,
    required this.estab,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            estab['foto'] != null
                ? Image.network(
                    '${api.baseUrl}/uploads/estabelecimentos/${estab['foto']}',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey,
                    child: Icon(
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
                    estab['nome'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(estab['subarea']),
                  const SizedBox(height: 5),
                  Text(estab['morada']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
