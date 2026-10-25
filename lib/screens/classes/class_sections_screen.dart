import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/utils/json_utils.dart';
import 'package:khoaluancunhan/core/utils/ui_helpers.dart';
import 'package:khoaluancunhan/screens/reports/report_screen.dart';
import 'package:khoaluancunhan/services/api_service.dart';
import 'package:khoaluancunhan/widgets/async_data_view.dart';
import 'package:khoaluancunhan/widgets/empty_state.dart';

class ClassSectionsScreen extends StatelessWidget {
  final ApiService api;
  const ClassSectionsScreen({super.key, required this.api});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Lớp học phần')),
    body: AsyncDataView(
      load: () => api.get('/api/catalogs/class-sections'),
      builder: (data) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (rows(data).isEmpty) const EmptyState('Chưa có lớp học phần.'),
          ...rows(data).map(
            (r) => Card(
              child: ListTile(
                title: Text('${r['code']} · ${r['name']}'),
                subtitle: Text('${r['semester']} · ${r['academicYear']}'),
                trailing: const Icon(Icons.bar_chart),
                onTap: () => openScreen(
                  context,
                  ReportScreen(api: api, kind: 'class-sections', id: r['id']),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
