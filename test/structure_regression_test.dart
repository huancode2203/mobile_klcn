import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluancunhan/app.dart';
import 'package:khoaluancunhan/models/face_enrollment_model.dart';
import 'package:khoaluancunhan/models/session_model.dart';
import 'package:khoaluancunhan/screens/auth/login_screen.dart';
import 'package:khoaluancunhan/screens/home/home_screen.dart';
import 'package:khoaluancunhan/services/demo/demo_api_service.dart';
import 'package:khoaluancunhan/services/session_service.dart';
import 'package:khoaluancunhan/services/student_service.dart';
import 'package:khoaluancunhan/services/alert_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  test('Domain services decode demo contracts into usable models', () async {
    final api = DemoApiService();
    await api.restore();
    final students = await StudentService(api).list(query: 'SV2024001');
    expect(students.single.id, 1);
    final sessions = await SessionService(api).list(status: 'RUNNING');
    expect(sessions.single.isRunning, isTrue);
    expect(sessions.single.scheduledStart, isNotNull);
    await AlertService(api).action(1, 'close', note: 'Đã xử lý');
    final alerts = await AlertService(api).list();
    expect(alerts.single.status, 'CLOSED');
    expect(alerts.single.lecturerNote, 'Đã xử lý');
    api.client.close();
    api.dispose();
  });
  test(
    'Optional model fields and old face count contract remain supported',
    () {
      final session = SessionModel.fromJson({
        'id': 1,
        'classSectionId': 2,
        'status': 'READY',
      });
      expect(session.scheduledStart, isNull);
      expect(session.canOperate, isFalse);
      final face = FaceEnrollmentModel.fromJson({
        'id': 1,
        'status': 'NEEDS_RETAKE',
        'acceptedImageCount': 4,
      });
      expect(face.passedImageCount, 4);
      expect(face.canUpload, isTrue);
    },
  );
  testWidgets(
    'Switching between local and server modes resets app navigation',
    (tester) async {
      await tester.pumpWidget(const HtbamApp());
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      final demoButton = find.text('Trải nghiệm local · không cần máy chủ');
      await tester.ensureVisible(demoButton);
      await tester.tap(demoButton);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.person_outline).last);
      await tester.pumpAndSettle();
      final connectButton = find.text('Kết nối backend thật');
      await tester.ensureVisible(connectButton);
      await tester.tap(connectButton);
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
