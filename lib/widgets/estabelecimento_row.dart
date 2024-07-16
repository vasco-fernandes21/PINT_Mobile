import 'package:flutter/material.dart';
import 'package:pint/api/api.dart';
import 'package:pint/models/estabelecimento.dart';
import 'package:pint/screens/pesquisar/estabelecimentos/paginaEstabelecimento.dart';

class EstabelecimentoRow extends StatelessWidget {
  final Estabelecimento estabelecimento;
  final int postoID;
  final api = ApiClient();

  EstabelecimentoRow({required this.estabelecimento, required this.postoID});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EstabelecimentoPage(
                
                estabelecimentoID: estabelecimento.id,
              ),
            ),
          );
        },
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(10), // Altura fixa para todos os cards
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10), // Raio de borda para a imagem
                child: estabelecimento.foto != null
                    ? Image.network(
                        '${api.baseUrl}/uploads/estabelecimentos/${estabelecimento.foto}',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.event,
                          color: Colors.grey[600],
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      estabelecimento.nome,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      estabelecimento.morada, 
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                        overflow: TextOverflow.ellipsis
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
