import 'package:khoaluancunhan/core/utils/date_formatter.dart';
import 'package:khoaluancunhan/core/utils/status_labels.dart';

String fieldValue(String key, dynamic v) {
  if (v == null) return '—';
  if (v is bool) return v ? 'Có' : 'Không';
  if (v is num &&
      (key.toLowerCase().contains('ratio') ||
          [
            'focused',
            'distracted',
            'sleepy',
            'active',
            'observationQuality',
          ].contains(key))) {
    return '${(v * 100).toStringAsFixed(1)}%';
  }
  if (key.endsWith('At') || key.startsWith('scheduled')) return dateText(v);
  return label(v);
}
