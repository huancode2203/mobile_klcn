import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:khoaluancunhan/core/errors/api_exception.dart';
import 'package:khoaluancunhan/core/utils/json_utils.dart';
import 'package:khoaluancunhan/models/json.dart';
import 'package:khoaluancunhan/models/user_model.dart';

class ApiService extends ChangeNotifier {
  final http.Client client;
  final FlutterSecureStorage storage;
  String baseUrl = const String.fromEnvironment('API_BASE_URL');
  String? token;
  UserModel? user;
  bool get signedIn => token != null && user != null;
  bool get isDemo => false;
  bool get admin => user?.isAdmin ?? false;
  bool get lecturer => user?.isLecturer ?? false;
  bool permits(String p) => user?.permits(p) ?? false;
  ApiService({http.Client? client, FlutterSecureStorage? storage})
    : client = client ?? http.Client(),
      storage = storage ?? const FlutterSecureStorage();
  static String normalizeUrl(String input) {
    final uri = Uri.tryParse(input.trim());
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.userInfo.isNotEmpty) {
      throw const ApiException(
        'Nhập địa chỉ hợp lệ, ví dụ https://htbam.example.edu',
      );
    }
    return input
        .trim()
        .replaceFirst(RegExp(r'/+$'), '')
        .replaceFirst(RegExp(r'/api$'), '');
  }

  Future<void> restore() async {
    baseUrl = await storage.read(key: 'server') ?? baseUrl;
    token = await storage.read(key: 'token');
    if (baseUrl.isEmpty || token == null) return;
    try {
      user = UserModel.fromJson(object(await get('/api/auth/me')));
    } on ApiException catch (e) {
      if (e.status == 401) await clear();
    }
    notifyListeners();
  }

  Future<void> login(String server, String name, String password) async {
    baseUrl = normalizeUrl(server);
    token = null;
    user = null;
    await storage.delete(key: 'token');
    final result = await post('/api/auth/login', {
      'userName': name.trim(),
      'password': password,
    });
    token = result['accessToken'] as String;
    try {
      user = UserModel.fromJson(object(await get('/api/auth/me')));
      await storage.write(key: 'server', value: baseUrl);
      await storage.write(key: 'token', value: token);
    } catch (_) {
      token = null;
      user = null;
      rethrow;
    }
    notifyListeners();
  }

  Future<void> clear() async {
    token = null;
    user = null;
    await storage.delete(key: 'token');
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await post('/api/auth/logout', {});
    } finally {
      await clear();
    }
  }

  Uri uri(String p) => Uri.parse('$baseUrl$p');
  Map<String, String> get headers => {
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  Future<dynamic> get(String p) => request('GET', p);
  Future<dynamic> post(String p, Json b) => request('POST', p, b);
  Future<dynamic> put(String p, Json b) => request('PUT', p, b);
  Future<dynamic> request(String method, String path, [Json? body]) async {
    try {
      final req = http.Request(method, uri(path))..headers.addAll(headers);
      if (body != null) {
        req.headers['Content-Type'] = 'application/json';
        req.body = jsonEncode(body);
      }
      final res = await http.Response.fromStream(
        await client.send(req).timeout(const Duration(seconds: 25)),
      ).timeout(const Duration(seconds: 25));
      return await decode(res);
    } on TimeoutException {
      throw const ApiException('Máy chủ phản hồi quá lâu. Hãy thử lại.');
    } on http.ClientException {
      throw const ApiException(
        'Không kết nối được máy chủ. Kiểm tra địa chỉ và mạng Wi-Fi/VPN.',
      );
    }
  }

  Future<dynamic> decode(http.Response res) async {
    final raw = utf8.decode(res.bodyBytes);
    dynamic body;
    try {
      body = raw.isEmpty ? null : jsonDecode(raw);
    } catch (_) {
      body = raw;
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    if (res.statusCode == 401) {
      await clear();
      throw const ApiException(
        'Phiên đăng nhập hết hạn hoặc tài khoản/mật khẩu không đúng.',
        401,
      );
    }
    String message = res.statusCode == 403
        ? 'Bạn không có quyền thực hiện thao tác này.'
        : 'Yêu cầu thất bại (${res.statusCode}).';
    if (body is Map) {
      message = (body['message'] ?? body['detail'] ?? body['title'] ?? message)
          .toString();
      if (body['errors'] is Map) {
        message = (body['errors'] as Map).values
            .expand((e) => e is List ? e : [e])
            .join('\n');
      }
    } else if (body is String && body.isNotEmpty && !body.contains('<html')) {
      message = body.length > 600 ? body.substring(0, 600) : body;
    }
    throw ApiException(message, res.statusCode);
  }

  Future<void> upload(
    String path,
    String filePath, {
    Map<String, String> fields = const {},
  }) async {
    try {
      final req = http.MultipartRequest('POST', uri(path))
        ..headers.addAll(headers)
        ..fields.addAll(fields);
      req.files.add(await http.MultipartFile.fromPath('file', filePath));
      await decode(
        await http.Response.fromStream(
          await client.send(req).timeout(const Duration(minutes: 3)),
        ).timeout(const Duration(minutes: 3)),
      );
    } on TimeoutException {
      throw const ApiException('Tải file quá lâu. Hãy thử lại.');
    } on http.ClientException {
      throw const ApiException('Không tải được file lên máy chủ.');
    }
  }

  Future<List<int>> download(String path) async {
    final r = await client
        .get(uri(path), headers: headers)
        .timeout(const Duration(seconds: 60));
    if (r.statusCode != 200) await decode(r);
    return r.bodyBytes;
  }
}
