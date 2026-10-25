import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/utils/date_formatter.dart';
import 'package:khoaluancunhan/core/utils/status_labels.dart';
import 'package:khoaluancunhan/core/utils/ui_helpers.dart';
import 'package:khoaluancunhan/models/alert_model.dart';
import 'package:khoaluancunhan/screens/sessions/session_detail_screen.dart';
import 'package:khoaluancunhan/services/alert_service.dart';
import 'package:khoaluancunhan/services/api_service.dart';
import 'package:khoaluancunhan/widgets/async_data_view.dart';
import 'package:khoaluancunhan/widgets/empty_state.dart';
import 'package:khoaluancunhan/widgets/notice_banner.dart';
import 'package:khoaluancunhan/widgets/status_badge.dart';

class AlertsScreen extends StatefulWidget {
  final ApiService api;
  const AlertsScreen({super.key, required this.api});
  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int revision = 0;
  bool busy = false;
  Future<void> act(AlertModel row, String action) async {
    String note = '';
    final accepted = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Xử lý cảnh báo'),
        content: TextField(
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Ghi chú'),
          onChanged: (v) => note = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    setState(() => busy = true);
    try {
      await AlertService(widget.api).action(row.id, action, note: note);
      if (mounted) setState(() => revision++);
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AsyncDataView<List<AlertModel>>(
    revision: revision,
    load: () => AlertService(widget.api).list(),
    builder: (data) => ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const NoticeBanner(
          'Kéo xuống để cập nhật cảnh báo. Thông báo đẩy khi chạy nền chưa được tích hợp.',
        ),
        if ((data).isEmpty)
          const EmptyState('Chưa có cảnh báo trong phạm vi của bạn.'),
        ...(data).map(
          (r) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label(r.type),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      StatusBadge(r.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Buổi #${r.sessionId} · ${r.studentId == null ? 'Chưa xác định sinh viên' : 'Sinh viên #${r.studentId}'}',
                  ),
                  Text(dateText(r.createdAt)),
                  if (r.lecturerNote != null) Text(r.lecturerNote.toString()),
                  TextButton(
                    onPressed: () => openScreen(
                      context,
                      SessionDetailScreen(api: widget.api, id: r.sessionId),
                    ),
                    child: const Text('Xem buổi học'),
                  ),
                  if (widget.api.lecturer)
                    Wrap(
                      spacing: 6,
                      children: [
                        if (r.status == 'OPEN')
                          TextButton(
                            onPressed: busy ? null : () => act(r, 'ack'),
                            child: const Text('Xác nhận'),
                          ),
                        if (r.status != 'CLOSED')
                          TextButton(
                            onPressed: busy ? null : () => act(r, 'close'),
                            child: const Text('Đóng'),
                          ),
                        if (r.status == 'CLOSED')
                          TextButton(
                            onPressed: busy ? null : () => act(r, 'reopen'),
                            child: const Text('Mở lại'),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
