import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'video_page.dart';
import '../settings/settings_page.dart';
import '../journal/journal_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'habitica.dart';
import 'chat_page.dart';
import 'package:usage_stats/usage_stats.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class MentorPage extends StatefulWidget {
  const MentorPage({super.key});

  @override
  _MentorPageState createState() => _MentorPageState();
}

class _MentorPageState extends State<MentorPage> {
  final _storage = const FlutterSecureStorage();
  final interestController = TextEditingController();
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  String interest = '';
  String result = '';
  bool isLoading = false;
  int _selectedIndex = 0;
  List<Video> videos = [];
  List<Messages> messages_data = [];
  String serverurl = '';

  Future<void> _loadCompletionFromSharedPreferences() async {
    final storedData = await _storage.read(key: 'completion');
    String? serverurl = await _storage.read(key: 'server_url');
    serverurl = serverurl;
    setState(() {
      result = storedData ?? '';
      if (result.isEmpty || result == '') {
        _emulateRequest();
      } else {
        __postprocessdata(storedData);
      }
    });
  }

  //Gets user's usage data
  Future<String> getUsage() async {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 3));
    String outputString = "";

    // check if permission is granted
    bool? isPermission = await UsageStats.checkUsagePermission();
    if (isPermission == true) {
      List<UsageInfo> usageStats =
          await UsageStats.queryUsageStats(startDate, endDate);
      if (usageStats.isNotEmpty) {
        for (UsageInfo appUsage in usageStats) {
          if (int.parse(appUsage.totalTimeInForeground!) > 0) {
            Duration duration = Duration(
                milliseconds:
                    int.parse(appUsage.totalTimeInForeground.toString()));
            int hours = duration.inHours;
            int minutes = duration.inMinutes.remainder(60);
            if (hours > 0 || minutes > 0) {
              outputString += 'Package name: ${appUsage.packageName} ';
              outputString +=
                  'Total time in foreground: $hours hours $minutes minutes';
              outputString += ', ';
            }
          }
        }
      }
    } else {
      showDialog(
        context:
            context, // Replace 'context' with the actual context from your app
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Permission Required'),
            content:
                Text('Please grant the usage permission to track app usage.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                  UsageStats.grantUsagePermission();
                },
              ),
            ],
          );
        },
      );
      bool? isPermission = await UsageStats.checkUsagePermission();
      if (isPermission == true) {
        List<UsageInfo> usageStats =
            await UsageStats.queryUsageStats(startDate, endDate);
        if (usageStats.isNotEmpty) {
          for (UsageInfo appUsage in usageStats) {
            if (int.parse(appUsage.totalTimeInForeground!) > 0) {
              Duration duration = Duration(
                  milliseconds:
                      int.parse(appUsage.totalTimeInForeground.toString()));
              int hours = duration.inHours;
              int minutes = duration.inMinutes.remainder(60);
              if (hours > 0 || minutes > 0) {
                outputString += 'Package name: ${appUsage.packageName}';
                outputString +=
                    'Total time in foreground: $hours hours $minutes minutes';
              }
            }
          }
        }
      }
    }
    print(outputString);
    return outputString;
  }

  void __postprocessdata(var response) {
    var completionMemory = jsonDecode(response);
    Map<String, dynamic> responseData = completionMemory['videos'];
    String Completion_Message = completionMemory['completion'].toString();
    messages_data.add(Messages(role: 'assistant', content: Completion_Message));
    final videoList = (responseData)
        .entries
        .map((entry) => Video.fromJson({
              'title': entry.key,
              'videoId': entry.value[0],
              'videoDescription': entry.value[1],
            }))
        .toList();
    if (this.mounted) {
      setState(() {
        isLoading = false;
        videos = videoList;
        result = Completion_Message;
      });
    } else {
      if (this.mounted) {
        setState(() {
          result =
              'Request failed with status code ${response.statusCode}: ${response.body}';
        });
      }
    }
  }

  void _emulateRequest() async {
    // Preparing the screen
    setState(() {
      isLoading = true;
      videos.clear(); // Clear previous videos
    });

    // Retrieve the saved settings
    String? habiticaUserId = await _storage.read(key: 'habitica_user_id');
    String? habiticaApiKey = await _storage.read(key: 'habitica_api_key');
    String? serverurl = await _storage.read(key: 'server_url');
    serverurl = serverurl;
    String phone_usage_data = '';

    //Preparing the phone usage data
    if (Platform.isAndroid) {
      String? phone_usage = await getUsage();
      phone_usage_data = phone_usage!.toString();
    }

    //Preparing Journal data
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('journals')
        .where('userId', isEqualTo: userId)
        .where('title',
            isGreaterThan:
                Timestamp.fromDate(DateTime.now().subtract(Duration(days: 3))))
        .get();
    List<QueryDocumentSnapshot> documents = snapshot.docs;
    List<Map<String, dynamic>> journalDataList = documents.map((doc) {
      // Extract the date from the Timestamp
      DateTime date = (doc['title'] as Timestamp).toDate();
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Create a new map without the userId field
      Map<String, dynamic> newData =
          Map.from(doc.data() as Map<dynamic, dynamic>)..remove('userId');

      // Set the 'title' field to the formatted date
      newData['title'] = formattedDate;

      return newData;
    }).toList();

    //Preparing Habitica Data
    String habits = '';
    if (habiticaUserId != null && habiticaApiKey != null) {
      final habitica_data =
          HabiticaData(habiticaUserId.toString(), habiticaApiKey.toString());
      habits = await habitica_data.execute();
    }

    // Prepare the data to send in the request
    Map<String, String> data = {
      'habits': habits,
      'goal': interest,
      'journal': journalDataList.toString(),
      'usage': phone_usage_data,
    };
    serverurl =
        serverurl ?? 'https://prasannanrobots.pythonanywhere.com/mentor';

    //try {
    var __response = await http.post(
      Uri.parse(serverurl.toString()),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (__response.statusCode == 200) {
      await _storage.write(key: 'completion', value: __response.body);
      __postprocessdata(__response.body);
    }
    //  } catch (error) {
    //   if (this.mounted) {
    //     setState(() {
    //       result = 'An error occured ${error}';
    //     });
    //   }
    //   } finally {
    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
    // }
  }

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
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ChatPage(messages: messages_data)),
                          );
                        },
                        child: Card(
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
                                    ))))),
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
                                  builder: (context) => VideoPage(
                                      videoId: video.videoId,
                                      description: video.videoDescription),
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
  final String videoDescription;

  Video(
      {required this.title,
      required this.videoId,
      required this.videoDescription});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['title'].toString() ?? '',
      videoId: json['videoId'].toString() ?? '',
      videoDescription: json['videoDescription'].toString() ?? '',
    );
  }
}

class Messages {
  final String role;
  final String content;

  Messages({required this.role, required this.content});
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}
