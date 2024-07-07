class Utilizador {
  final int id;
  final String nome;
  final String? nif;
  final String? loaclidade;
  final String? telemovel;
  final String? email;
  final String? foto;
  final String? cargo;

  Utilizador({
    required this.id,
    required this.nome,
    this.nif,
    this.loaclidade,
    this.telemovel,
    this.email,
    this.foto,
    this.cargo,
     });

  factory Utilizador.fromJson(Map<String, dynamic> json) {
    return Utilizador(
      id: json['id'],
      nome: json['nome'],
      nif: json['nif'],
      loaclidade: json['loaclidade'],
      telemovel: json['telemovel'],
      email: json['email'],
      foto: json['foto'],
      cargo: json['cargo'],
    );
  }
}
