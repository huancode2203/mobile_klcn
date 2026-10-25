import 'package:flutter/material.dart';
import 'package:khoaluancunhan/models/face_enrollment_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khoaluancunhan/core/errors/api_exception.dart';
import 'package:khoaluancunhan/core/theme/app_colors.dart';
import 'package:khoaluancunhan/core/utils/ui_helpers.dart';
import 'package:khoaluancunhan/models/student_model.dart';
import 'package:khoaluancunhan/screens/shared/data_screen.dart';
import 'package:khoaluancunhan/services/api_service.dart';
import 'package:khoaluancunhan/services/face_enrollment_service.dart';
import 'package:khoaluancunhan/widgets/async_data_view.dart';
import 'package:khoaluancunhan/widgets/empty_state.dart';
import 'package:khoaluancunhan/widgets/notice_banner.dart';
import 'package:khoaluancunhan/widgets/status_badge.dart';

class FaceEnrollmentScreen extends StatefulWidget {
  final ApiService api;
  final StudentModel student;
  const FaceEnrollmentScreen({
    super.key,
    required this.api,
    required this.student,
  });
  @override
  State<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen> {
  int revision = 0;
  bool busy = false;
  String pose = 'FRONT';
  FaceEnrollmentService get service =>
      FaceEnrollmentService(widget.api, widget.student.id);
  String get root => service.root;
  Future<void> run(Future<void> Function() work) async {
    setState(() => busy = true);
    try {
      await work();
      if (mounted) setState(() => revision++);
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> upload(int id, ImageSource source) async {
    await run(() async {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 92,
      );
      if (image == null) return;
      if (await image.length() > 8 * 1024 * 1024) {
        throw const ApiException('Ảnh phải nhỏ hơn hoặc bằng 8 MB.');
      }
      await service.upload(
        id,
        image.path,
        pose: pose,
        fromCamera: source == ImageSource.camera,
      );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Đăng ký khuôn mặt')),
    body: AsyncDataView<List<FaceEnrollmentModel>>(
      revision: revision,
      load: () => service.list(),
      builder: (data) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.student.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const NoticeBanner(
            'Cần tối thiểu 6 ảnh rõ mặt, đủ góc chính diện, trái và phải. Nếu AI chưa sẵn sàng, hồ sơ sẽ chờ xử lý.',
          ),
          FilledButton.icon(
            onPressed: busy
                ? null
                : () => run(() async {
                    await service.create();
                  }),
            icon: const Icon(Icons.add),
            label: const Text('Tạo lần đăng ký'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: pose,
            decoration: const InputDecoration(
              labelText: 'Góc mặt cho ảnh tải lên',
            ),
            items: const [
              DropdownMenuItem(value: 'FRONT', child: Text('Chính diện')),
              DropdownMenuItem(value: 'LEFT', child: Text('Nghiêng trái')),
              DropdownMenuItem(value: 'RIGHT', child: Text('Nghiêng phải')),
              DropdownMenuItem(value: 'UP', child: Text('Ngẩng lên')),
              DropdownMenuItem(value: 'DOWN', child: Text('Cúi xuống')),
            ],
            onChanged: busy ? null : (v) => setState(() => pose = v!),
          ),
          const SizedBox(height: 16),
          if ((data).isEmpty)
            const EmptyState('Chưa có lần đăng ký khuôn mặt.'),
          ...(data).map(
            (r) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Lần đăng ký #${r.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        StatusBadge(r.status),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${r.uploadedImageCount} ảnh · ${r.passedImageCount} ảnh đạt',
                    ),
                    if (r.failureReason != null)
                      NoticeBanner(r.failureReason.toString(), error: true),
                    if (['IN_PROGRESS', 'NEEDS_RETAKE'].contains(r.status))
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton.icon(
                            onPressed: busy
                                ? null
                                : () => upload(r.id, ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Chụp ảnh'),
                          ),
                          TextButton.icon(
                            onPressed: busy
                                ? null
                                : () => upload(r.id, ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Chọn ảnh'),
                          ),
                          TextButton(
                            onPressed: busy
                                ? null
                                : () => run(() async {
                                    await service.submit(r.id);
                                  }),
                            child: const Text('Gửi đăng ký'),
                          ),
                        ],
                      ),
                    if (r.status == 'PENDING_AI')
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => run(() async {
                                await service.process(r.id);
                              }),
                        child: const Text('Yêu cầu xử lý AI'),
                      ),
                    TextButton(
                      onPressed: () => openScreen(
                        context,
                        DataScreen(
                          api: widget.api,
                          title: 'Chi tiết đăng ký',
                          path: '$root/${r.id}',
                        ),
                      ),
                      child: const Text('Xem ảnh & chất lượng'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
