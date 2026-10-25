import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/theme/app_colors.dart';
import 'package:khoaluancunhan/core/utils/ui_helpers.dart';
import 'package:khoaluancunhan/models/student_model.dart';
import 'package:khoaluancunhan/screens/face_enrollment/face_enrollment_screen.dart';
import 'package:khoaluancunhan/screens/reports/report_screen.dart';
import 'package:khoaluancunhan/services/api_service.dart';

class StudentDetailScreen extends StatelessWidget {
  final ApiService api;
  final StudentModel student;
  const StudentDetailScreen({
    super.key,
    required this.api,
    required this.student,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Hồ sơ sinh viên')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(
          radius: 42,
          backgroundColor: brand,
          child: Icon(Icons.person_outline, color: Colors.white, size: 46),
        ),
        const SizedBox(height: 20),
        Text(
          student.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: ink,
          ),
        ),
        Text(student.studentCode, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(student.email?.toString() ?? 'Chưa có email'),
              ),
              ListTile(
                leading: const Icon(Icons.class_outlined),
                title: Text(student.studentClass?.toString() ?? 'Chưa có lớp'),
              ),
              ListTile(
                leading: const Icon(Icons.verified_user_outlined),
                title: Text(
                  student.isActive == true
                      ? 'Đang hoạt động'
                      : 'Ngừng hoạt động',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (api.permits('FACE_ENROLL_SCOPE'))
          FilledButton.icon(
            onPressed: () => openScreen(
              context,
              FaceEnrollmentScreen(api: api, student: student),
            ),
            icon: const Icon(Icons.face),
            label: const Text('Đăng ký khuôn mặt'),
          ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () => openScreen(
            context,
            ReportScreen(api: api, kind: 'students', id: student.id),
          ),
          icon: const Icon(Icons.bar_chart),
          label: const Text('Báo cáo sinh viên'),
        ),
      ],
    ),
  );
}
