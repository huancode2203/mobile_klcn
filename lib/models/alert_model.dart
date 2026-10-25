import 'package:khoaluancunhan/models/json.dart';

class AlertModel {
  final int id, sessionId;
  final int? studentId;
  final String type, status;
  final DateTime? createdAt;
  final String? lecturerNote;
  const AlertModel({
    required this.id,
    required this.sessionId,
    this.studentId,
    required this.type,
    required this.status,
    this.createdAt,
    this.lecturerNote,
  });
  factory AlertModel.fromJson(Json json) => AlertModel(
    id: (json['id'] as num).toInt(),
    sessionId: (json['sessionId'] as num).toInt(),
    studentId: (json['studentId'] as num?)?.toInt(),
    type: json['type']?.toString() ?? 'UNKNOWN',
    status: json['status']?.toString() ?? 'OPEN',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    lecturerNote: json['lecturerNote']?.toString(),
  );
}
