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

List<Evento> filtrarEOrdenarEventosFuturos(List<Evento> eventos) {
  DateTime agora = DateTime.now();
  List<Evento> eventosFuturos = eventos.where((evento) {
    DateTime dataEvento = DateTime.parse(evento.data);
    return dataEvento.isAfter(agora);
  }).toList();

  eventosFuturos.sort((a, b) {
    DateTime dataA = DateTime.parse(a.data);
    DateTime dataB = DateTime.parse(b.data);
    return dataA.compareTo(dataB);
  });

  return eventosFuturos;
}

  String formatDataPublicacao(String dataPublicacao) {
    // Formata a data de publicação no formato desejado
    DateTime parsedDate = DateTime.parse(dataPublicacao);
    Duration difference = DateTime.now().difference(parsedDate);

    if (difference.inMinutes < 1) {
      return 'agora';
    } else if (difference.inMinutes < 60) {
      int minutes = difference.inMinutes;
      return 'há ${minutes == 1 ? '1 minuto' : '$minutes minutos'}';
    } else if (difference.inHours < 24) {
      int hours = difference.inHours;
      return 'há ${hours == 1 ? '1 hora' : '$hours horas'}';
    } else {
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    }
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



