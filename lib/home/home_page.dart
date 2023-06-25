import 'package:Bablo/home/apps_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'video_page.dart';
import '../settings/settings_page.dart';
import '../journal/journal_page.dart';
import '../journal/journal_editing_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'habitica.dart';
import 'chat_page.dart';
import 'package:usage_stats/usage_stats.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:device_apps/device_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../settings/apps_selection_page.dart';
import 'data.dart';
import '../settings/auto_request.dart';

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
  final int _selectedIndex = 0;
  List<Video> videos = [];
  List<Messages> messages_data = [];
  List<Application> apps_data = [];
  List<Application> selected_apps_data = [];
  String serverurl = '';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late ScheduleManager scheduleManager;

  List<Application> loadedApps = [];
  Future<void> _loadstuffFromSharedPreferences() async {
    if (loadedApps.isEmpty) {
      loadedApps = await loadApps();
    }

    apps_data = loadedApps;

    final SharedPreferences prefs = await _prefs;
    late TimeOfDay defaultTime;
    final scheduledTime = prefs.getString('scheduledTime');
    defaultTime = scheduledTime != null
        ? TimeOfDay.fromDateTime(DateTime.parse(scheduledTime))
        : TimeOfDay.now();

    scheduleManager = ScheduleManager(callback: _emulateRequest);
    scheduleManager.scheduleEmulateRequest(defaultTime);

    List<String>? selectedAppNames = prefs.getStringList('selectedApps');
    if (selectedAppNames != null) {
      setState(() {
        selected_apps_data = apps_data
            .where((app) => selectedAppNames.contains(app.appName))
            .toList();
      });
    }

    final storedData = await _storage.read(key: 'completion');
    String? serverurl = await _storage.read(key: 'server_url');
    serverurl = serverurl;

    setState(() {
      result = storedData ?? '';
      if (result.isEmpty || result == '') {
        _emulateRequest();
      } else {
        try {
          __postprocessdata(storedData);
        } catch (error) {
          _emulateRequest();
        }
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
            title: const Text('Permission Required'),
            content: const Text(
                'Please grant the usage permission to track app usage.'),
            actions: [
              TextButton(
                child: const Text('OK'),
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
    return outputString;
  }

  void __postprocessdata(var response) {
    var completionMemory = jsonDecode(response);
    Map<String, dynamic> responseData = completionMemory['videos'];
    String completionMessage = completionMemory['completion'].toString();
    messages_data.add(Messages(role: 'assistant', content: completionMessage));
    final videoList = (responseData)
        .entries
        .map((entry) => Video.fromJson({
              'title': entry.key,
              'videoId': entry.value[0],
              'videoDescription': entry.value[1],
            }))
        .toList();
    if (mounted) {
      setState(() {
        isLoading = false;
        videos = videoList;
        result = completionMessage;
      });
    } else {
      if (mounted) {
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
    String? userGoal = await _storage.read(key: 'userGoal');
    String? selfPerception = await _storage.read(key: 'selfPerception');
    serverurl = serverurl;
    String phoneUsageData = '';

    //Preparing the phone usage data
    if (Platform.isAndroid) {
      String? phoneUsage = await getUsage();
      phoneUsageData = phoneUsage.toString();
    }

    //Preparing Journal data
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('journals')
        .where('userId', isEqualTo: userId)
        .where('title',
            isGreaterThan: Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 3))))
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
      final habiticaData =
          HabiticaData(habiticaUserId.toString(), habiticaApiKey.toString());
      habits = await habiticaData.execute();
    }

    // Prepare the data to send in the request
    Map<String, String> data = {
      'habits': habits,
      'goal': interest,
      'journal': journalDataList.toString(),
      'usage': phoneUsageData,
      'usergoal': userGoal.toString(),
      'selfperception': selfPerception.toString(),
    };
    serverurl =
        serverurl ?? 'https://prasannanrobots.pythonanywhere.com/mentor';

    try {
      var response = await http.post(
        Uri.parse(serverurl.toString()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        await _storage.write(key: 'completion', value: response.body);
        __postprocessdata(response.body);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          result = 'An error occured $error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadstuffFromSharedPreferences();

    // scheduleManager = ScheduleManager(callback: _emulateRequest);
  }

  // void _setScheduledTime(TimeOfDay selectedTime) {
  //   setState(() {
  //     scheduleManager.scheduleEmulateRequest(selectedTime);
  //   });
  // }
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
                  Card(
                      color: const Color.fromARGB(255, 19, 19, 19),
                      child: ListTile(
                        onLongPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AppSelectionPage()),
                          );
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AppsPage(apps: apps_data)),
                          );
                        },
                        title: const Text("Apps",
                            style: TextStyle(
                                color: Color.fromARGB(255, 50, 204, 102))),
                        subtitle: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: selected_apps_data.length,
                            itemBuilder: (context, index) {
                              final Application app = selected_apps_data[index];
                              return ListTile(
                                tileColor:
                                    const Color.fromARGB(255, 19, 19, 19),
                                onTap: () async {
                                  bool isInstalled =
                                      await DeviceApps.isAppInstalled(
                                          app.packageName);
                                  if (isInstalled) {
                                    DeviceApps.openApp(app.packageName);
                                  }
                                },
                                title: Text(
                                  app.appName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 50, 204, 102),
                                  ),
                                ),
                              );
                            }),
                      )),
                  const SizedBox(height: 16.0),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('journals')
                        .where('userId', isEqualTo: userId)
                        .orderBy('title', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final journalDocs = snapshot.data?.docs;

                      if (journalDocs == null || journalDocs.isEmpty) {
                        return const Text('No journals available.');
                      }

                      final lastJournalData =
                          journalDocs[0].data() as Map<String, dynamic>;
                      final lastJournalTitle =
                          lastJournalData['title'].toDate().toString();
                      final lastJournalContent =
                          lastJournalData['content'] as String;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Card(
                            color: const Color.fromARGB(255, 19, 19, 19),
                            child: ListTile(
                              title: Text(
                                lastJournalTitle,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 50, 204, 102),
                                ),
                              ),
                              subtitle: Text(
                                lastJournalContent,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 50, 204, 102),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JournalEditingPage(
                                      journalTitle: lastJournalTitle,
                                      journalContent: lastJournalContent,
                                      documentId: journalDocs[0].id,
                                      userId: userId.toString(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  if (isLoading)
                    const Column(children: [
                      SizedBox(height: 16),
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                      SizedBox(height: 10.0),
                      Text("YOLO",
                          style: TextStyle(
                              color: Color.fromARGB(255, 50, 204, 102)))
                    ])
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
                            title: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _emulateRequest();
                                  },
                                  icon: const Icon(Icons.refresh,
                                      color: Color.fromARGB(255, 50, 204, 102)),
                                ),
                                const Text(
                                  "Mentor: ",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 50, 204, 102),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              result,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 50, 204, 102),
                              ),
                            ),
                          ),
                        )),
                  const SizedBox(height: 16.0),
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
                        color: const Color.fromARGB(255, 50, 204, 102),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
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
                icon: Icon(Icons.book),
                label: 'Journal',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color.fromARGB(255, 50, 204, 102),
            unselectedItemColor: Colors.white,
            backgroundColor: Colors.black,
            onTap: (int index) {
              switch (index) {
                case 0:
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MentorPage()));
                  break;
                case 1:
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const JournalPage()));
                  break;
                case 2:
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()));
                  break;
              }
            },
          ),
        ));
  }
}
