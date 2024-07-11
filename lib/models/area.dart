class Area {
  final int id;
  final String nome;
  final String? icone;

  Area({required this.id, required this.nome, this.icone});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      nome: json['nome'],
      icone: json['icone'],
    );
  }
}
