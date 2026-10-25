import 'package:khoaluancunhan/models/json.dart';

List<Json> rows(dynamic v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : [];
Json object(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : {};
