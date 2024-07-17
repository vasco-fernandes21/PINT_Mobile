class Album {
  final int id;
  final String nome;
  final String descricao;
  final String foto;
  final int idArea;
  final int idPosto;
  final int idCriador;
  // Adicione outros campos conforme necessário

  Album({
  required this.id,
  required this.descricao,
  required this.foto,
   required this.nome,
   required this.idArea,
   required this.idPosto,
   required this.idCriador,
    // Inicialize outros campos
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      descricao: json['descricao'],
      idArea: json['idArea'],
      idPosto: json['idPosto'],
      foto: json['foto'],
      idCriador: json['idCriador'],
      nome: json['nome'],
      // Inicialize outros campos
    );
  }
}