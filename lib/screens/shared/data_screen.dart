import 'package:flutter/material.dart';
import 'package:khoaluancunhan/services/api_service.dart';
import 'package:khoaluancunhan/widgets/async_data_view.dart';
import 'package:khoaluancunhan/widgets/data_view.dart';

class DataScreen extends StatelessWidget {
  final ApiService api;
  final String title, path;
  const DataScreen({
    super.key,
    required this.api,
    required this.title,
    required this.path,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: AsyncDataView(
      load: () => api.get(path),
      builder: (data) => ListView(
        padding: const EdgeInsets.all(16),
        children: buildDataWidgets(data),
      ),
    ),
  );
}
