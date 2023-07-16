import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:music_player/screens/music_player_screen.dart';
import 'package:path/path.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<File> _musicFiles = [];
  // late List<DownloadTask> _runningTasks = [];
  bool _loading = false;

  Future<void> getMusicFiles() async {
    Directory musicDir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = musicDir.listSync();
    List<File> mp3Files = [];
    for (FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.mp3')) {
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
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: _musicFiles.length,
        itemBuilder: (context, index) {
          String fileName = basename(_musicFiles[index].path);
          return ListTile(
            trailing: IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MusicPlayerScreen(
                    music: _musicFiles[index],
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
