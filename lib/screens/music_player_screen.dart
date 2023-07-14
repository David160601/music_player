import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

class MusicPlayerScreen extends StatefulWidget {
  final File music;
  final AudioPlayer audioPlayer;
  Function(File file) handlePlayMusic;
  MusicPlayerScreen(
      {super.key,
      required this.music,
      required this.handlePlayMusic,
      required this.audioPlayer});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  Future<void> handleChangePosition(double value) async {
    await widget.audioPlayer.seek(Duration(seconds: value.toInt()));
  }

  String formatDuration(Duration duration) {
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    start();
    widget.audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        _duration = event;
      });
    });
    widget.audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        _isPlaying = true;
        _position = event;
      });
    });
  }

  void start() async {
    await widget.handlePlayMusic(widget.music);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(basename(widget.music.path)),
      ),
      body: Column(children: [
        const Image(
            height: 350,
            width: double.infinity,
            fit: BoxFit.cover,
            image: NetworkImage(
                "https://img.freepik.com/premium-vector/simple-music-logo-design-concept-vector_9850-3776.jpg?w=2000")),
        const SizedBox(
          height: 10,
        ),
        Text(
          textAlign: TextAlign.center,
          basename(widget.music.path),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(
          height: 10,
        ),
        Slider(
          min: 0,
          max: _duration.inSeconds.toDouble(),
          value: _position.inSeconds.toDouble(),
          onChanged: (double value) {
            handleChangePosition(value);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatDuration(_position)),
              Text(formatDuration(_duration))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    handleChangePosition(_position.inSeconds.toDouble() - 10);
                  },
                  splashRadius: 25,
                  iconSize: 50,
                  icon: const Icon(Icons.skip_previous)),
              const SizedBox(
                width: 20,
              ),
              CircleAvatar(
                radius: 40,
                child: IconButton(
                    iconSize: 40,
                    splashRadius: 45,
                    onPressed: () {
                      widget.handlePlayMusic(widget.music);
                    },
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow)),
              ),
              const SizedBox(
                width: 20,
              ),
              IconButton(
                  splashRadius: 25,
                  onPressed: () {
                    handleChangePosition(_position.inSeconds.toDouble() + 10);
                  },
                  iconSize: 50,
                  icon: const Icon(Icons.skip_next)),
            ],
          ),
        )
      ]),
    );
  }
}
