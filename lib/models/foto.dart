class Foto {
  final int id;
  final String foto;
  final int? idEvento;
  final int idCriador;
  final String? nomeCriador;
  final String? descricao;
  // Adicione outros campos conforme necessário

  Foto({
    required this.id,
   required this.foto,
    this.idEvento,
   required this.idCriador,
   this.nomeCriador,
   this.descricao,
    // Inicialize outros campos
  });

  factory Foto.fromJson(Map<String, dynamic> json) {
    return Foto(
      id: json['id'],
      idEvento: json['idEvento'],
      foto: json['foto'],
      idCriador: json['idCriador'],
      nomeCriador: json['criador']['nome'],
      descricao: json['descricao'],
      // Inicialize outros campos
    );
  }
}