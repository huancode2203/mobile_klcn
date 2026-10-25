import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/utils/date_formatter.dart';
import 'package:khoaluancunhan/core/utils/json_utils.dart';
import 'package:khoaluancunhan/core/utils/ui_helpers.dart';
import 'package:khoaluancunhan/models/json.dart';
import 'package:khoaluancunhan/services/api_service.dart';
import 'package:khoaluancunhan/services/catalog_service.dart';
import 'package:khoaluancunhan/services/session_service.dart';
import 'package:khoaluancunhan/widgets/notice_banner.dart';

class CreateSessionScreen extends StatefulWidget {
  final ApiService api;
  const CreateSessionScreen({super.key, required this.api});
  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  late Future<List<dynamic>> catalogs;
  int? section, room, source, policy;
  bool camera = true, busy = false;
  DateTime start = DateTime.now().add(const Duration(hours: 1)),
      end = DateTime.now().add(const Duration(hours: 3));
  String? error;
  @override
  void initState() {
    super.initState();
    catalogs = CatalogService(widget.api).sessionOptions();
  }

  Future<void> pick(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? start : end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? start : end),
    );
    if (time == null || !mounted) return;
    setState(() {
      final d = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (isStart) {
        start = d;
      } else {
        end = d;
      }
    });
  }

  Widget select(
    String title,
    List<Json> items,
    int? selected,
    void Function(int?) change,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: DropdownButtonFormField<int>(
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(labelText: title),
      items: items
          .map(
            (r) => DropdownMenuItem<int>(
              value: r['id'] as int,
              child: Text(
                '${r['code'] ?? ''} ${r['name'] ?? r['fileName'] ?? ''}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: busy ? null : change,
    ),
  );
  Future<void> save() async {
    if (section == null ||
        policy == null ||
        source == null ||
        (camera && room == null)) {
      setState(
        () => error =
            'Chọn đủ lớp, chính sách, nguồn và phòng (nếu dùng camera).',
      );
      return;
    }
    if (!end.isAfter(start)) {
      setState(() => error = 'Kết thúc phải sau thời gian bắt đầu.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await SessionService(widget.api).create({
        'classSectionId': section,
        'roomId': room,
        'cameraId': camera ? source : null,
        'videoId': camera ? null : source,
        'attendancePolicyId': policy,
        'scheduledStart': start.toUtc().toIso8601String(),
        'scheduledEnd': end.toUtc().toIso8601String(),
        'studentIds': <int>[],
        'alertProfile': 'DEFAULT',
      });
      if (mounted) {
        showMessage(context, 'Đã tạo buổi học.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tạo buổi học')),
    body: FutureBuilder<List<dynamic>>(
      future: catalogs,
      builder: (context, s) {
        if (s.hasError) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              NoticeBanner(s.error.toString(), error: true),
              FilledButton(
                onPressed: () => setState(
                  () => catalogs = CatalogService(widget.api).sessionOptions(),
                ),
                child: const Text('Thử lại'),
              ),
            ],
          );
        }
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final data = s.data!;
        final sources = rows(data[camera ? 2 : 3])
            .where(
              (r) => camera
                  ? r['isActive'] == true && r['roomId'] == room
                  : r['status'] == 'READY' && r['videoType'] == 'INPUT_UPLOAD',
            )
            .toList();
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const NoticeBanner(
              'Danh sách sinh viên được lấy từ lớp học phần và lưu riêng cho buổi học.',
            ),
            select(
              'Lớp học phần',
              rows(data[0]).where((r) => r['isActive'] == true).toList(),
              section,
              (v) => setState(() => section = v),
            ),
            select(
              'Chính sách chuyên cần',
              rows(data[4]).where((r) => r['isActive'] == true).toList(),
              policy,
              (v) => setState(() => policy = v),
            ),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('Camera'),
                  icon: Icon(Icons.videocam_outlined),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Video'),
                  icon: Icon(Icons.video_file_outlined),
                ),
              ],
              selected: {camera},
              onSelectionChanged: busy
                  ? null
                  : (v) => setState(() {
                      camera = v.first;
                      source = null;
                    }),
            ),
            const SizedBox(height: 16),
            select(
              'Phòng học',
              rows(data[1]).where((r) => r['isActive'] == true).toList(),
              room,
              (v) => setState(() {
                room = v;
                if (camera) source = null;
              }),
            ),
            select(
              camera ? 'Camera trong phòng' : 'Video đã tải lên',
              sources,
              source,
              (v) => setState(() => source = v),
            ),
            ListTile(
              title: const Text('Bắt đầu'),
              subtitle: Text(dateText(start.toIso8601String())),
              trailing: const Icon(Icons.edit_calendar),
              onTap: busy ? null : () => pick(true),
            ),
            ListTile(
              title: const Text('Kết thúc'),
              subtitle: Text(dateText(end.toIso8601String())),
              trailing: const Icon(Icons.edit_calendar),
              onTap: busy ? null : () => pick(false),
            ),
            if (error != null) NoticeBanner(error!, error: true),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: busy ? null : save,
              child: Text(busy ? 'Đang lưu…' : 'Tạo buổi học'),
            ),
          ],
        );
      },
    ),
  );
}
