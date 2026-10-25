import 'package:flutter/material.dart';
import 'package:khoaluancunhan/widgets/notice_banner.dart';

class AsyncDataView<T> extends StatefulWidget {
  final Future<T> Function() load;
  final Widget Function(T data) builder;
  final int revision;
  const AsyncDataView({
    super.key,
    required this.load,
    required this.builder,
    this.revision = 0,
  });
  @override
  State<AsyncDataView<T>> createState() => _AsyncDataViewState<T>();
}

class _AsyncDataViewState<T> extends State<AsyncDataView<T>> {
  late Future<T> future = widget.load();
  @override
  void didUpdateWidget(AsyncDataView<T> old) {
    super.didUpdateWidget(old);
    if (old.revision != widget.revision) future = widget.load();
  }

  Future<void> refresh() async {
    setState(() => future = widget.load());
    try {
      await future;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: refresh,
    child: FutureBuilder<T>(
      future: future,
      builder: (context, s) {
        if (s.connectionState != ConnectionState.done) {
          return ListView(
            children: const [
              SizedBox(height: 100),
              Center(child: CircularProgressIndicator()),
            ],
          );
        }
        if (s.hasError) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              NoticeBanner(s.error.toString(), error: true),
              FilledButton.tonal(
                onPressed: refresh,
                child: const Text('Thử lại'),
              ),
            ],
          );
        }
        return widget.builder(s.data as T);
      },
    ),
  );
}
