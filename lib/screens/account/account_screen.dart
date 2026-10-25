import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/theme/app_colors.dart';
import 'package:khoaluancunhan/core/utils/ui_helpers.dart';
import 'package:khoaluancunhan/screens/classes/class_sections_screen.dart';
import 'package:khoaluancunhan/screens/shared/data_screen.dart';
import 'package:khoaluancunhan/services/api_service.dart';
import 'package:khoaluancunhan/widgets/status_badge.dart';

class AccountScreen extends StatefulWidget {
  final ApiService api;
  final VoidCallback? onConnectBackend;
  const AccountScreen({super.key, required this.api, this.onConnectBackend});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool busy = false;
  Future<void> password() async {
    final current = TextEditingController(), next = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: current,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: next,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Từ 10 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Đổi mật khẩu'),
          ),
        ],
      ),
    );
    final oldValue = current.text, newValue = next.text;
    current.dispose();
    next.dispose();
    if (accepted != true || !mounted) return;
    setState(() => busy = true);
    try {
      await widget.api.put('/api/auth/change-password', {
        'currentPassword': oldValue,
        'newPassword': newValue,
      });
      await widget.api.clear();
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.account_circle_outlined,
                  size: 52,
                  color: brand,
                ),
                const SizedBox(height: 14),
                Text(
                  api.user?.fullName.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                ),
                Text(api.user?.email.toString() ?? ''),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (api.user?.roles ?? [])
                      .map((r) => StatusBadge(r))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.dns_outlined),
          title: const Text('Máy chủ kết nối'),
          subtitle: Text(api.baseUrl),
        ),
        if (api.isDemo)
          ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('Kết nối backend thật'),
            subtitle: const Text('Thoát dữ liệu demo và nhập địa chỉ máy chủ'),
            onTap: widget.onConnectBackend,
          ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Đổi mật khẩu'),
          onTap: busy ? null : password,
        ),
        ListTile(
          leading: const Icon(Icons.monitor_heart_outlined),
          title: const Text('Trạng thái hệ thống'),
          onTap: () => openScreen(
            context,
            DataScreen(
              api: api,
              title: 'Trạng thái hệ thống',
              path: '/api/system/capabilities',
            ),
          ),
        ),
        if (!api.admin) ...[
          ListTile(
            leading: const Icon(Icons.class_outlined),
            title: const Text('Lớp học phần'),
            onTap: () => openScreen(context, ClassSectionsScreen(api: api)),
          ),
          ListTile(
            leading: const Icon(Icons.fact_check_outlined),
            title: const Text('Chính sách chuyên cần'),
            onTap: () => openScreen(
              context,
              DataScreen(
                api: api,
                title: 'Chính sách chuyên cần',
                path: '/api/attendance-policies',
              ),
            ),
          ),
        ],
        if (api.permits('SUBSTITUTE_ASSIGN'))
          ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: const Text('Cơ cấu quản lý'),
            onTap: () => openScreen(
              context,
              DataScreen(
                api: api,
                title: 'Cơ cấu quản lý',
                path: '/api/management-assignments',
              ),
            ),
          ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: busy
              ? null
              : () async {
                  if (!await showConfirmation(
                    context,
                    'Đăng xuất?',
                    'Bạn sẽ cần đăng nhập lại để sử dụng ứng dụng.',
                  )) {
                    return;
                  }
                  try {
                    if (api.isDemo) {
                      widget.onConnectBackend?.call();
                    } else {
                      await api.logout();
                    }
                  } catch (_) {
                    /* Local credentials have already been cleared. */
                  }
                },
          icon: const Icon(Icons.logout),
          label: const Text('Đăng xuất'),
        ),
      ],
    );
  }
}
