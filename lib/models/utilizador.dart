class Utilizador {
  final int id;
  final String nome;
  final String? nif;
  final String? localidade;
  final String? telemovel;
  final String? email;
  final String? foto;
  final String? cargo;
  final String? ultimoLogin;
  final int? idAreaPreferencia;
  final int? idSubareaPreferencia;
  final String? idGoogle;
  final String? idFacebook;

  Utilizador({
    required this.id,
    required this.nome,
    this.nif,
    this.localidade,
    this.telemovel,
    this.email,
    this.foto,
    this.cargo,
    this.ultimoLogin,
    this.idAreaPreferencia,
    this.idSubareaPreferencia,
    this.idGoogle,
    this.idFacebook
     });

  factory Utilizador.fromJson(Map<String, dynamic> json) {
    return Utilizador(
      id: json['id'],
      nome: json['nome'],
      nif: json['nif'],
      localidade: json['localidade'],
      telemovel: json['telemovel'],
      email: json['email'],
      foto: json['foto'],
      cargo: json['cargo'],
      ultimoLogin: json['ultimoLogin'],
      idAreaPreferencia: json['idArea'],
      idSubareaPreferencia: json['idSubarea'],
      idGoogle: json['id_google'],
      idFacebook: json['id_facebook']
    );
  }
}
