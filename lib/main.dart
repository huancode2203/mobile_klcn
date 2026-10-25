import 'package:flutter/material.dart';
import 'package:khoaluancunhan/app.dart';
import 'package:khoaluancunhan/services/demo/demo_api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const localDemo = bool.fromEnvironment('LOCAL_DEMO', defaultValue: false);
  runApp(HtbamApp(api: localDemo ? DemoApiService() : null));
}
