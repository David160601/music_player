import 'package:music_player/constant/youtube.dart';
import 'package:youtube_api/youtube_api.dart';

class YoutubeService {
  static Future<List<YouTubeVideo>> getVidoes(String query) async {
    try {
      List<YouTubeVideo> videoResult = [];
      int max = 10;
      String type = "video";
      YoutubeAPI ytApi = YoutubeAPI(youtubeApiKey, maxResults: max, type: type);
      videoResult = await ytApi.search(query);
      return videoResult;
    } catch (e) {
      throw Exception("error fetching video");
    }
  }
}
