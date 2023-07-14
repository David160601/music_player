import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late List<DownloadTask> _runningTasks = [];
  bool _loading = false;
  final Map<String, int> _downloadProgress = {};
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    _getTasks();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus(data[1]);
      int progress = data[2];
      setState(() {
        _downloadProgress[id] = progress;
      });
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  Future<void> _getTasks() async {
    setState(() {
      _loading = true;
    });
    final tasks = await FlutterDownloader.loadTasks();
    final runningTasks = tasks!.where((task) {
      if (task.status == DownloadTaskStatus.running) {
        _downloadProgress[task.taskId] = task.progress;
      }
      return task.status == DownloadTaskStatus.running;
    }).toList();
    setState(() {
      _runningTasks = runningTasks;
      _loading = false;
    });
  }

  void removeTask(DownloadTask task) {
    try {
      FlutterDownloader.remove(taskId: task.taskId);
      setState(() {
        _runningTasks.remove(task);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : _runningTasks.isEmpty
            ? const Center(
                child: Text("No download at the moment"),
              )
            : ListView.separated(
                itemCount: _runningTasks.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemBuilder: (context, index) {
                  final task = _runningTasks[index];
                  return ListTile(
                      title: Text(
                        task.filename ?? "Not available",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('${_downloadProgress[task.taskId]}%'),
                      trailing: _downloadProgress[task.taskId]! < 100
                          ? IconButton(
                              onPressed: () {
                                removeTask(_runningTasks[index]);
                              },
                              icon: const Icon(Icons.cancel),
                            )
                          : Container());
                },
              );
  }
}
