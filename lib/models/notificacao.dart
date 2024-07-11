class Notificacao {
  final int id;
  final int idUtilizador;
  final String titulo;
  final String descricao;
  final bool estado;
  final String data;
  // Adicione outros campos conforme necessário

  Notificacao({
    required this.id,
    required this.idUtilizador,
    required this.titulo,
    required this.data,
    required this.estado,
    required this.descricao,
    // Inicialize outros campos
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) {
    return Notificacao(
      id: json['id'],
      idUtilizador: json['idUtilizador'],
      data: json['data'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      estado: json['estado'],
      // Inicialize outros campos
    );
  }
}