import 'dart:io';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<File> musicFiles = [];
  late List<DownloadTask> _runningTasks = [];
  @override
  void initState() {
    super.initState();
    getTasks();
    getMusicFiles();
  }

  Future<void> getTasks() async {
    final tasks = await FlutterDownloader.loadTasks();
    final runningTasks = tasks!
        .where((task) => task.status == DownloadTaskStatus.running)
        .toList();
    _runningTasks = runningTasks;
  }

  Future<void> getMusicFiles() async {
    String musicPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_MUSIC);
    Directory musicDir = Directory(musicPath);
    List<FileSystemEntity> files = musicDir.listSync();

    List<File> mp3Files = [];
    for (FileSystemEntity file in files) {
      if (file is File &&
          file.path.endsWith('.mp3') &&
          !checkRunningFile(basename(file.path))) {
        mp3Files.add(file);
      }
    }

    setState(() {
      musicFiles = mp3Files;
    });
  }

  bool checkRunningFile(String fileName) {
    bool isRunning = false;
    for (var item in _runningTasks) {
      if (item.filename == fileName) {
        isRunning = true;
      }
    }
    return isRunning;
  }

  @override
  Widget build(BuildContext context) {
    return musicFiles.isEmpty
        ? const Center(
            child: Text("No music data"),
          )
        : ListView.separated(
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemCount: musicFiles.length,
            itemBuilder: (context, index) {
              String fileName = basename(musicFiles[index].path);
              return ListTile(
                trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                ),
                title: Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            });
  }
}
