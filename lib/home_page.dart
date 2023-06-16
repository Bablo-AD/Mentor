import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'video_page.dart';
<<<<<<< Updated upstream
=======
import 'settings_page.dart';
import 'journal_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
>>>>>>> Stashed changes

class MentorPage extends StatefulWidget {
  const MentorPage({super.key});

  @override
  _MentorPageState createState() => _MentorPageState();
}

class _MentorPageState extends State<MentorPage> {
  final interestController = TextEditingController();
  String interest = '';
<<<<<<< Updated upstream
  String completion = '';
=======
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  String result = '';
  Future<void> _loadCompletionFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedCompletion = prefs.getString('completion');

    setState(() {
      result = storedCompletion ?? '';
      if (result.isEmpty || result == '') {
        print(result);
        _emulateRequest();
      }
    });
  }

>>>>>>> Stashed changes
  List<Video> videos = [];
  bool isLoading = false;

  void _emulateRequest() async {
    setState(() {
      isLoading = true;
      videos.clear(); // Clear previous videos
    });
    // Retrieve the saved settings
    String? habiticaUserId = await _storage.read(key: 'habitica_user_id');
    String? habiticaApiKey = await _storage.read(key: 'habitica_api_key');
    String? googleKeepEmail = await _storage.read(key: 'google_keep_email');
    String? serverurl = await _storage.read(key: 'server_url');
<<<<<<< Updated upstream
    String? googleKeepPassword =
        await _storage.read(key: 'google_keep_password');

    if (habiticaUserId != null &&
        habiticaApiKey != null &&
        googleKeepEmail != null &&
        googleKeepPassword != null) {
      // Prepare the data to send in the request
      Map<String, String> data = {
        'habitica_user_id': habiticaUserId,
        'habitica_api_key': habiticaApiKey,
        'email': googleKeepEmail,
        'password': googleKeepPassword,
        'goal': interest,
      };
=======
    serverurl =
        serverurl ?? 'https://prasannanrobots.pythonanywhere.com/mentor';
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('journals')
        .where('userId', isEqualTo: userId)
        .where('title',
            isGreaterThan:
                Timestamp.fromDate(DateTime.now().subtract(Duration(days: 3))))
        .get();
    List<QueryDocumentSnapshot> documents = snapshot.docs;
    List<Map<String, dynamic>> journalDataList =
        documents.map((doc) => doc.data() as Map<String, dynamic>).toList();
>>>>>>> Stashed changes

      //try {
      var response = await http.post(
        Uri.parse(serverurl
            .toString()), // Replace with the actual URL of your Flask API
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

<<<<<<< Updated upstream
      if (response.statusCode == 200) {
        var completionMemory = jsonDecode(response.body);
        completion = completionMemory['completion'];
=======
      if (__response.statusCode == 200) {
        var completionMemory = jsonDecode(__response.body);
        result = completionMemory['completion'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('completion', result);
>>>>>>> Stashed changes
        completionMemory.remove('completion');
        Map<String, dynamic> responseData = completionMemory;

        final videoList = (responseData)
            .entries
            .map((entry) => Video.fromJson({
                  'title': entry.key,
                  'videoId': entry.value,
                }))
            .toList();

        setState(() {
          isLoading = false;
          videos = videoList;
          result = completion;
        });
      } else {
        setState(() {
          result =
              'Request failed with status code ${response.statusCode}: ${response.body}';
        });
      }
      //}// catch (error) {
      // setState(() {
      //   result = 'An error occured ${error}';
      // });
      // } finally {
      //   setState(() {
      //     isLoading = false;
      //   });
    }
  }

  final _storage = const FlutterSecureStorage();
  String result = '';
  @override
  void initState() {
    super.initState();
    _loadCompletionFromSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.black,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Mentor', style: TextStyle(color: Colors.green)),
            actions: [
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  })
            ],
            backgroundColor: Colors.black,
          ),
          backgroundColor: Colors.black,
          body: SingleChildScrollView(
            // Wrap the body with SingleChildScrollView
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          autofillHints: const <String>[
                            'I want to exercise daily',
                            'I want to read daily'
                          ],
                          controller: interestController,
                          decoration: const InputDecoration(
                            hintText: 'Enter Your Goal',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 16.0,
                            backgroundColor: Color(0xFF000000),
                            color: Colors.green,
                          ),
                          onSubmitted: (value) {
                            setState(() {
                              interest = value;
                            });
                            _emulateRequest(); // Call your submission method here
                          },
                          onChanged: (value) {
                            setState(() {
                              interest = value;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: isLoading ? null : _emulateRequest,
                        icon: const Icon(Icons.search),
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  if (isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else
                    Card(
                        color: const Color.fromARGB(255, 19, 19, 19),
                        child: ListTile(
                            title: const Text(
                              "Bablo: ",
                              style: const TextStyle(color: Colors.green),
                            ),
                            subtitle: Text(result,
                                style: const TextStyle(color: Colors.green)))),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final video = videos[index];

                      return Card(
                          color: const Color.fromARGB(255, 19, 19, 19),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VideoPage(videoId: video.videoId),
                                ),
                              );
                            },
                            title: Text(
                              video.title,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ));
                    },
                  )
                ],
              ),
            ),
          ),
        ));
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

class Video {
  final String title;
  final String videoId;

  Video({required this.title, required this.videoId});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['title'] ?? '',
      videoId: json['videoId'] ?? '',
    );
  }
}
