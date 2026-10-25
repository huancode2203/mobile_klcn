import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/theme/app_colors.dart';

class NoticeBanner extends StatelessWidget {
  final String text;
  final bool error;
  const NoticeBanner(this.text, {super.key, this.error = false});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: error ? const Color(0xFFFFEDEC) : const Color(0xFFE4F3F3),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: error ? Colors.red.shade800 : brand,
        height: 1.45,
      ),
    ),
  );
}
