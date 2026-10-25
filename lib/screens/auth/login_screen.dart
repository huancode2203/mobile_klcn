import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/theme/app_colors.dart';
import 'package:khoaluancunhan/services/api_service.dart';
import 'package:khoaluancunhan/widgets/notice_banner.dart';

class LoginScreen extends StatefulWidget {
  final ApiService api;
  final String? initialError;
  final VoidCallback? onDemo;
  const LoginScreen({
    super.key,
    required this.api,
    this.initialError,
    this.onDemo,
  });
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final form = GlobalKey<FormState>();
  late final server = TextEditingController(text: widget.api.baseUrl);
  final name = TextEditingController(), password = TextEditingController();
  bool busy = false, hide = true;
  String? error;
  @override
  void initState() {
    super.initState();
    error = widget.initialError;
  }

  @override
  void dispose() {
    server.dispose();
    name.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.login(server.text, name.text, password.text);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: brand,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'HTBAM',
                    style: TextStyle(
                      color: ink,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const Text(
                    'Lớp học trong tầm tay',
                    style: TextStyle(
                      color: brand,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Theo dõi buổi học, sinh viên và những điều cần chú ý.',
                    style: TextStyle(color: Colors.blueGrey, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: server,
                    enabled: !busy,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ máy chủ',
                      hintText: 'http://192.168.1.10:8080',
                      prefixIcon: Icon(Icons.dns_outlined),
                    ),
                    validator: (v) {
                      try {
                        ApiService.normalizeUrl(v ?? '');
                        return null;
                      } catch (_) {
                        return 'Nhập địa chỉ http:// hoặc https:// của backend';
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Android Emulator: dùng 10.0.2.2 thay localhost. Điện thoại thật: dùng IP máy chủ cùng mạng.',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: name,
                    enabled: !busy,
                    autofillHints: const [AutofillHints.username],
                    decoration: const InputDecoration(
                      labelText: 'Tài khoản hoặc email',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Nhập tài khoản' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: password,
                    enabled: !busy,
                    obscureText: hide,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => hide = !hide),
                        icon: Icon(
                          hide
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Nhập mật khẩu' : null,
                    onFieldSubmitted: (_) {
                      if (!busy) submit();
                    },
                  ),
                  const SizedBox(height: 16),
                  if (error != null) NoticeBanner(error!, error: true),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: busy ? null : submit,
                    child: busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Đăng nhập'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Dùng tài khoản được cấp trên hệ thống HTBAM.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: busy ? null : widget.onDemo,
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Trải nghiệm local · không cần máy chủ'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
