import 'package:intl/intl.dart';
import 'package:pint/models/avaliacao.dart';
import 'package:pint/models/evento.dart';
import 'package:pint/models/inscricao.dart';

// Função para contar avaliações por estrela
int contarAvaliacoesPorEstrela(List<Avaliacao> avaliacoes, int estrelas) {
  return avaliacoes
      .where((avaliacao) => avaliacao.classificacao == estrelas)
      .length;
}

//Função para devolver uma string formata da data e hora do evento
String formatarDataHora(String data, String hora) {
  final DateFormat dateFormatter = DateFormat(
    'yyyy-MM-dd',
  );
  final DateFormat timeFormatter = DateFormat(
    'HH:mm:ss',
  );
  final DateTime date = dateFormatter.parse(data);
  final DateTime time = timeFormatter.parse(hora);

  // Combina a data e a hora em um único DateTime
  final DateTime dateTime = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
    time.second,
  );

  final DateFormat outputFormat = DateFormat(
    'dd/MM/yyyy (EEEE),',
  );
  final DateFormat hourFormat = DateFormat(
    'HH\'h\'mm',
  );

  String formattedDate = outputFormat.format(dateTime);
  String formattedTime = hourFormat.format(dateTime);

  return '$formattedDate $formattedTime';
}

  bool verificaCriador(int meuId, Evento evento) {
    if (evento.idCriador == meuId){
      return true;
    }
    return false;
  }

  bool verificaInscricao(int meuId, List<Inscricao> inscricoes) {
    for (var inscricao in inscricoes) {
      if (inscricao.idUtilizador == meuId) {
        return true;
      }
    }
    return false;
  }

