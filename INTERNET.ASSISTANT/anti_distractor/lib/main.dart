import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class Video {
  final String title;
  final String videoId;

  Video({required this.title, required this.videoId});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['title'],
      videoId: json['videoId'],
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
  late SharedPreferences _prefs;
  final journalController = TextEditingController();

  String journal = '';
  String interest = '';
  List<Video> videos = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadJournalFromPrefs();
  }

  Future<void> _loadJournalFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      journal = _prefs.getString('journal') ?? '';
      journalController.text = journal;
    });
  }

  Future<void> _saveJournalToPrefs(String value) async {
    setState(() {
      journal = value;
    });
    await _prefs.setString('journal', value);
  }

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
                  'videoId': entry.value,
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
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('An error occurred:'),
              SizedBox(height: 8.0),
              Text(error.toString()), // Display the error message
            ],
          ),
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
              controller: journalController,
              decoration: InputDecoration(labelText: 'Journal'),
              onChanged: (value) {
                _saveJournalToPrefs(value);
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
                    final video = videos[index];
                    final youtubePlayerController = YoutubePlayerController(
                      initialVideoId: video.videoId,
                      flags: YoutubePlayerFlags(
                        autoPlay: false,
                      ),
                    );

                    return ListTile(
                      onTap: () {
                        _launchURL(video.videoId);
                      },
                      title: YoutubePlayer(
                        controller: youtubePlayerController,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.amber,
                      ),
                      subtitle: Text(video.title),
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

_launchURL(String videoId) async {
  final url = 'https://www.youtube.com/watch?v=$videoId';
  Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $url');
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// void main() => runApp(MyApp());

// class Video {
//   final String title;
//   final String videoId;

//   Video({required this.title, required this.videoId});

//   factory Video.fromJson(Map<String, dynamic> json) {
//     return Video(
//       title: json['title'],
//       videoId: json['videoId'],
//     );
//   }
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Anti Distractor',
//       theme: ThemeData(
//         primarySwatch: Colors.teal,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
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
//   bool isLoading = false;

//   Future<void> fetchVideos() async {
//     if (interest.isEmpty || journal.isEmpty) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Error'),
//           content: Text('Please enter both Interest and Short Journal.'),
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
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     final url = 'http://192.168.0.111:5000/youtube_recommend';

//     final body = {
//       'interest': interest,
//       'journal': journal,
//     };

//     try {
//       final response = await http.put(Uri.parse(url), body: body);

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);

//         final videoList = (responseData as Map<String, dynamic>)
//             .entries
//             .map((entry) => Video.fromJson({
//                   'title': entry.key,
//                   'videoId': entry.value,
//                 }))
//             .toList();

//         setState(() {
//           videos = videoList;
//           isLoading = false;
//         });
//       } else {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text('Error'),
//             content: Text('Failed to fetch videos.'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           ),
//         );

//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (error) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Error'),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('An error occurred:'),
//               SizedBox(height: 8.0),
//               Text(error.toString()),
//             ],
//           ),
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

//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Anti Distractor'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               decoration: InputDecoration(labelText: 'Interest'),
//               onChanged: (value) {
//                 setState(() {
//                   interest = value;
//                 });
//               },
//             ),
//             SizedBox(height: 16.0),
//             TextField(
//               decoration: InputDecoration(labelText: 'Journal'),
//               onChanged: (value) {
//                 setState(() {
//                   journal = value;
//                 });
//               },
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: isLoading ? null : fetchVideos,
//               child: isLoading
//                   ? CircularProgressIndicator()
//                   : Text('Fetch Videos'),
//             ),
//             SizedBox(height: 16.0),
//             if (videos.isNotEmpty)
//               Expanded(
//                 child: ListView.separated(
//                   itemCount: videos.length,
//                   separatorBuilder: (context, index) => Divider(),
//                   itemBuilder: (context, index) {
//                     final video = videos[index];
//                     final youtubePlayerController = YoutubePlayerController(
//                       initialVideoId: video.videoId,
//                       flags: YoutubePlayerFlags(
//                         autoPlay: false,
//                       ),
//                     );

//                     return ListTile(
//                       onTap: () {
//                         _launchURL(
//                             'https://www.youtube.com/watch?v=${video.videoId}');
//                       },
//                       title: YoutubePlayer(
//                         controller: youtubePlayerController,
//                         showVideoProgressIndicator: true,
//                         progressIndicatorColor: Colors.amber,
//                       ),
//                       subtitle: Text(video.title),
//                     );
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
// // import 'package:url_launcher/url_launcher.dart';

// // void main() => runApp(MyApp());

// // class Video {
// //   final String title;
// //   final String link;

// //   Video({required this.title, required this.link});

// //   factory Video.fromJson(Map<String, dynamic> json) {
// //     return Video(
// //       title: json['title'],
// //       link: json['link'],
// //     );
// //   }
// // }

// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Anti Distractor',
// //       theme: ThemeData(
// //         primarySwatch: Colors.teal,
// //         visualDensity: VisualDensity.adaptivePlatformDensity,
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
// //   String journal = '';
// //   String interest = '';
// //   List<Video> videos = [];
// //   bool isLoading = false;

// //   Future<void> fetchVideos() async {
// //     if (interest.isEmpty || journal.isEmpty) {
// //       showDialog(
// //         context: context,
// //         builder: (context) => AlertDialog(
// //           title: Text('Error'),
// //           content: Text('Please enter both Interest and Short Journal.'),
// //           actions: [
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.pop(context);
// //               },
// //               child: Text('OK'),
// //             ),
// //           ],
// //         ),
// //       );
// //       return;
// //     }

// //     setState(() {
// //       isLoading = true;
// //     });

// //     final url = 'http://192.168.0.111:5000/youtube_recommend';

// //     final body = {
// //       'interest': interest,
// //       'journal': journal,
// //     };

// //     try {
// //       final response = await http.put(Uri.parse(url), body: body);

// //       if (response.statusCode == 200) {
// //         final responseData = jsonDecode(response.body);

// //         final videoList = (responseData as Map<String, dynamic>)
// //             .entries
// //             .map((entry) => Video.fromJson({
// //                   'title': entry.key,
// //                   'link': entry.value,
// //                 }))
// //             .toList();

// //         setState(() {
// //           videos = videoList;
// //           isLoading = false;
// //         });
// //       } else {
// //         showDialog(
// //           context: context,
// //           builder: (context) => AlertDialog(
// //             title: Text('Error'),
// //             content: Text('Failed to fetch videos.'),
// //             actions: [
// //               TextButton(
// //                 onPressed: () {
// //                   Navigator.pop(context);
// //                 },
// //                 child: Text('OK'),
// //               ),
// //             ],
// //           ),
// //         );

// //         setState(() {
// //           isLoading = false;
// //         });
// //       }
// //     } catch (error) {
// //       showDialog(
// //         context: context,
// //         builder: (context) => AlertDialog(
// //           title: Text('Error'),
// //           content: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Text('An error occurred:'),
// //               SizedBox(height: 8.0),
// //               Text(error.toString()), // Display the error message
// //             ],
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.pop(context);
// //               },
// //               child: Text('OK'),
// //             ),
// //           ],
// //         ),
// //       );

// //       setState(() {
// //         isLoading = false;
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Anti Distractor'),
// //       ),
// //       body: Padding(
// //         padding: EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.stretch,
// //           children: [
// //             TextField(
// //               decoration: InputDecoration(labelText: 'Interest'),
// //               onChanged: (value) {
// //                 setState(() {
// //                   interest = value;
// //                 });
// //               },
// //             ),
// //             SizedBox(height: 16.0),
// //             TextField(
// //               decoration: InputDecoration(labelText: 'Journal'),
// //               onChanged: (value) {
// //                 setState(() {
// //                   journal = value;
// //                 });
// //               },
// //             ),
// //             SizedBox(height: 16.0),
// //             ElevatedButton(
// //               onPressed: isLoading ? null : fetchVideos,
// //               child: isLoading
// //                   ? CircularProgressIndicator()
// //                   : Text('Fetch Videos'),
// //             ),
// //             SizedBox(height: 16.0),
// //             if (videos.isNotEmpty)
// //               Expanded(
// //                 child: ListView.builder(
// //                   itemCount: videos.length,
// //                   itemBuilder: (context, index) {
// //                     return ListTile(
// //                       onTap: () {
// //                         _launchURL(videos[index].link);
// //                       },
// //                       title: Text(
// //                         videos[index].title,
// //                         style: TextStyle(
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                       subtitle: Text(videos[index].link),
// //                     );
// //                   },
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // _launchURL(String url) async {
// //   Uri uri = Uri.parse(url);
// //   if (!await launchUrl(uri)) {
// //     throw Exception('Could not launch $url');
// //   }
// // }
