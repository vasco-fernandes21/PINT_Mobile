class Area {
  final int id;
  final String nome;

  Area({required this.id, required this.nome});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      nome: json['nome'],
    );
  }
}
