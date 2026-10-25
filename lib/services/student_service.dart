import 'package:khoaluancunhan/core/utils/json_utils.dart';
import 'package:khoaluancunhan/models/student_model.dart';
import 'package:khoaluancunhan/services/api_service.dart';

class StudentService {
  final ApiService api;
  const StudentService(this.api);
  Future<List<StudentModel>> list({String query = ''}) async => rows(
    await api.get(
      '/api/students?q=${Uri.encodeQueryComponent(query)}&status=all&includeInactive=true',
    ),
  ).map(StudentModel.fromJson).toList();
}
