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
  TextEditingController query = TextEditingController();
  List<YouTubeVideo> videos = [];
  bool loading = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  Future handleChange() async {
    setState(() {
      loading = true;
    });
    try {
      videos = await YoutubeService.getVidoes(query.text);
    } catch (e) {
      setState(() {
        loading = false;
      });
      throw Exception("error fetching video");
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: body(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    query.dispose();
  }

  PreferredSizeWidget appbar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: AppBar(
        title: TextField(
            controller: query,
            onChanged: (value) {
              setState(() {
                loading = true;
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
    return loading
        ? const Center(child: CircularProgressIndicator())
        : videos.isEmpty && query.text.isNotEmpty
            ? const Center(
                child: Text("Result not foumd"),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                    key: _listKey,
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      return MusicCard(
                        video: videos[index],
                      );
                    }),
              );
  }
}
