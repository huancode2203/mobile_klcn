import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/theme/app_colors.dart';
import 'package:khoaluancunhan/core/utils/ui_helpers.dart';
import 'package:khoaluancunhan/models/student_model.dart';
import 'package:khoaluancunhan/screens/students/student_detail_screen.dart';
import 'package:khoaluancunhan/services/api_service.dart';
import 'package:khoaluancunhan/services/student_service.dart';
import 'package:khoaluancunhan/widgets/async_data_view.dart';
import 'package:khoaluancunhan/widgets/empty_state.dart';

class StudentsScreen extends StatefulWidget {
  final ApiService api;
  const StudentsScreen({super.key, required this.api});
  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String query = '';
  int revision = 0;
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: search,
          decoration: InputDecoration(
            hintText: 'TÃ¬m tÃªn hoáº·c mÃ£ sinh viÃªn',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              onPressed: () => setState(() {
                query = search.text;
                revision++;
              }),
              icon: const Icon(Icons.arrow_forward),
            ),
          ),
          onSubmitted: (v) => setState(() {
            query = v;
            revision++;
          }),
        ),
      ),
      Expanded(
        child: AsyncDataView<List<StudentModel>>(
          revision: revision,
          load: () => StudentService(widget.api).list(query: query),
          builder: (data) => ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (data.isEmpty)
                const EmptyState('KhÃ´ng tÃ¬m tháº¥y sinh viÃªn.'),
              ...data.map(
                (s) => Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(
                      backgroundColor: brand.withValues(alpha: .1),
                      child: Text(
                        s.fullName.isEmpty ? '?' : s.fullName.characters.first,
                        style: const TextStyle(color: brand),
                      ),
                    ),
                    title: Text(
                      s.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${s.studentCode} Â· ${s.studentClass ?? 'ChÆ°a cÃ³ lá»›p'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => openScreen(
                      context,
                      StudentDetailScreen(api: widget.api, student: s),
                    ),
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
