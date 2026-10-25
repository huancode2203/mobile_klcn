import 'package:khoaluancunhan/models/json.dart';

class UserModel {
  final int id;
  final String fullName, email, userName;
  final List<String> roles, permissions;
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.userName = '',
    this.roles = const [],
    this.permissions = const [],
  });
  factory UserModel.fromJson(Json json) => UserModel(
    id: (json['id'] as num?)?.toInt() ?? 0,
    fullName: json['fullName']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    userName: json['userName']?.toString() ?? '',
    roles: List<String>.unmodifiable(
      (json['roles'] as List? ?? []).map((e) => e.toString()),
    ),
    permissions: List<String>.unmodifiable(
      (json['permissions'] as List? ?? []).map((e) => e.toString()),
    ),
  );
  bool get isAdmin => roles.contains('ADMIN');
  bool get isLecturer => roles.contains('LECTURER');
  bool permits(String permission) => permissions.contains(permission);
}
