import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/theme/app_colors.dart';
import 'package:khoaluancunhan/core/utils/status_labels.dart';

class StatusBadge extends StatelessWidget {
  final dynamic value;
  const StatusBadge(this.value, {super.key});
  @override
  Widget build(BuildContext context) {
    final color = ['FAILED', 'FINALIZE_FAILED', 'OPEN'].contains(value)
        ? Colors.deepOrange
        : ['RUNNING', 'READY', 'COMPLETED'].contains(value)
        ? brand
        : Colors.blueGrey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label(value),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
