import 'package:khoaluancunhan/services/api_service.dart';

class CatalogService {
  final ApiService api;
  const CatalogService(this.api);
  Future<List<dynamic>> sessionOptions() => Future.wait(
    [
      '/api/catalogs/class-sections',
      '/api/catalogs/rooms',
      '/api/catalogs/cameras',
      '/api/videos',
      '/api/attendance-policies',
    ].map(api.get),
  );
}
