String dateText(dynamic input) {
  final d = DateTime.tryParse(input?.toString() ?? '')?.toLocal();
  if (d == null) return 'Chưa có thời gian';
  String p(int n) => n.toString().padLeft(2, '0');
  return '${p(d.day)}/${p(d.month)}/${d.year} · ${p(d.hour)}:${p(d.minute)}';
}
