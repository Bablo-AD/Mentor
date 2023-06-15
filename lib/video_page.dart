import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPage extends StatelessWidget {
  final String videoId;

  VideoPage({required this.videoId});

  @override
  Widget build(BuildContext context) {
    final youtubePlayerController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mentor',
          style: TextStyle(color: Colors.green),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: YoutubePlayer(
          controller: youtubePlayerController,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.green,
        ),
      ),
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
