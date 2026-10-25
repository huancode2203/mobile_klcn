import 'package:khoaluancunhan/models/user_model.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:khoaluancunhan/services/api_service.dart';
import 'package:khoaluancunhan/core/errors/api_exception.dart';
import 'package:khoaluancunhan/app.dart';
import 'package:khoaluancunhan/screens/home/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  test('Server URL validation and normalization', () {
    expect(
      ApiService.normalizeUrl(' http://10.0.2.2:8080/api/ '),
      'http://10.0.2.2:8080',
    );
    for (final value in [
      'localhost:8080',
      '',
      'file:///test',
      'https://server?token=x',
    ]) {
      expect(
        () => ApiService.normalizeUrl(value),
        throwsA(isA<ApiException>()),
      );
    }
  });
  test(
    'LoginScreen sends contract and fetches permissions with bearer token',
    () async {
      final api = ApiService(
        client: MockClient((request) async {
          if (request.url.path.endsWith('/login')) {
            expect(jsonDecode(request.body), {
              'userName': 'lecturer',
              'password': 'secret',
            });
            expect(request.headers['Authorization'], isNull);
            return http.Response(
              jsonEncode({'accessToken': 'test-token'}),
              200,
            );
          }
          expect(request.headers['Authorization'], 'Bearer test-token');
          return http.Response(
            jsonEncode({
              'fullName': 'Lecturer',
              'roles': ['LECTURER'],
              'permissions': ['FACE_ENROLL_SCOPE'],
            }),
            200,
          );
        }),
      );
      await api.login('https://server', ' lecturer ', 'secret');
      expect(api.signedIn, isTrue);
      expect(api.permits('FACE_ENROLL_SCOPE'), isTrue);
      expect(api.admin, isFalse);
      api.client.close();
    },
  );
  test('401 clears token and user; 403 preserves authentication', () async {
    var status = 403;
    final api = ApiService(
      client: MockClient((_) async => http.Response('{}', status)),
    );
    api.baseUrl = 'https://server';
    api.token = 'token';
    api.user = UserModel.fromJson({
      'roles': ['LECTURER'],
    });
    await expectLater(
      api.get('/api/sessions'),
      throwsA(isA<ApiException>().having((e) => e.status, 'status', 403)),
    );
    expect(api.signedIn, isTrue);
    status = 401;
    await expectLater(
      api.get('/api/sessions'),
      throwsA(isA<ApiException>().having((e) => e.status, 'status', 401)),
    );
    expect(api.signedIn, isFalse);
    expect(await api.storage.read(key: 'token'), isNull);
    api.client.close();
  });
  test(
    'AI unavailable error is preserved, never converted into running state',
    () async {
      final api = ApiService(
        client: MockClient(
          (_) async => http.Response(jsonEncode('AI not ready'), 503),
        ),
      );
      api.baseUrl = 'https://server';
      await expectLater(
        api.post('/api/sessions/1/start', {}),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'AI not ready',
          ),
        ),
      );
      api.client.close();
    },
  );
  testWidgets('LoginScreen fits narrow phone and validates required fields', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = ApiService();
    await tester.pumpWidget(HtbamApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('HTBAM'), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    expect(find.text('Nhập tài khoản'), findsOneWidget);
    expect(find.text('Nhập mật khẩu'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    api.client.close();
    api.dispose();
  });
  testWidgets('Admin navigation does not expose academic screens', (
    tester,
  ) async {
    final api = ApiService();
    api.token = 'token';
    api.user = UserModel.fromJson({
      'fullName': 'Admin',
      'roles': ['ADMIN'],
    });
    await tester.pumpWidget(MaterialApp(home: HomeScreen(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('Tài khoản người dùng'), findsOneWidget);
    expect(find.text('Sinh viên'), findsNothing);
    expect(find.text('Buổi học'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    api.client.close();
    api.dispose();
  });
}
