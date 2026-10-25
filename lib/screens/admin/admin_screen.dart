import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/theme/app_colors.dart';
import 'package:khoaluancunhan/core/utils/ui_helpers.dart';
import 'package:khoaluancunhan/screens/shared/data_screen.dart';
import 'package:khoaluancunhan/services/api_service.dart';
import 'package:khoaluancunhan/widgets/notice_banner.dart';

class AdminScreen extends StatelessWidget {
  final ApiService api;
  const AdminScreen({super.key, required this.api});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const NoticeBanner(
        'Khu vực quản trị hệ thống. Dữ liệu học vụ được phân quyền riêng cho giảng viên.',
      ),
      ...<String, String>{
        'Tài khoản người dùng': '/api/admin/users',
        'Phòng học': '/api/catalogs/rooms',
        'Camera': '/api/catalogs/cameras',
        'Nhật ký hệ thống': '/api/audit',
        'Trạng thái dịch vụ': '/api/system/capabilities',
      }.entries.map(
        (e) => Card(
          child: ListTile(
            leading: const Icon(Icons.settings_outlined, color: brand),
            title: Text(e.key),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => openScreen(
              context,
              DataScreen(api: api, title: e.key, path: e.value),
            ),
          ),
        ),
      ),
    ],
  );
}
