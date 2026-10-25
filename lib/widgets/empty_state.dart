import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String text;
  const EmptyState(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 20),
    child: Column(
      children: [
        const Icon(Icons.inbox_outlined, size: 52, color: Colors.blueGrey),
        const SizedBox(height: 16),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.blueGrey),
        ),
      ],
    ),
  );
}
