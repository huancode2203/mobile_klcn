import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/utils/ui_helpers.dart';
import 'package:khoaluancunhan/services/api_service.dart';
import 'package:khoaluancunhan/services/report_service.dart';
import 'package:khoaluancunhan/widgets/async_data_view.dart';
import 'package:khoaluancunhan/widgets/data_view.dart';
import 'package:share_plus/share_plus.dart';

class ReportScreen extends StatefulWidget {
  final ApiService api;
  final String kind;
  final int id;
  const ReportScreen({
    super.key,
    required this.api,
    required this.kind,
    required this.id,
  });
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int revision = 0;
  bool busy = false;
  Future<void> export(String format) async {
    setState(() => busy = true);
    try {
      final bytes = await ReportService(widget.api)
          .download(widget.kind, widget.id, format);
      final ext = format == 'excel' ? 'xlsx' : 'pdf';
      final file = XFile.fromData(
        Uint8List.fromList(bytes),
        mimeType: format == 'excel'
            ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
            : 'application/pdf',
        name: 'HTBAM_${widget.kind}_${widget.id}.$ext',
      );
      if (!kIsWeb &&
          [
            TargetPlatform.android,
            TargetPlatform.iOS,
          ].contains(defaultTargetPlatform)) {
        if (!mounted) return;
        final box = context.findRenderObject() as RenderBox?;
        await SharePlus.instance.share(
          ShareParams(
            files: [file],
            fileNameOverrides: ['HTBAM_${widget.kind}_${widget.id}.$ext'],
            sharePositionOrigin: box == null
                ? null
                : box.localToGlobal(Offset.zero) & box.size,
          ),
        );
        return;
      }
      final location = await getSaveLocation(
        suggestedName: 'HTBAM_${widget.kind}_${widget.id}.$ext',
      );
      if (location == null) return;
      await file.saveTo(location.path);
      if (mounted) showMessage(context, 'Đã lưu báo cáo.');
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> generate() async {
    setState(() => busy = true);
    try {
      await ReportService(widget.api).generateComment(widget.kind, widget.id);
      if (mounted) setState(() => revision++);
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Báo cáo & chuyên cần')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: busy ? null : () => export('pdf'),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Lưu PDF'),
              ),
              FilledButton.tonalIcon(
                onPressed: busy ? null : () => export('excel'),
                icon: const Icon(Icons.table_chart_outlined),
                label: const Text('Lưu Excel'),
              ),
              if (widget.api.lecturer && widget.kind != 'students')
                TextButton(
                  onPressed: busy ? null : generate,
                  child: const Text('Tạo nhận xét tự động'),
                ),
            ],
          ),
        ),
        if (busy) const LinearProgressIndicator(),
        Expanded(
          child: AsyncDataView(
            revision: revision,
            load: () => ReportService(widget.api).get(widget.kind, widget.id),
            builder: (data) => ListView(
              padding: const EdgeInsets.all(16),
              children: buildDataWidgets(data),
            ),
          ),
        ),
      ],
    ),
  );
}
