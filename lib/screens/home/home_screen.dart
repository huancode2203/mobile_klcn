import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/theme/app_colors.dart';
import 'package:khoaluancunhan/screens/account/account_screen.dart';
import 'package:khoaluancunhan/screens/admin/admin_screen.dart';
import 'package:khoaluancunhan/screens/alerts/alerts_screen.dart';
import 'package:khoaluancunhan/screens/dashboard/dashboard_screen.dart';
import 'package:khoaluancunhan/screens/sessions/sessions_screen.dart';
import 'package:khoaluancunhan/screens/students/students_screen.dart';
import 'package:khoaluancunhan/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final ApiService api;
  final VoidCallback? onConnectBackend;
  const HomeScreen({super.key, required this.api, this.onConnectBackend});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  ApiService get api => widget.api;
  @override
  Widget build(BuildContext context) {
    final titles = api.admin
        ? ['Hệ thống', 'Tài khoản']
        : ['Tổng quan', 'Buổi học', 'Sinh viên', 'Cảnh báo', 'Tài khoản'];
    final pages = api.admin
        ? <Widget>[
            AdminScreen(api: api),
            AccountScreen(api: api, onConnectBackend: widget.onConnectBackend),
          ]
        : <Widget>[
            DashboardScreen(
              api: api,
              onSessions: () => setState(() => tab = 1),
            ),
            SessionsScreen(api: api),
            StudentsScreen(api: api),
            AlertsScreen(api: api),
            AccountScreen(api: api, onConnectBackend: widget.onConnectBackend),
          ];
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titles[tab],
              style: const TextStyle(fontWeight: FontWeight.w800, color: ink),
            ),
            Text(
              'HTBAM · ${api.user?.fullName ?? ''}',
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: brand.withValues(alpha: .1),
              child: const Icon(Icons.school_outlined, color: brand),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (api.isDemo)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFFFF0D4),
              child: const Text(
                'DEMO LOCAL · Dữ liệu minh họa, thay đổi chỉ lưu tạm',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF865700)),
              ),
            ),
          Expanded(
            child: KeyedSubtree(key: ValueKey(tab), child: pages[tab]),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: api.admin
            ? const [
                NavigationDestination(
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  label: 'Hệ thống',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Tài khoản',
                ),
              ]
            : const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'Tổng quan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  label: 'Buổi học',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  label: 'Sinh viên',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_outlined),
                  label: 'Cảnh báo',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Tài khoản',
                ),
              ],
      ),
    );
  }
}
