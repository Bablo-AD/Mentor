import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class Video {
  final String title;
  final String link;

  Video({required this.title, required this.link});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['title'],
      link: json['link'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anti Distractor',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
  String journal = '';
  String interest = '';
  List<Video> videos = [];
  bool isLoading = false;

  Future<void> fetchVideos() async {
    if (interest.isEmpty || journal.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter both Interest and Short Journal.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = 'http://192.168.0.111:5000/youtube_recommend';

    final body = {
      'interest': interest,
      'journal': journal,
    };

    try {
      final response = await http.put(Uri.parse(url), body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final videoList = (responseData as Map<String, dynamic>)
            .entries
            .map((entry) => Video.fromJson({
                  'title': entry.key,
                  'link': entry.value,
                }))
            .toList();

        setState(() {
          videos = videoList;
          isLoading = false;
        });
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch videos.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );

        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anti Distractor'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Interest'),
              onChanged: (value) {
                setState(() {
                  interest = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(labelText: 'Journal'),
              onChanged: (value) {
                setState(() {
                  journal = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isLoading ? null : fetchVideos,
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text('Fetch Videos'),
            ),
            SizedBox(height: 16.0),
            if (videos.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        _launchURL(videos[index].link);
                      },
                      title: Text(
                        videos[index].title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(videos[index].link),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

_launchURL(String url) async {
  Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $url');
  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/gestures.dart';
// import 'package:url_launcher/url_launcher.dart';

// void main() => runApp(MyApp());

// class Video {
//   final String title;
//   final String link;

//   Video({required this.title, required this.link});

//   factory Video.fromJson(Map<String, dynamic> json) {
//     return Video(
//       title: json['title'],
//       link: json['link'],
//     );
//   }
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Anti Distractor',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   String journal = '';
//   String interest = '';
//   List<Video> videos = [];

//   Future<void> fetchVideos() async {
//     final url = 'http://192.168.0.111:5000/youtube_recommend';

//     // Create the request body
//     final body = {
//       'interest': interest,
//       'journal': journal,
//     };

//     // Make the HTTP PUT request
//     final response = await http.put(Uri.parse(url), body: body);

//     // Check the response status code
//     if (response.statusCode == 200) {
//       // Parse the response JSON
//       final responseData = jsonDecode(response.body);

//       // Create a list of Video objects from the response data
//       final videoList = (responseData as Map<String, dynamic>)
//           .entries
//           .map((entry) => Video.fromJson({
//                 'title': entry.key,
//                 'link': entry.value,
//               }))
//           .toList();

//       setState(() {
//         videos = videoList;
//       });
//     } else {
//       // Show an error message if the request fails
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Error'),
//           content: Text('Failed to fetch videos.'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Anti Distractor'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               decoration: InputDecoration(labelText: 'Interest'),
//               onChanged: (value) {
//                 setState(() {
//                   interest = value; // Update the interest value
//                 });
//               },
//             ),
//             TextField(
//               decoration: InputDecoration(labelText: 'Short Journal'),
//               onChanged: (value) {
//                 setState(() {
//                   journal = value; // Update the short journal value
//                 });
//               },
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 fetchVideos();
//               },
//               child: Text('Fetch Videos'),
//             ),
//             if (videos.isNotEmpty)
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: videos.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                         onTap: () {
//                           _launchURL(videos[index].link);
//                         },
//                         title: Text(videos[index].title),
//                         subtitle: Text(videos[index].link));
//                   },
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// _launchURL(String url) async {
//   Uri uri = Uri.parse(url);
//   if (!await launchUrl(uri)) {
//     throw Exception('Could not launch $url');
//   }
// }

// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:webview_flutter/webview_flutter.dart';
// // import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// // void main() => runApp(MyApp());

// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Anti Distractor',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: HomePage(),
// //     );
// //   }
// // }

// // class HomePage extends StatefulWidget {
// //   @override
// //   _HomePageState createState() => _HomePageState();
// // }

// // class _HomePageState extends State<HomePage> {
// //   List<VideoData> videos = [];
// //   String journal = '';
// //   String interest = '';

// //   Future<void> fetchVideo(String journal, String interest) async {
// //     final url =
// //         'http://192.168.0.111:5000/youtube_recommend'; // Replace with your actual API URL

// //     // Create the request payload
// //     final body = {
// //       'interest': interest,
// //       //if (shortJournal != null) 'short_journal': shortJournal,
// //       'journal': journal,
// //     };

// //     // Make the HTTP PUT request
// //     final response = await http.put(Uri.parse(url), body: body);

// //     // Parse the response JSON
// //     final responseData = jsonDecode(response.body);

// //     setState(() {
// //       videos = List<VideoData>.from(
// //           responseData.map((video) => VideoData.fromJson(video)));
// //     });
// //   }

// //   void callFetchVideo() {
// //     fetchVideo(journal, interest);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Anti Distractor'),
// //       ),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             TextField(
// //               decoration: InputDecoration(labelText: 'Journal'),
// //               onChanged: (value) {
// //                 setState(() {
// //                   journal = value;
// //                 });
// //               },
// //             ),
// //             TextField(
// //               decoration: InputDecoration(labelText: 'Interest'),
// //               onChanged: (value) {
// //                 setState(() {
// //                   interest = value;
// //                 });
// //               },
// //             ),
// //             ElevatedButton(
// //               onPressed: callFetchVideo,
// //               child: Text('Fetch Video'),
// //             ),
// //             if (videos.isNotEmpty)
// //               Column(
// //                 children: [
// //                   for (var video in videos)
// //                     ListTile(
// //                       title: Text(video.title),
// //                       subtitle: Text(video.link),
// //                     ),
// //                 ],
// //               ),

// //             // Expanded(
// //             //   child: ListView.builder(
// //             //     itemCount: videos.length,
// //             //     itemBuilder: (context, index) {
// //             //       return ListTile(
// //             //         title: Text(videos[index].title),
// //             //         onTap: () {
// //             //           Navigator.push(
// //             //             context,
// //             //             MaterialPageRoute(
// //             //               builder: (context) => VideoPlayerPage(videoLink: videos[index].link),
// //             //             ),
// //             //           );
// //             //         },
// //             //       );
// //             //     },
// //             //   ),
// //             // ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class VideoData {
// //   final String title;
// //   final String link;

// //   VideoData({
// //     required this.title,
// //     required this.link,
// //   });

// //   factory VideoData.fromJson(Map<String, dynamic> json) {
// //     return VideoData(
// //       title: json['title'] as String,
// //       link: json['link'] as String,
// //     );
// //   }
// // }

// // // class VideoPlayerPage extends StatelessWidget {
// // //   final String videoLink;

// // //   const VideoPlayerPage({Key? key, required this.videoLink}) : super(key: key);

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text('Video Player'),
// // //       ),
// // //       body: WebView(
// // //         initialUrl: videoLink,
// // //         javascriptMode: JavascriptMode.unrestricted,
// // //       ),
// // //     );
// // //   }
// // // }


// // // class VideoPlayerPage extends StatefulWidget {
// // //   final String videoLink;

// // //   const VideoPlayerPage({Key? key, required this.videoLink}) : super(key: key);

// // //   @override
// // //   _VideoPlayerPageState createState() => _VideoPlayerPageState();
// // // }

// // // class _VideoPlayerPageState extends State<VideoPlayerPage> {
// // //   late final YoutubePlayerController _controller;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _controller = YoutubePlayerController(
// // //       initialVideoId: YoutubePlayerController.convertUrlToId(widget.videoLink)!,
// // //       params: YoutubePlayerParams(
// // //         showControls: true,
// // //         showFullscreenButton: true,
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return YoutubePlayerIFrame(
// // //       controller: _controller,
// // //       aspectRatio: 16 / 9,
// // //       showControls: true,
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _controller.close();
// // //     super.dispose();
// // //   }
// // // }