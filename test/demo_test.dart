import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluancunhan/services/demo/demo_api_service.dart';
import 'package:khoaluancunhan/screens/home/home_screen.dart';
import 'package:khoaluancunhan/core/utils/json_utils.dart';

void main() {
  test('Local workflow mutates only the in-memory repository', () async {
    final api = DemoApiService();
    await api.restore();
    expect(api.isDemo, isTrue);
    final result = await api.post('/api/sessions', {
      'classSectionId': 1,
      'cameraId': 1,
      'roomId': 1,
      'attendancePolicyId': 1,
      'scheduledStart': DateTime.now().toIso8601String(),
      'scheduledEnd': DateTime.now()
          .add(const Duration(hours: 2))
          .toIso8601String(),
      'studentIds': <int>[],
    });
    final id = result['id'];
    await api.post('/api/sessions/$id/start', {});
    expect((await api.get('/api/sessions/$id'))['status'], 'RUNNING');
    await api.post('/api/sessions/$id/stop', {});
    expect((await api.get('/api/sessions/$id'))['status'], 'COMPLETED');
    await api.post('/api/alerts/1/ack', {'note': 'Đã xem demo'});
    expect(rows(await api.get('/api/alerts')).first['status'], 'ACK');
    expect(api.token, 'local-demo');
    api.client.close();
    api.dispose();
  });
  testWidgets('Local overview and all main tabs render at phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = DemoApiService();
    await api.restore();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: HomeScreen(api: api),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('DEMO LOCAL'), findsOneWidget);
    for (final icon in [
      Icons.calendar_month_outlined,
      Icons.groups_outlined,
      Icons.notifications_outlined,
      Icons.person_outline,
    ]) {
      await tester.tap(find.byIcon(icon).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    api.client.close();
    api.dispose();
  });
}
