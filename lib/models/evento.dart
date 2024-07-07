class Evento {
  final int id;
  final String nome;
  final String descricao;
  final String morada;
  final String? email;
  final int? telemovel;
  final String foto;
  // Adicione outros campos conforme necessário

  Evento({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.morada,
    this.email,
    this.telemovel,
    required this.foto,
    // Inicialize outros campos
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      morada: json['morada'],
      email: json['email'],
      telemovel: json['telemovel'],
      foto: json['foto'],
      // Inicialize outros campos
    );
  }
}