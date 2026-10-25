import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/theme/app_theme.dart';
import 'package:khoaluancunhan/screens/auth/login_screen.dart';
import 'package:khoaluancunhan/screens/home/home_screen.dart';
import 'package:khoaluancunhan/services/api_service.dart';
import 'package:khoaluancunhan/services/demo/demo_api_service.dart';

class HtbamApp extends StatefulWidget {
  final ApiService? api;
  const HtbamApp({super.key, this.api});
  @override
  State<HtbamApp> createState() => _HtbamAppState();
}

class _HtbamAppState extends State<HtbamApp> {
  late ApiService api = widget.api ?? ApiService();
  late bool ownsApi = widget.api == null;
  bool loading = true;
  String? startupError;
  @override
  void initState() {
    super.initState();
    api.addListener(changed);
    restore();
  }

  void changed() {
    if (mounted) setState(() {});
  }

  Future<void> restore() async {
    try {
      await api.restore();
    } catch (e) {
      startupError = 'Không khôi phục được phiên đăng nhập: $e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void releaseApi() {
    api.removeListener(changed);
    if (ownsApi) {
      api.client.close();
      api.dispose();
    }
  }

  void switchMode(ApiService next) {
    releaseApi();
    setState(() {
      api = next;
      ownsApi = true;
      loading = true;
      startupError = null;
    });
    api.addListener(changed);
    restore();
  }

  @override
  void dispose() {
    releaseApi();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    key: ObjectKey(api),
    debugShowCheckedModeBanner: false,
    title: 'HTBAM Mobile',
    theme: AppTheme.light,
    home: loading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : api.signedIn
        ? HomeScreen(api: api, onConnectBackend: () => switchMode(ApiService()))
        : LoginScreen(
            api: api,
            initialError: startupError,
            onDemo: () => switchMode(DemoApiService()),
          ),
  );
}
