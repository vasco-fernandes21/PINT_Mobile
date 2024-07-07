class Avaliacao {
  final int id;
  final int classificacao;
  final String? comentario;
  final int idUtilizador;
  final String nomeUtilizador;
  final String? fotoUtilizador;
  final String data;
  // Adicione outros campos conforme necessário

  Avaliacao({
    required this.id,
    required this.classificacao,
    this.comentario,
    required this.idUtilizador,
    required this.data,
    required this.nomeUtilizador,
    this.fotoUtilizador,
    // Inicialize outros campos
  });

  factory Avaliacao.fromJson(Map<String, dynamic> json) {
    return Avaliacao(
      id: json['id'],
      classificacao: json['classificacao'],
      comentario: json['comentario'],
      idUtilizador: json['idUtilizador'],
      data: json['data'],
      nomeUtilizador: json['utilizador']['nome'],
      fotoUtilizador: json['utilizador']['foto'],
      // Inicialize outros campos
    );
  }
}