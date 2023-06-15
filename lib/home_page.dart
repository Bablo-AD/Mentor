import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'video_page.dart';
import 'settings_page.dart';
import 'journal_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MentorPage extends StatefulWidget {
  const MentorPage({super.key});

  @override
  _MentorPageState createState() => _MentorPageState();
}

class _MentorPageState extends State<MentorPage> {
  final _storage = const FlutterSecureStorage();
  final interestController = TextEditingController();
  String interest = '';
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  String result = '';
  List<Video> videos = [];
  bool isLoading = false;
  int _selectedIndex = 0;
  void _emulateRequest() async {
    setState(() {
      isLoading = true;
      videos.clear(); // Clear previous videos
    });
    // Retrieve the saved settings
    String? habiticaUserId = await _storage.read(key: 'habitica_user_id');
    String? habiticaApiKey = await _storage.read(key: 'habitica_api_key');
    String? serverurl = await _storage.read(key: 'server_url');

    final QuerySnapshot orderthing = await FirebaseFirestore.instance
        .collection('journals')
        .where('userId', isEqualTo: userId)
        .orderBy('title', descending: true)
        .get();
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

    // Prepare the data to send in the request
    Map<String, String> data = {
      'habitica_user_id': habiticaUserId.toString(),
      'habitica_api_key': habiticaApiKey.toString(),
      'goal': interest,
      'journal': journalDataList.toString(),
    };

    try {
      var __response = await http.post(
        Uri.parse(serverurl.toString()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (__response.statusCode == 200) {
        var completionMemory = jsonDecode(__response.body);
        result = completionMemory['completion'];
        completionMemory.remove('completion');
        Map<String, dynamic> responseData = completionMemory;

        final videoList = (responseData)
            .entries
            .map((entry) => Video.fromJson({
                  'title': entry.key,
                  'videoId': entry.value,
                }))
            .toList();
        if (this.mounted) {
          setState(() {
            isLoading = false;
            videos = videoList;
            result = result;
          });
        }
      } else {
        if (this.mounted) {
          setState(() {
            result =
                'Request failed with status code ${__response.statusCode}: ${__response.body}';
          });
        }
      }
    } catch (error) {
      if (this.mounted) {
        setState(() {
          result = 'An error occured ${error}';
        });
      }
    } finally {
      if (this.mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _emulateRequest();
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
            title: const Text('Mentor',
                style: TextStyle(color: Color.fromARGB(255, 50, 204, 102))),
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
                            color: Color.fromARGB(255, 50, 204, 102),
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
                        color: Color.fromARGB(255, 50, 204, 102),
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
                              "Mentor: ",
                              style: const TextStyle(
                                color: Color.fromARGB(255, 50, 204, 102),
                              ),
                            ),
                            subtitle: Text(result,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 50, 204, 102),
                                )))),
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
                                color: Color.fromARGB(255, 50, 204, 102),
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
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notes),
                label: 'Journal',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color.fromARGB(255, 50, 204, 102),
            unselectedItemColor: Colors.white,
            backgroundColor: Colors.black,
            onTap: (int index) {
              switch (index) {
                case 0:
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MentorPage()));
                  break;
                case 1:
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => JournalPage()));
                  break;
                case 2:
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SettingsPage()));
                  break;
              }
            },
          ),
        ));
  }
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
