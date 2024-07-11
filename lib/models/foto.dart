class Foto {
  final int id;
  final String foto;
  final int idEvento;
  final int idCriador;
  final String? nomeCriador;
  // Adicione outros campos conforme necessário

  Foto({
    required this.id,
   required this.foto,
   required this.idEvento,
   required this.idCriador,
   this.nomeCriador,
    // Inicialize outros campos
  });

  factory Foto.fromJson(Map<String, dynamic> json) {
    return Foto(
      id: json['id'],
      idEvento: json['idEvento'],
      foto: json['foto'],
      idCriador: json['idCriador'],
      nomeCriador: json['criador']['nome'],
      // Inicialize outros campos
    );
  }
}