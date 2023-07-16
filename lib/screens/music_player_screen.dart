import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/provider/music_player_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

class MusicPlayerScreen extends ConsumerStatefulWidget {
  final File music;

  const MusicPlayerScreen({
    super.key,
    required this.music,
  });

  @override
  ConsumerState<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends ConsumerState<MusicPlayerScreen> {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  String formatDuration(Duration duration) {
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    start();
  }

  Future start() async {
    setState(() {
      _isPlaying = true;
    });
    Duration duration = await ref
        .read(musicPlayerProvider.notifier)
        .handlePlayMusic(widget.music);
    setState(() {
      _duration = duration;
    });
    final AudioPlayer audioPlayer = ref.watch(musicPlayerProvider).audioPlayer;
    audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        _position = event;
      });
    });
  }

  Future handlePauseResume() async {
    if (_isPlaying) {
      await ref.watch(musicPlayerProvider).audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await ref.watch(musicPlayerProvider).audioPlayer.resume();
      setState(() {
        _isPlaying = true;
      });
    }
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
            ref.read(musicPlayerProvider.notifier).handleChangePosition(value);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatDuration(_position)),
              Text(formatDuration(_duration)),
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
                    ref.read(musicPlayerProvider.notifier).handleChangePosition(
                        _position.inSeconds.toDouble() - 10);
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
                    onPressed: handlePauseResume,
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow)),
              ),
              const SizedBox(
                width: 20,
              ),
              IconButton(
                  splashRadius: 25,
                  onPressed: () {
                    ref.read(musicPlayerProvider.notifier).handleChangePosition(
                        _position.inSeconds.toDouble() + 10);
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
