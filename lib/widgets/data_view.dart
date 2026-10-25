import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/constants/field_labels.dart';
import 'package:khoaluancunhan/core/utils/json_utils.dart';
import 'package:khoaluancunhan/core/utils/status_labels.dart';
import 'package:khoaluancunhan/widgets/data_record_card.dart';
import 'package:khoaluancunhan/widgets/empty_state.dart';

List<Widget> buildDataWidgets(dynamic data) {
  if (data is List) {
    return data.isEmpty
        ? [const EmptyState('Chưa có dữ liệu.')]
        : data
              .map(
                (r) => r is Map
                    ? DataRecordCard(object(r))
                    : Card(child: ListTile(title: Text(label(r)))),
              )
              .toList();
  }
  if (data is Map) {
    final map = object(data);
    return [
      if (map.values.any((v) => v is! Map && v is! List)) DataRecordCard(map),
      ...map.entries
          .where((e) => e.value is Map || e.value is List)
          .map(
            (e) => ExpansionTile(
              title: Text(fieldNames[e.key] ?? e.key),
              initiallyExpanded: [
                'summary',
                'attendance',
                'autoComment',
              ].contains(e.key),
              children: buildDataWidgets(e.value),
            ),
          ),
    ];
  }
  return [Text(data?.toString() ?? 'Chưa có dữ liệu.')];
}
