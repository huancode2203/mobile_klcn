import 'dart:async';

import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/theme/app_colors.dart';
import 'package:khoaluancunhan/core/utils/date_formatter.dart';
import 'package:khoaluancunhan/core/utils/json_utils.dart';
import 'package:khoaluancunhan/core/utils/status_labels.dart';
import 'package:khoaluancunhan/core/utils/ui_helpers.dart';
import 'package:khoaluancunhan/models/json.dart';
import 'package:khoaluancunhan/screens/reports/report_screen.dart';
import 'package:khoaluancunhan/screens/shared/data_screen.dart';
import 'package:khoaluancunhan/services/api_service.dart';
import 'package:khoaluancunhan/services/session_service.dart';
import 'package:khoaluancunhan/widgets/data_record_card.dart';
import 'package:khoaluancunhan/widgets/empty_state.dart';
import 'package:khoaluancunhan/widgets/metric_card.dart';
import 'package:khoaluancunhan/widgets/notice_banner.dart';
import 'package:khoaluancunhan/widgets/status_badge.dart';

class SessionDetailScreen extends StatefulWidget {
  final ApiService api;
  final int id;
  const SessionDetailScreen({super.key, required this.api, required this.id});
  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen>
    with WidgetsBindingObserver {
  Timer? timer;
  int revision = 0;
  bool busy = false, refreshing = false;
  Json detail = {}, snapshot = {};
  String? error;
  DateTime? updated;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refresh();
    timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (['RUNNING', 'STARTING', 'FINALIZING'].contains(detail['status'])) {
        refresh();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  Future<void> refresh() async {
    if (refreshing) return;
    refreshing = true;
    try {
      final d = await SessionService(widget.api).detail(widget.id);
      final s = await SessionService(widget.api).dashboard(widget.id);
      if (mounted) {
        setState(() {
          detail = d;
          snapshot = s;
          error = null;
          updated = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      refreshing = false;
    }
  }

  Future<void> action(String command) async {
    if (!await showConfirmation(
      context,
      '${labelAction(command)} buổi học?',
      'Thao tác được thực hiện trên hệ thống dùng chung với website.',
    )) {
      return;
    }
    if (!mounted) return;
    setState(() => busy = true);
    try {
      await SessionService(widget.api).action(widget.id, command);
      await refresh();
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String labelAction(String s) =>
      const {
        'start': 'Bắt đầu',
        'stop': 'Kết thúc',
        'cancel': 'Hủy',
        'retry-finalize': 'Thử tổng hợp lại',
      }[s] ??
      s;
  @override
  Widget build(BuildContext context) {
    final state = detail['status'];
    final behavior = object(snapshot['behavior']);
    return Scaffold(
      appBar: AppBar(
        title: Text('Buổi học #${widget.id}'),
        actions: [
          IconButton(onPressed: refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (error != null) NoticeBanner(error!, error: true),
            if (detail.isEmpty && error == null)
              const Center(child: CircularProgressIndicator()),
            if (detail.isNotEmpty) ...[
              Text(
                detail['course']?.toString() ?? 'Buổi học',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              Text(
                '${detail['classSection'] ?? ''} · ${detail['actualTeacherName'] ?? detail['teacher'] ?? ''}',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusBadge(state),
                  StatusBadge(detail['cameraId'] != null ? 'Camera' : 'Video'),
                ],
              ),
              const SizedBox(height: 12),
              Text(dateText(detail['scheduledStart'])),
              if (snapshot['modelReady'] != true)
                NoticeBanner(
                  widget.api.isDemo
                      ? 'DEMO LOCAL · Số liệu và hành vi dưới đây chỉ để minh họa giao diện, không phải kết quả AI thật.'
                      : 'AI chưa sẵn sàng. Trạng thái và dữ liệu được lấy từ máy chủ; không có kết quả phân tích giả.',
                ),
              if (updated != null)
                Text(
                  'Cập nhật ${dateText(updated!.toIso8601String())} · mỗi 10 giây khi đang chạy',
                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      'Đã nhận diện',
                      '${snapshot['identifiedStudents'] ?? 0}',
                      Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      'Chưa xác định',
                      '${snapshot['unknownIdentities'] ?? 0}',
                      Icons.person_search_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Phân bố hành vi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              ...['focused', 'distracted', 'sleepy', 'active'].map((k) {
                final value = (behavior[k] as num? ?? 0).toDouble().clamp(
                  0.0,
                  1.0,
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${label(k.toUpperCase())} · ${(value * 100).toStringAsFixed(1)}%',
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
              if (detail['canOperate'] == true && widget.api.lecturer)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (state == 'READY')
                      FilledButton.icon(
                        onPressed: busy ? null : () => action('start'),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Bắt đầu'),
                      ),
                    if (state == 'RUNNING')
                      FilledButton.icon(
                        onPressed: busy ? null : () => action('stop'),
                        icon: const Icon(Icons.stop),
                        label: const Text('Kết thúc'),
                      ),
                    if (state == 'FINALIZE_FAILED')
                      FilledButton(
                        onPressed: busy ? null : () => action('retry-finalize'),
                        child: const Text('Thử tổng hợp lại'),
                      ),
                  ],
                ),
              if (detail['canManage'] == true &&
                  widget.api.lecturer &&
                  ['READY', 'DRAFT'].contains(state))
                TextButton(
                  onPressed: busy ? null : () => action('cancel'),
                  child: const Text('Hủy buổi học'),
                ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => openScreen(
                  context,
                  ReportScreen(
                    api: widget.api,
                    kind: 'sessions',
                    id: widget.id,
                  ),
                ),
                icon: const Icon(Icons.bar_chart),
                label: const Text('Báo cáo & điểm danh'),
              ),
              TextButton.icon(
                onPressed: () => openScreen(
                  context,
                  DataScreen(
                    api: widget.api,
                    title: 'Lịch sử hành vi',
                    path: '/api/history/sessions/${widget.id}/behaviors',
                  ),
                ),
                icon: const Icon(Icons.history),
                label: const Text('Lịch sử hành vi'),
              ),
              TextButton.icon(
                onPressed: () => openScreen(
                  context,
                  DataScreen(
                    api: widget.api,
                    title: 'Lịch sử nhận diện',
                    path: '/api/history/sessions/${widget.id}/identities',
                  ),
                ),
                icon: const Icon(Icons.face),
                label: const Text('Lịch sử nhận diện'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sinh viên trong buổi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              ...rows(detail['roster']).map(
                (r) => Card(
                  child: ListTile(
                    title: Text(r['fullName']?.toString() ?? 'Sinh viên'),
                    subtitle: Text(r['studentCode']?.toString() ?? ''),
                  ),
                ),
              ),
              if (rows(detail['roster']).isEmpty)
                const EmptyState('Chưa có sinh viên.'),
              if (rows(snapshot['identities']).isNotEmpty) ...[
                const Text('Nhận diện đang hoạt động'),
                ...rows(snapshot['identities']).map((r) => DataRecordCard(r)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
