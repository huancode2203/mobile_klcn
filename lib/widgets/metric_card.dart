import 'package:flutter/material.dart';
import 'package:khoaluancunhan/core/theme/app_colors.dart';

class MetricCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const MetricCard(this.title, this.value, this.icon, {super.key});
  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: brand),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          Text(title, style: const TextStyle(color: Colors.blueGrey)),
        ],
      ),
    ),
  );
}
