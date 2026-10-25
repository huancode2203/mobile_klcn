import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/theme/app_colors.dart';
import 'package:khoaluancunhan/core/utils/json_utils.dart';
import 'package:khoaluancunhan/core/utils/ui_helpers.dart';
import 'package:khoaluancunhan/models/session_model.dart';
import 'package:khoaluancunhan/screens/sessions/session_detail_screen.dart';
import 'package:khoaluancunhan/services/api_service.dart';
import 'package:khoaluancunhan/services/session_service.dart';
import 'package:khoaluancunhan/widgets/async_data_view.dart';
import 'package:khoaluancunhan/widgets/empty_state.dart';
import 'package:khoaluancunhan/widgets/metric_card.dart';
import 'package:khoaluancunhan/widgets/notice_banner.dart';
import 'package:khoaluancunhan/widgets/session_tile.dart';

class DashboardScreen extends StatelessWidget {
  final ApiService api;
  final VoidCallback onSessions;
  const DashboardScreen({
    super.key,
    required this.api,
    required this.onSessions,
  });
  @override
  Widget build(BuildContext context) => AsyncDataView(
    load: () async {
      final values = await Future.wait([
        SessionService(api).list(),
        api.get('/api/system/capabilities'),
      ]);
      return values;
    },
    builder: (data) {
      final sessions = data[0] as List<SessionModel>;
      final caps = object(data[1]);
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [ink, brand]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KHÔNG GIAN GIẢNG DẠY',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Xin chào, ${api.user?.fullName ?? 'giảng viên'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Nắm bắt lớp học. Theo sát từng sinh viên.',
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: 18),
                FilledButton.tonal(
                  onPressed: onSessions,
                  child: const Text('Xem buổi học →'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  'Buổi học',
                  sessions.length.toString(),
                  Icons.calendar_month,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  'Đang diễn ra',
                  sessions.where((s) => s.isRunning).length.toString(),
                  Icons.sensors,
                ),
              ),
            ],
          ),
          if (caps['sessionInference'] != true)
            NoticeBanner(
              api.isDemo
                  ? 'Chế độ local: dữ liệu minh họa để thử giao diện và thao tác. Chưa kết nối backend hoặc AI.'
                  : 'AI phân tích chưa sẵn sàng. Bạn vẫn có thể chuẩn bị buổi học và tra cứu dữ liệu đã có.',
            ),
          const SizedBox(height: 16),
          const Text(
            'Buổi học gần đây',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 10),
          if (sessions.isEmpty)
            const EmptyState('Chưa có buổi học trong phạm vi của bạn.'),
          ...sessions
              .take(5)
              .map(
                (s) => SessionTile(
                  session: s,
                  onTap: () => openScreen(
                    context,
                    SessionDetailScreen(api: api, id: s.id),
                  ),
                ),
              ),
        ],
      );
    },
  );
}
