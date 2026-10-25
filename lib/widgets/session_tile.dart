import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/theme/app_colors.dart';
import 'package:khoaluancunhan/core/utils/date_formatter.dart';
import 'package:khoaluancunhan/models/session_model.dart';
import 'package:khoaluancunhan/widgets/status_badge.dart';

class SessionTile extends StatelessWidget {
  final VoidCallback onTap;
  final SessionModel session;
  const SessionTile({super.key, required this.onTap, required this.session});
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: const CircleAvatar(
        backgroundColor: canvas,
        child: Icon(Icons.videocam_outlined, color: brand),
      ),
      title: Text(
        'Buổi học #${session.id}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateText(session.scheduledStart)),
            Text(
              session.originalTeacherName?.toString() ??
                  'Lớp học phần #${session.classSectionId}',
            ),
            const SizedBox(height: 8),
            StatusBadge(session.status),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
