import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:music_player/models/download_task.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  List<RunningDownloadTask> _downloadTasks = [];
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    _getTasks();
  }

  Future<void> _getTasks() async {
    setState(() {
      _loading = true;
    });
    await FileDownloader().trackTasks();
    final records = await FileDownloader().database.allRecords();
    for (dynamic record in records) {
      final test = await FileDownloader().database.recordForId(record.taskId);
      if (record.status == TaskStatus.running) {
        setState(() {
          double recordProgress = record.progress * 100;
          _downloadTasks.add(RunningDownloadTask(
              taskId: record.taskId,
              progress: recordProgress.floor(),
              filename: test?.task.filename ?? " "));
        });
      }
    }

    FileDownloader().registerCallbacks(
      taskProgressCallback: (update) {
        List<RunningDownloadTask> newDownloadTasks = _downloadTasks.map((e) {
          RunningDownloadTask downloadTask = e;
          if (update.task.taskId == downloadTask.taskId) {
            double progress = update.progress * 100;
            downloadTask.progress = progress.floor();
          }
          return downloadTask;
        }).toList();
        setState(() {
          _downloadTasks = newDownloadTasks;
        });
      },
    );
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.separated(
            itemCount: _downloadTasks.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemBuilder: (context, index) {
              final task = _downloadTasks[index];
              return ListTile(
                  title: Text(
                    task.filename ?? "Not available",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('${_downloadTasks[index].progress}%'),
                  trailing: _downloadTasks[index].progress < 100
                      ? IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.cancel),
                        )
                      : Container());
            },
          );
  }
}
