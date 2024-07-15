class Avaliacao {
  final int id;
  final int classificacao;
  final String? comentario;
  final int idUtilizador;
  final String nomeUtilizador;
  final String? fotoUtilizador;
  final String data;
  final int? idPai;
  final int? upvotes;
  final int? downvotes;
  final String? idGoogle;
  // Adicione outros campos conforme necessário

  Avaliacao({
    required this.id,
    required this.classificacao,
    this.comentario,
    required this.idUtilizador,
    required this.data,
    required this.nomeUtilizador,
    this.fotoUtilizador,
    this.upvotes,
    this.downvotes,
    this.idPai,
    this.idGoogle,
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
      upvotes: json['upvotes'],
      downvotes: json['downvotes'],
      idPai: json['idPai'],
      idGoogle: json['utilizador']['id_google'],
      // Inicialize outros campos
    );
  }
}