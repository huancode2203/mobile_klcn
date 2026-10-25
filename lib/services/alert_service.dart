import 'package:khoaluancunhan/core/utils/json_utils.dart';
import 'package:khoaluancunhan/models/alert_model.dart';
import 'package:khoaluancunhan/services/api_service.dart';

class AlertService {
  final ApiService api;
  const AlertService(this.api);
  Future<List<AlertModel>> list() async =>
      rows(await api.get('/api/alerts')).map(AlertModel.fromJson).toList();
  Future<void> action(int id, String action, {String note = ''}) async {
    await api.post('/api/alerts/$id/$action', {'note': note});
  }
}
