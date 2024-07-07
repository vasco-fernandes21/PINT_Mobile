class Subarea {
  final int id;
  final String nome;

  Subarea({required this.id, required this.nome});

  factory Subarea.fromJson(Map<String, dynamic> json) {
    return Subarea(
      id: json['id'],
      nome: json['nome'],
    );
  }
}
