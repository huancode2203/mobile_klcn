import 'package:khoaluancunhan/core/utils/json_utils.dart';
import 'package:khoaluancunhan/models/json.dart';
import 'package:khoaluancunhan/models/session_model.dart';
import 'package:khoaluancunhan/services/api_service.dart';

class SessionService {
  final ApiService api;
  const SessionService(this.api);
  Future<List<SessionModel>> list({String status = ''}) async => rows(
    await api.get(
      '/api/sessions${status.isEmpty ? '' : '?status=${Uri.encodeQueryComponent(status)}'}',
    ),
  ).map(SessionModel.fromJson).toList();
  Future<Json> detail(int id) async =>
      object(await api.get('/api/sessions/$id'));
  Future<Json> dashboard(int id) async =>
      object(await api.get('/api/sessions/$id/dashboard'));
  Future<void> create(Json body) async {
    await api.post('/api/sessions', body);
  }

  Future<void> action(int id, String action) async {
    await api.post('/api/sessions/$id/$action', {});
  }
}
