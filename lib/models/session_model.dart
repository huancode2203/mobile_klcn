import 'package:khoaluancunhan/models/json.dart';

class SessionModel {
  final int id, classSectionId;
  final String status;
  final DateTime? scheduledStart;
  final String? originalTeacherName;
  final bool canOperate, canManage;
  const SessionModel({
    required this.id,
    required this.classSectionId,
    required this.status,
    this.scheduledStart,
    this.originalTeacherName,
    this.canOperate = false,
    this.canManage = false,
  });
  factory SessionModel.fromJson(Json json) => SessionModel(
    id: (json['id'] as num).toInt(),
    classSectionId: (json['classSectionId'] as num).toInt(),
    status: json['status']?.toString() ?? 'UNKNOWN',
    scheduledStart: DateTime.tryParse(json['scheduledStart']?.toString() ?? ''),
    originalTeacherName: json['originalTeacherName']?.toString(),
    canOperate: json['canOperate'] == true,
    canManage: json['canManage'] == true,
  );
  bool get isRunning => status == 'RUNNING';
}
