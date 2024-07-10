import 'package:http/http.dart' as http;
import 'api.dart';

class NotificacoesAPI  {
  final ApiClient api = ApiClient();

  Future<http.Response> getNotificacoes() {
    return api.get('/notificacao'); 
  }

 Future<http.Response> getContadorNotificacoes() {
    return api.get('/notificacao/contador'); 
  }


}