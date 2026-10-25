import 'package:flutter/material.dart';
import 'package:khoaluancunhan/models/session_model.dart';
import 'package:khoaluancunhan/core/utils/status_labels.dart';
import 'package:khoaluancunhan/core/utils/ui_helpers.dart';
import 'package:khoaluancunhan/screens/sessions/create_session_screen.dart';
import 'package:khoaluancunhan/screens/sessions/session_detail_screen.dart';
import 'package:khoaluancunhan/services/api_service.dart';
import 'package:khoaluancunhan/services/session_service.dart';
import 'package:khoaluancunhan/widgets/async_data_view.dart';
import 'package:khoaluancunhan/widgets/empty_state.dart';
import 'package:khoaluancunhan/widgets/session_tile.dart';

class SessionsScreen extends StatefulWidget {
  final ApiService api;
  const SessionsScreen({super.key, required this.api});
  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  String filter = '';
  int revision = 0;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: filter,
                decoration: const InputDecoration(labelText: 'Trạng thái'),
                items:
                    [
                          '',
                          'READY',
                          'RUNNING',
                          'COMPLETED',
                          'FINALIZE_FAILED',
                          'CANCELLED',
                        ]
                        .map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text(v.isEmpty ? 'Tất cả' : label(v)),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() {
                  filter = v ?? '';
                  revision++;
                }),
              ),
            ),
            if (widget.api.lecturer) ...[
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => CreateSessionScreen(api: widget.api),
                    ),
                  );
                  if (mounted) setState(() => revision++);
                },
                icon: const Icon(Icons.add),
                tooltip: 'Tạo buổi học',
              ),
            ],
          ],
        ),
      ),
      Expanded(
        child: AsyncDataView<List<SessionModel>>(
          revision: revision,
          load: () => SessionService(widget.api).list(status: filter),
          builder: (data) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if ((data).isEmpty) const EmptyState('Chưa có buổi học phù hợp.'),
              ...(data).map(
                (s) => SessionTile(
                  session: s,
                  onTap: () => openScreen(
                    context,
                    SessionDetailScreen(api: widget.api, id: s.id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
