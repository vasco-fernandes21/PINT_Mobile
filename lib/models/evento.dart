class Evento {
  final int id;
  final int idCriador;
  final int idArea;
  final int idSubarea;
  final bool estado;
  final String titulo;
  final String descricao;
  final String morada;
  final String? email;
  final String? telemovel;
  final String? foto;
  final String data;
  final String hora;
  // Adicione outros campos conforme necessário

  Evento({
    required this.id,
    required this.idCriador,
    required this.idArea,
    required this.idSubarea,
    required this.estado,
    required this.titulo,
    required this.descricao,
    required this.morada,
    required this.data,
    required this.hora,
    this.email,
    this.telemovel,
    this.foto,
    // Inicialize outros campos
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'],
      idCriador: json['idCriador'],
      idArea: json['idArea'],
      idSubarea: json['idSubarea'],
      estado: json['estado'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      morada: json['morada'],
      email: json['email'],
      telemovel: json['telemovel'],
      foto: json['foto'],
      data: json['data'],
      hora: json['hora'],
      // Inicialize outros campos
    );
  }
}