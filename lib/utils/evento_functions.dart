import 'package:intl/intl.dart';
import 'package:pint/models/avaliacao.dart';
import 'package:pint/models/evento.dart';
import 'package:pint/models/inscricao.dart';
import 'package:pint/models/utilizador.dart';

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

List<Evento> filtrarEventosPorPreferencia(List<Evento> eventos, Utilizador user) {

  // Verifica se ambos idAreaPreferencia e idSubareaPreferencia são nulos
  if (user.idAreaPreferencia == null && user.idSubareaPreferencia == null) {
    return [];
  }
  
  // Filtra os eventos de acordo com a preferência do usuário
  if (user.idSubareaPreferencia != null) {
    return eventos.where((evento) => evento.idSubarea == user.idSubareaPreferencia).toList();
  } else if (user.idAreaPreferencia != null) {
    return eventos.where((evento) => evento.idArea == user.idAreaPreferencia).toList();
  } else {
    return []; 
  }
}

List<Inscricao> ordenarInscricoesPorData(List<Inscricao> inscricoes) {
  inscricoes.sort((a, b) {
    // Verifica se ambos dataEvento são não nulos
    if (a.dataEvento != null && b.dataEvento != null) {
      DateTime dataA = DateTime.parse(a.dataEvento!);
      DateTime dataB = DateTime.parse(b.dataEvento!);
      return dataA.compareTo(dataB);
    } else if (a.dataEvento == null && b.dataEvento != null) {
      // Se a.dataEvento é nulo e b.dataEvento não é, coloca a antes de b
      return 1;
    } else if (a.dataEvento != null && b.dataEvento == null) {
      // Se b.dataEvento é nulo e a.dataEvento não é, coloca b antes de a
      return -1;
    } else {
      // Se ambos são nulos, considera-os iguais
      return 0;
    }
  });
  return inscricoes;
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

String formatarDataEventoCard(String? data) {
  if (data == null) return '-';

  final DateFormat dateFormatter = DateFormat(
    'yyyy-MM-dd',
  );
  final DateTime date = dateFormatter.parse(data);

  final DateTime dateTime = DateTime(
    date.year,
    date.month,
    date.day,
  );

  final DateFormat outputFormat = DateFormat(
    'dd/MM/yyyy',
  );

  String formattedDate = outputFormat.format(dateTime);

  return formattedDate;
}

String formatarDataEvento(String? data) {
  if (data == null) return '-';

  final DateFormat dateFormatter = DateFormat(
    'yyyy-MM-dd',
  );
  final DateTime date = dateFormatter.parse(data);

  final DateTime dateTime = DateTime(
    date.year,
    date.month,
    date.day,
  );

  final DateFormat outputFormat = DateFormat(
    'd/M/yy',
  );

  String formattedDate = outputFormat.format(dateTime);

  return formattedDate;
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
    'dd/MM/yyyy (EEEE)',
  );
  final DateFormat hourFormat = DateFormat(
    'HH\'h\'mm',
  );

  String formattedDate = outputFormat.format(dateTime);
  String formattedTime = hourFormat.format(dateTime);

  return '$formattedDate\n$formattedTime';
}

String diasAte(String data) {

  

  // Parse the input date string into a DateTime object
  DateTime dataFutura = DateTime.parse(data);
  
  // Get the current date
  DateTime hoje = DateTime.now();
  
  // Remove the time component from the current date
  hoje = DateTime(hoje.year, hoje.month, hoje.day);
  
  // Calculate the difference in days between the future date and today
  Duration diferenca = dataFutura.difference(hoje);
  
  // Get the number of days
  int diasFaltantes = diferenca.inDays;
  
  // Determine the appropriate message based on the number of days
  if (diasFaltantes == 0) {
    return 'Hoje!';
  } else if (diasFaltantes == 1) {
    return 'Falta 1 dia!';
  } else {
    return 'Faltam $diasFaltantes dias';
  }
}


bool verificaCriador(int meuId, Evento evento) {
  if (evento.idCriador == meuId) {
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

List<Avaliacao> filtrarComentariosNaoNulos(List<Avaliacao> comentarios) {
  return comentarios.where((comentario) => comentario.comentario != null).toList();
}

