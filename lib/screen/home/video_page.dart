import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPage extends StatefulWidget {
  final String videoId;
  final String description;

  const VideoPage({Key? key, required this.videoId, required this.description})
      : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late final YoutubePlayerController youtubePlayerController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    youtubePlayerController = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentor/Video')),
      body: YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: youtubePlayerController,
            showVideoProgressIndicator: true,
            progressIndicatorColor: const Color.fromARGB(255, 50, 204, 102),
          ),
          builder: (context, player) {
            return Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.open_in_browser,
                      color: Color.fromARGB(255, 50, 204, 102)),
                  onPressed: () {
                    _launchURL(widget.videoId);
                  },
                ),
                const SizedBox(
                  height: 2,
                ),
                // some widgets
                player,
                const SizedBox(height: 16.0),
                Text(widget.description),
                //some other widgets
              ],
            );
          }),
    );
  }

  _launchURL(String videoId) async {
    final url = 'https://www.youtube.com/watch?v=$videoId';
    Uri uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
    await launchUrl(uri);
  }
}
