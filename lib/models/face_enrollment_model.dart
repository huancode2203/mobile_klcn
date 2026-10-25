import 'package:khoaluancunhan/models/json.dart';

class FaceEnrollmentModel {
  final int id, uploadedImageCount, passedImageCount;
  final String status;
  final String? failureReason;
  const FaceEnrollmentModel({
    required this.id,
    required this.status,
    required this.uploadedImageCount,
    required this.passedImageCount,
    this.failureReason,
  });
  factory FaceEnrollmentModel.fromJson(Json json) => FaceEnrollmentModel(
    id: (json['id'] as num).toInt(),
    status: json['status']?.toString() ?? 'UNKNOWN',
    uploadedImageCount: (json['uploadedImageCount'] as num?)?.toInt() ?? 0,
    passedImageCount:
        ((json['passedImageCount'] ?? json['acceptedImageCount']) as num?)
            ?.toInt() ??
        0,
    failureReason: json['failureReason']?.toString(),
  );
  bool get canUpload => status == 'IN_PROGRESS' || status == 'NEEDS_RETAKE';
}
