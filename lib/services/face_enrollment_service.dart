import 'package:khoaluancunhan/core/utils/json_utils.dart';
import 'package:khoaluancunhan/models/face_enrollment_model.dart';
import 'package:khoaluancunhan/services/api_service.dart';

class FaceEnrollmentService {
  final ApiService api;
  final int studentId;
  const FaceEnrollmentService(this.api, this.studentId);
  String get root => '/api/students/$studentId/face-enrollments';
  Future<List<FaceEnrollmentModel>> list() async =>
      rows(await api.get(root)).map(FaceEnrollmentModel.fromJson).toList();
  Future<void> create() async {
    await api.post(root, {});
  }

  Future<void> submit(int id) async {
    await api.post('$root/$id/submit', {});
  }

  Future<void> process(int id) async {
    await api.post('$root/$id/process', {});
  }

  Future<void> upload(
    int id,
    String filePath, {
    required String pose,
    required bool fromCamera,
  }) => api.upload(
    '$root/$id/images',
    filePath,
    fields: {
      'capturePose': pose,
      'sourceType': fromCamera ? 'CAMERA' : 'UPLOAD',
    },
  );
}
