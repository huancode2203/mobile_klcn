import 'package:khoaluancunhan/services/api_service.dart';

class ReportService {
  final ApiService api;
  const ReportService(this.api);
  Future<dynamic> get(String kind, int id) => api.get('/api/reports/$kind/$id');
  Future<List<int>> download(String kind, int id, String format) =>
      api.download('/api/reports/$kind/$id/$format');
  Future<void> generateComment(String kind, int id) async {
    await api.post('/api/reports/$kind/$id/auto-comment', {});
  }
}
