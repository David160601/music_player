import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late List<DownloadTask> _runningTasks = [];
  bool loading = false;
  @override
  void initState() {
    super.initState();
    _getTasks();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getTasks() async {
    setState(() {
      loading = true;
    });
    final tasks = await FlutterDownloader.loadTasks();
    final runningTasks = tasks!
        .where((task) => task.status == DownloadTaskStatus.running)
        .toList();
    setState(() {
      _runningTasks = runningTasks;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            itemCount: _runningTasks.length,
            itemBuilder: (context, index) {
              final task = _runningTasks[index];
              return ListTile(
                  title: Text(task.filename ?? "Not available"),
                  subtitle: Text('${task.progress}%'),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.cancel),
                  ));
            },
          );
  }
}
