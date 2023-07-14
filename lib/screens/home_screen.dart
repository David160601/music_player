import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:music_player/screens/music_player_screen.dart';
import 'package:path/path.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<File> _musicFiles = [];
  late List<DownloadTask> _runningTasks = [];
  bool _loading = false;
  final _audioPlayer = AudioPlayer();
  File? playedMusic;
  Future<void> handlePlayMusic(File file) async {
    if (playedMusic == null) {
      await _audioPlayer.play(UrlSource(file.path));
    } else {
      if (file != playedMusic) {
        await _audioPlayer.pause();
        await _audioPlayer.play(UrlSource(file.path));
      }
    }
    setState(() {
      playedMusic = file;
    });
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> getRunningTasks() async {
    final tasks = await FlutterDownloader.loadTasks();
    final runningTasks = tasks!
        .where((task) => task.status == DownloadTaskStatus.running)
        .toList();
    _runningTasks = runningTasks;
  }

  bool checkRunningTasks(String fileName) {
    bool isRunning = false;
    for (var item in _runningTasks) {
      if (item.filename == fileName) {
        isRunning = true;
      }
    }
    return isRunning;
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
          !checkRunningTasks(basename(file.path))) {
        mp3Files.add(file);
      }
    }

    setState(() {
      _musicFiles = mp3Files;
    });
  }

  Future<void> getMusics() async {
    setState(() {
      _loading = true;
    });
    await getRunningTasks();
    await getMusicFiles();
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getMusics();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : _musicFiles.isEmpty
            ? const Center(
                child: Text("No music data"),
              )
            : listOfMusics();
  }

  ListView listOfMusics() {
    return ListView.separated(
        separatorBuilder: (BuildContext context, int index) => const Divider(
              color: Colors.red,
            ),
        itemCount: _musicFiles.length,
        itemBuilder: (context, index) {
          String fileName = basename(_musicFiles[index].path);
          return ListTile(
            trailing: IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MusicPlayerScreen(
                    music: _musicFiles[index],
                    audioPlayer: _audioPlayer,
                    handlePlayMusic: handlePlayMusic,
                  );
                }));
              },
              icon: const Icon(Icons.play_arrow),
            ),
            title: Row(
              children: [
                const Icon(Icons.music_note),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Text(
                    fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        });
  }
}
