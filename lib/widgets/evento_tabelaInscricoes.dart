import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pint/models/inscricao.dart'; // Para formatar a data

class TabelaInscricoes extends StatelessWidget {
  final List<Inscricao> inscricoes;

  TabelaInscricoes({required this.inscricoes});

  String formatarData(String data) {
    DateTime dateTime = DateTime.parse(data);
    dateTime = dateTime.add(Duration(hours: 1)); // Adiciona 1 hora
    return DateFormat('dd/MM/yy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(
          label: Text(
            'Nome',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Data',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: inscricoes.map((inscricao) {
        return DataRow(
          cells: <DataCell>[
            DataCell(Text(inscricao.nomeUtilizador ?? '')),
            DataCell(Text(formatarData(inscricao.data ?? ''))),
          ],
        );
      }).toList(),
    );
  }
}