class Posto {
  final int id;
  final String nome;

  Posto({required this.id, required this.nome});

  factory Posto.fromJson(Map<String, dynamic> json) {
    return Posto(
      id: json['id'],
      nome: json['nome'],
    );
  }
}
