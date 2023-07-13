import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<File> musicFiles = [];

  @override
  void initState() {
    super.initState();
    getMusicFiles();
  }

  Future<void> getMusicFiles() async {
    String musicPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_MUSIC);
    Directory musicDir = Directory(musicPath);
    List<FileSystemEntity> files = musicDir.listSync();

    List<File> mp3Files = [];
    for (FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.mp3')) {
        mp3Files.add(file);
      }
    }

    setState(() {
      musicFiles = mp3Files;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("home screen"),
    );
  }
}
