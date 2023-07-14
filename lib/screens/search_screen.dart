import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:music_player/services/youtube_service.dart';
import 'package:music_player/widgets/music_card.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:easy_debounce/easy_debounce.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _query = TextEditingController();
  List<YouTubeVideo> _videos = [];
  bool _loading = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  Future handleChange() async {
    setState(() {
      _loading = true;
    });
    try {
      _videos = await YoutubeService.getVidoes(_query.text);
    } catch (e) {
      setState(() {
        _loading = false;
      });
      throw Exception("error fetching video");
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _query.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: body(),
    );
  }

  PreferredSizeWidget appbar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: AppBar(
        title: TextField(
            controller: _query,
            onChanged: (value) {
              setState(() {
                _loading = true;
              });
              EasyDebounce.debounce(
                  'my-debouncer', // <-- An ID for this particular debouncer
                  const Duration(
                      milliseconds: 1000), // <-- The debounce duration
                  () => handleChange() // <-- The target method
                  );
            },
            decoration: InputDecoration(
              hintText: "Search",
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              suffixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Colors.grey), // Set your desired border color
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Colors
                        .grey), // Set the same border color as enabledBorder
              ),
            )),
      ),
    );
  }

  Widget body() {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : _videos.isEmpty && _query.text.isNotEmpty
            ? const Center(
                child: Text("Result not foumd"),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                    key: _listKey,
                    itemCount: _videos.length,
                    itemBuilder: (context, index) {
                      return MusicCard(
                        video: _videos[index],
                      );
                    }),
              );
  }
}
