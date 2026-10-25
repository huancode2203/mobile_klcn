import 'package:khoaluancunhan/data/demo/demo_students.dart';

import 'dart:convert';

import 'package:khoaluancunhan/core/errors/api_exception.dart';
import 'package:khoaluancunhan/core/utils/json_utils.dart';
import 'package:khoaluancunhan/models/json.dart';
import 'package:khoaluancunhan/models/user_model.dart';
import 'package:khoaluancunhan/services/api_service.dart';

/// Local-only repository. Every mutation is in memory and resets on reopening.
class DemoApiService extends ApiService {
  @override
  bool get isDemo => true;
  final List<Json> students = createDemoStudents();
  late final List<Json> sessions = [
    session(101, 'READY', DateTime.now().add(const Duration(hours: 1))),
    session(
      102,
      'RUNNING',
      DateTime.now().subtract(const Duration(minutes: 35)),
    ),
    session(103, 'COMPLETED', DateTime.now().subtract(const Duration(days: 1))),
  ];
  late final List<Json> alerts = [
    {
      'id': 1,
      'sessionId': 102,
      'studentId': 2,
      'type': 'DISTRACTED',
      'status': 'OPEN',
      'confidence': .91,
      'observationQuality': .87,
      'createdAt': DateTime.now().toIso8601String(),
      'startedAt': DateTime.now().toIso8601String(),
      'lecturerNote': null,
    },
  ];
  final Map<int, List<Json>> enrollments = {};
  Json session(int id, String status, DateTime time) => {
    'id': id,
    'classSectionId': 1,
    'classSection': 'HTTT-01',
    'course': 'Phân tích và thiết kế hệ thống',
    'teacher': 'Giảng viên Demo',
    'originalTeacherName': 'Giảng viên Demo',
    'actualTeacherName': 'Giảng viên Demo',
    'scheduledStart': time.toIso8601String(),
    'scheduledEnd': time.add(const Duration(hours: 2)).toIso8601String(),
    'status': status,
    'cameraId': 1,
    'roomId': 1,
    'attendancePolicyId': 1,
    'canOperate': status != 'COMPLETED' && status != 'CANCELLED',
    'canManage': true,
    'roster': students
        .map(
          (s) => {
            'studentId': s['id'],
            'studentCode': s['studentCode'],
            'fullName': s['fullName'],
          },
        )
        .toList(),
  };
  DemoApiService() {
    baseUrl = 'Local · dữ liệu minh họa';
  }
  @override
  Future<void> restore() async {
    token = 'local-demo';
    user = UserModel.fromJson({
      'id': 1,
      'fullName': 'Giảng viên Demo',
      'email': 'demo@example.test',
      'roles': ['LECTURER'],
      'permissions': [
        'SESSION_CREATE_SCOPE',
        'FACE_ENROLL_SCOPE',
        'STUDENT_EDIT_SCOPE',
      ],
    });
  }

  @override
  Future<void> clear() async {
    token = null;
    user = null;
    notifyListeners();
  }

  @override
  Future<void> logout() => clear();
  @override
  Future<void> login(String server, String name, String password) async =>
      throw const ApiException('Thoát chế độ demo để đăng nhập máy chủ thật.');
  dynamic copy(dynamic data) => jsonDecode(jsonEncode(data));
  @override
  Future<dynamic> request(String method, String path, [Json? body]) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final uri = Uri.parse(path);
    final p = uri.path;
    if (p == '/api/system/capabilities') {
      return {
        'web': true,
        'backend': false,
        'database': false,
        'objectStorage': false,
        'aiHealth': false,
        'sessionInference': false,
        'faceEnrollment': false,
        'annotatedVideoOutput': false,
        'loadedModels': [],
        'mode': 'LOCAL_DEMO',
      };
    }
    if (p == '/api/students') {
      final q = (uri.queryParameters['q'] ?? '').toLowerCase();
      return copy(
        students
            .where(
              (s) => '${s['fullName']} ${s['studentCode']}'
                  .toLowerCase()
                  .contains(q),
            )
            .toList(),
      );
    }
    if (p == '/api/catalogs/class-sections') {
      return [
        {
          'id': 1,
          'code': 'HTTT-01',
          'name': 'Phân tích và thiết kế hệ thống',
          'isActive': true,
          'semester': 'HK1',
          'academicYear': '2026–2027',
        },
      ];
    }
    if (p == '/api/catalogs/rooms') {
      return [
        {'id': 1, 'code': 'A301', 'name': 'Phòng A301', 'isActive': true},
      ];
    }
    if (p == '/api/catalogs/cameras') {
      return [
        {
          'id': 1,
          'code': 'CAM01',
          'name': 'Camera lớp A301',
          'roomId': 1,
          'isActive': true,
        },
      ];
    }
    if (p == '/api/videos') {
      return [
        {
          'id': 1,
          'fileName': 'video_demo.mp4',
          'videoType': 'INPUT_UPLOAD',
          'status': 'READY',
        },
      ];
    }
    if (p == '/api/attendance-policies') {
      return [
        {
          'id': 1,
          'code': 'DEFAULT',
          'name': 'Chuyên cần mặc định',
          'presentThreshold': .8,
          'partialThreshold': .5,
          'isActive': true,
        },
      ];
    }
    if (p == '/api/sessions') {
      if (method == 'POST') {
        final id = sessions.length + 101;
        final row = session(
          id,
          'READY',
          DateTime.parse(body!['scheduledStart']),
        );
        row.addAll(body);
        sessions.insert(0, row);
        return {'id': id, 'status': 'READY'};
      }
      final status = uri.queryParameters['status'];
      return copy(
        sessions.where((s) => status == null || s['status'] == status).toList(),
      );
    }
    final parts = p.split('/').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 3 && parts[1] == 'sessions') {
      final s = sessions.firstWhere(
        (r) => r['id'] == int.tryParse(parts[2]),
        orElse: () =>
            throw const ApiException('Không có buổi học demo này.', 404),
      );
      if (parts.length == 3) return copy(s);
      switch (parts[3]) {
        case 'dashboard':
          return {
            'sessionId': s['id'],
            'status': s['status'],
            'modelReady': false,
            'cameraHealth': 'DEMO',
            'identifiedStudents': 3,
            'unknownIdentities': 1,
            'behavior': {
              'focused': .62,
              'distracted': .18,
              'sleepy': .08,
              'active': .12,
            },
            'identities': [],
            'recentAlerts': copy(alerts),
          };
        case 'start':
          s['status'] = 'RUNNING';
          break;
        case 'stop':
        case 'retry-finalize':
          s['status'] = 'COMPLETED';
          s['canOperate'] = false;
          break;
        case 'cancel':
          s['status'] = 'CANCELLED';
          s['canOperate'] = false;
          break;
      }
      return copy(s);
    }
    if (p == '/api/alerts') return copy(alerts);
    if (parts.length == 4 && parts[1] == 'alerts') {
      final a = alerts.firstWhere((r) => r['id'] == int.parse(parts[2]));
      a['status'] = {
        'ack': 'ACK',
        'close': 'CLOSED',
        'reopen': 'OPEN',
      }[parts[3]];
      a['lecturerNote'] = body?['note'];
      return null;
    }
    if (parts.length >= 4 &&
        parts[1] == 'students' &&
        parts[3] == 'face-enrollments') {
      final studentId = int.parse(parts[2]);
      final list = enrollments.putIfAbsent(studentId, () => []);
      if (parts.length == 4) {
        if (method == 'POST') {
          list.insert(0, {
            'id': list.length + 1,
            'studentId': studentId,
            'status': 'IN_PROGRESS',
            'uploadedImageCount': 0,
            'passedImageCount': 0,
            'requiredPoses': 'FRONT,LEFT,RIGHT',
            'images': [],
          });
        }
        return method == 'POST' ? copy(list.first) : copy(list);
      }
      final e = list.firstWhere((r) => r['id'] == int.parse(parts[4]));
      if (parts.length == 5) {
        return {'enrollment': copy(e), 'images': copy(e['images'])};
      }
      if (parts[5] == 'submit') {
        if ((e['uploadedImageCount'] as int) < 6 ||
            !{'FRONT', 'LEFT', 'RIGHT'}.every(
              (pose) =>
                  rows(e['images'])
                      .any((image) => image['capturePose'] == pose),
            )) {
          throw const ApiException(
            'Cần ít nhất 6 ảnh và đủ góc chính diện, trái, phải.',
          );
        }
        e['status'] = 'PENDING_AI';
        return null;
      }
      throw const ApiException(
        'Chế độ local chưa có model AI. Hồ sơ ở trạng thái chờ.',
      );
    }
    if (parts.length >= 4 && parts[1] == 'history') {
      return copy(
        students
            .map(
              (s) => {
                'studentCode': s['studentCode'],
                'fullName': s['fullName'],
                'behaviorLabel': 'FOCUSED',
                'observationQuality': .9,
                'source': 'Dữ liệu minh họa local',
              },
            )
            .toList(),
      );
    }
    if (parts.length >= 4 && parts[1] == 'reports') {
      return {
        'summary': {
          'source': 'Dữ liệu minh họa local, không phải kết quả AI thật',
          'focusedRatio': .62,
          'distractedRatio': .18,
          'sleepyRatio': .08,
          'activeRatio': .12,
          'alertCount': 1,
        },
        'attendance': students
            .map(
              (s) => {
                'studentCode': s['studentCode'],
                'fullName': s['fullName'],
                'attendanceStatus': 'PRESENT',
                'presenceRatio': .92,
              },
            )
            .toList(),
        'autoComment': 'Minh họa giao diện báo cáo. Nhận xét thực tế sẽ do backend cung cấp.',
      };
    }
    if (p == '/api/auth/change-password') {
      throw const ApiException('Chế độ demo không có mật khẩu để thay đổi.');
    }
    throw const ApiException('Chức năng này cần kết nối backend thật.');
  }

  @override
  Future<void> upload(
    String path,
    String filePath, {
    Map<String, String> fields = const {},
  }) async {
    final parts = path.split('/');
    final list = enrollments[int.parse(parts[3])]!;
    final e = list.firstWhere((r) => r['id'] == int.parse(parts[5]));
    (e['images'] as List).add({
      'id': (e['uploadedImageCount'] as int) + 1,
      'originalFileName': filePath.split(RegExp(r'[/\\]')).last,
      'capturePose': fields['capturePose'],
      'qualityStatus': 'PENDING',
      'note': 'Ảnh demo chỉ lưu tên/góc trong bộ nhớ, không tải lên máy chủ.',
    });
    e['uploadedImageCount'] = (e['uploadedImageCount'] as int) + 1;
  }

  @override
  Future<List<int>> download(String path) async => throw const ApiException(
    'Xuất PDF/Excel cần backend thật. Chế độ local chỉ xem báo cáo minh họa.',
  );
}
