class Inscricao {
  final int id;
  final int idEvento;
  final int idUtilizador;
  final String? nomeUtilizador;
  final String? data;
  final String? tituloEvento;
  final String? dataEvento;
  final String? nomePosto;
  // Adicione outros campos conforme necessário

  Inscricao({
    required this.id,
    required this.idEvento,
    required this.idUtilizador,
    this.data,
    this.nomeUtilizador,
    this.tituloEvento,
    this.dataEvento,
    this.nomePosto,
    // Inicialize outros campos
  });

  factory Inscricao.fromJson(Map<String, dynamic> json) {
    return Inscricao(
      id: json['id'],
      idUtilizador: json['idUtilizador'],
      idEvento: json['idEvento'],
      data: json['data'],
      nomeUtilizador: json['utilizador']['nome'],
      tituloEvento: json['evento']['titulo'],
      dataEvento: json['evento']['data'],
      nomePosto: json['evento']['posto']['nome'],
      // Inicialize outros campos
    );
  }
}