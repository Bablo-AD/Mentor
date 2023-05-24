import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anti Distractor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<VideoData> videos = [];
  String journal = '';
  String interest = '';

  Future<void> fetchVideo(String journal, String interest) async {
    final url =
        'http://192.168.0.111:5000/youtube_recommend'; // Replace with your actual API URL

    // Create the request payload
    final body = {
      'interest': interest,
      //if (shortJournal != null) 'short_journal': shortJournal,
      'journal': journal,
    };

    // Make the HTTP PUT request
    final response = await http.put(Uri.parse(url), body: body);

    // Parse the response JSON
    final responseData = jsonDecode(response.body);

    setState(() {
      videos = List<VideoData>.from(
          responseData.map((video) => VideoData.fromJson(video)));
    });
  }

  void callFetchVideo() {
    fetchVideo(journal, interest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anti Distractor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Journal'),
              onChanged: (value) {
                setState(() {
                  journal = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Interest'),
              onChanged: (value) {
                setState(() {
                  interest = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: callFetchVideo,
              child: Text('Fetch Video'),
            ),
            if (videos.isNotEmpty)
              Column(
                children: [
                  for (var video in videos)
                    ListTile(
                      title: Text(video.title),
                      subtitle: Text(video.link),
                    ),
                ],
              ),

            // Expanded(
            //   child: ListView.builder(
            //     itemCount: videos.length,
            //     itemBuilder: (context, index) {
            //       return ListTile(
            //         title: Text(videos[index].title),
            //         onTap: () {
            //           Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //               builder: (context) => VideoPlayerPage(videoLink: videos[index].link),
            //             ),
            //           );
            //         },
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class VideoData {
  final String title;
  final String link;

  VideoData({
    required this.title,
    required this.link,
  });

  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      title: json['title'] as String,
      link: json['link'] as String,
    );
  }
}

// class VideoPlayerPage extends StatelessWidget {
//   final String videoLink;

//   const VideoPlayerPage({Key? key, required this.videoLink}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Video Player'),
//       ),
//       body: WebView(
//         initialUrl: videoLink,
//         javascriptMode: JavascriptMode.unrestricted,
//       ),
//     );
//   }
// }


// class VideoPlayerPage extends StatefulWidget {
//   final String videoLink;

//   const VideoPlayerPage({Key? key, required this.videoLink}) : super(key: key);

//   @override
//   _VideoPlayerPageState createState() => _VideoPlayerPageState();
// }

// class _VideoPlayerPageState extends State<VideoPlayerPage> {
//   late final YoutubePlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = YoutubePlayerController(
//       initialVideoId: YoutubePlayerController.convertUrlToId(widget.videoLink)!,
//       params: YoutubePlayerParams(
//         showControls: true,
//         showFullscreenButton: true,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return YoutubePlayerIFrame(
//       controller: _controller,
//       aspectRatio: 16 / 9,
//       showControls: true,
//     );
//   }

//   @override
//   void dispose() {
//     _controller.close();
//     super.dispose();
//   }
// }