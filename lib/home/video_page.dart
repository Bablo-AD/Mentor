import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPage extends StatelessWidget {
  final String videoId;
  final String description;

  const VideoPage(
      {super.key, required this.videoId, required this.description});

  @override
  Widget build(BuildContext context) {
    final youtubePlayerController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Mentor/Video')),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.open_in_browser,
                      color: Color.fromARGB(255, 50, 204, 102)),
                  onPressed: () {
                    _launchURL(videoId);
                  },
                ),
                const SizedBox(
                  height: 2,
                ),
                YoutubePlayer(
                  controller: youtubePlayerController,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor:
                      const Color.fromARGB(255, 50, 204, 102),
                ),
                const SizedBox(height: 16.0),
                Text(description),
              ])),
    );
  }
}

_launchURL(String videoId) async {
  final url = 'https://www.youtube.com/watch?v=$videoId';
  Uri uri = Uri.parse(url);
  if (!await canLaunchUrl(uri)) {
    throw Exception('Could not launch $url');
  }
  await launchUrl(uri);
}
