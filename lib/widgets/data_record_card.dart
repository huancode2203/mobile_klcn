import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/constants/field_labels.dart';
import 'package:khoaluancunhan/core/utils/field_formatter.dart';
import 'package:khoaluancunhan/models/json.dart';

class DataRecordCard extends StatelessWidget {
  final Json record;
  const DataRecordCard(this.record, {super.key});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: record.entries
            .where((e) => e.value is! Map && e.value is! List)
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${fieldNames[e.key] ?? e.key}: ${fieldValue(e.key, e.value)}',
                  style: const TextStyle(height: 1.4),
                ),
              ),
            )
            .toList(),
      ),
    ),
  );
}
