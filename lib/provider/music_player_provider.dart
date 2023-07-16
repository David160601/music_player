import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicPlayer {
  AudioPlayer audioPlayer = AudioPlayer();
  File? playedMusic;
  MusicPlayer();
}

class MusicPlayerNotifier extends StateNotifier<MusicPlayer> {
  MusicPlayerNotifier() : super(MusicPlayer());
  Future<Duration> handlePlayMusic(File file) async {
    if (state.playedMusic != file) {
      await state.audioPlayer.pause();
    }
    await state.audioPlayer.play(UrlSource(file.path));
    state.playedMusic = file;
    state.audioPlayer.setReleaseMode(ReleaseMode.loop);
    Duration duration = await state.audioPlayer.getDuration() ?? Duration.zero;
    return duration;
  }

  Future<void> handleChangePosition(double value) async {
    await state.audioPlayer.seek(Duration(seconds: value.toInt()));
  }
}

final musicPlayerProvider =
    StateNotifierProvider<MusicPlayerNotifier, MusicPlayer>((ref) {
  return MusicPlayerNotifier();
});
