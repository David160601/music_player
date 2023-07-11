import 'package:flutter/material.dart';
import 'package:youtube_api/youtube_api.dart';

class MusicCard extends StatelessWidget {
  final YouTubeVideo video;

  const MusicCard({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(children: [
        Expanded(
            child: Row(
          children: [
            video.thumbnail.medium.url != null
                ? Image(
                    height: 70,
                    width: 130,
                    fit: BoxFit.cover,
                    image: NetworkImage(video.thumbnail.medium.url ?? ""))
                : Container(),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                child: Text(
              video.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )),
          ],
        )),
        IconButton(onPressed: () {}, icon: const Icon(Icons.download))
      ]),
    );
  }
}
