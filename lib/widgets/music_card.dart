import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:external_path/external_path.dart';

class MusicCard extends StatefulWidget {
  final YouTubeVideo video;
  const MusicCard({super.key, required this.video});

  @override
  State<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard> {
  var downloadProgress = 0;
  bool loading = false;
  Future downloadFile() async {
    try {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        var yt = YoutubeExplode();
        final video = await yt.videos.get(widget.video.id);
        final manifest =
            await yt.videos.streamsClient.getManifest(video.id.value);
        final audioStreamInfo = manifest.audioOnly.withHighestBitrate();
        final streamUrl = audioStreamInfo.url;
        var path = await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_MUSIC);
        await FlutterDownloader.enqueue(
            url: streamUrl.toString(),
            fileName: "${widget.video.title}.mp3",
            savedDir: path,
            allowCellular: true,
            showNotification: true,
            openFileFromNotification: true);
        await FlutterDownloader.registerCallback(downloadCallback);
        yt.close();
      } else {}
    } catch (e) {
      throw Exception(e);
    }
  }

  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus(data[1]);
      int progress = data[2];
      setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(children: [
        Expanded(
            child: Row(
          children: [
            widget.video.thumbnail.medium.url != null
                ? Image(
                    height: 70,
                    width: 130,
                    fit: BoxFit.cover,
                    image:
                        NetworkImage(widget.video.thumbnail.medium.url ?? ""))
                : Container(),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                child: Text(
              widget.video.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )),
          ],
        )),
        IconButton(
            onPressed: () {
              downloadFile();
            },
            icon: const Icon(Icons.download)),
      ]),
    );
  }
}
