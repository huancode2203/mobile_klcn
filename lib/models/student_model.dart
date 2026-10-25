import 'package:khoaluancunhan/models/json.dart';

class StudentModel {
  final int id;
  final String studentCode, fullName;
  final String? email, studentClass;
  final bool isActive;
  const StudentModel({
    required this.id,
    required this.studentCode,
    required this.fullName,
    this.email,
    this.studentClass,
    required this.isActive,
  });
  factory StudentModel.fromJson(Json json) => StudentModel(
    id: (json['id'] as num).toInt(),
    studentCode: json['studentCode']?.toString() ?? '',
    fullName: json['fullName']?.toString() ?? '',
    email: json['email']?.toString(),
    studentClass: json['studentClass']?.toString(),
    isActive: json['isActive'] == true,
  );
}
