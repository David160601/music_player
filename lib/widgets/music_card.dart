import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:external_path/external_path.dart';
import 'package:background_downloader/background_downloader.dart';

class MusicCard extends StatefulWidget {
  final YouTubeVideo video;

  const MusicCard({super.key, required this.video});

  @override
  State<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool loading = false;
  Future downloadFile() async {
    try {
      setState(() {
        loading = true;
      });
      FileDownloader().configureNotification(
          running: TaskNotification('Downloading', widget.video.title),
          complete: TaskNotification('Download finished', widget.video.title),
          progressBar: true);

      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        var yt = YoutubeExplode();
        final video = await yt.videos.get(widget.video.id);
        final manifest =
            await yt.videos.streamsClient.getManifest(video.id.value);
        final audioStreamInfo = manifest.audioOnly.withHighestBitrate();
        final streamUrl = audioStreamInfo.url;

        await FileDownloader().enqueue(DownloadTask(
            url: streamUrl.toString(),
            filename: "${widget.video.title}.mp3",
            baseDirectory: BaseDirectory.applicationDocuments,
            updates: Updates.statusAndProgress));

        yt.close();
      } else {}
      setState(() {
        loading = false;
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${widget.video.title} added to download list"),
      ));
    } catch (e) {
      setState(() {
        loading = false;
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Error"),
      ));
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(children: [
        Expanded(
            child: Row(
          children: [
            if (widget.video.thumbnail.medium.url != null)
              Image(
                  height: 70,
                  width: 130,
                  fit: BoxFit.cover,
                  image: NetworkImage(widget.video.thumbnail.medium.url ?? "")),
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
        loading
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              )
            : IconButton(
                onPressed: () {
                  downloadFile();
                },
                icon: const Icon(Icons.download)),
      ]),
    );
  }
}
