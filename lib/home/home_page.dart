import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:device_apps/device_apps.dart';

import '../utils/data.dart';
import 'make_request.dart';
import '../journal/journal_editing_page.dart';
import 'video_page.dart';
import 'chat_page.dart';
import '../utils/loader.dart';
import 'apps_page.dart';
import '../settings/apps_selection_page.dart';
import '../utils/notifications.dart';
import '../journal/journal_page.dart';
import '../settings/settings_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          MentorPage(),
          JournalPage(), // Replace with your Journal page widget
          SettingsPage(), // Replace with your Settings page widget
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.book),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class MentorPage extends StatefulWidget {
  const MentorPage({super.key});

  @override
  _MentorPageState createState() => _MentorPageState();
}

class _MentorPageState extends State<MentorPage> {
  final interestController = TextEditingController();

  String interest = '';
  String result = '';
  bool isLoading = false;
  List<Video> videos = Data.videoList;
  Loader loader = Loader();

  String serverurl = '';
  LocalNotificationService notifier = LocalNotificationService();
  List<Application> loadedApps = [];

  //Gets user's usage data
  void _Makerequest(String interest) async {
    setState(() {
      isLoading = true;
      videos.clear(); // Clear previous videos
      Data.videoList.clear();
    });
    check_permissions();
    DataProcessor dataGetter = DataProcessor();
    //try {
    await dataGetter.execute();
    // } catch (e) {
    //   if (mounted) {
    //     setState(() {
    //       isLoading = false;
    //       result = e.toString();
    //     });
    //  }
    //}

    if (mounted) {
      setState(() {
        isLoading = false;
        result = Data.completion_message;
        videos = Data.videoList;
        print(Data.notification_title);
      });
    }
    notifier.showNotificationAndroid(
        Data.notification_title, Data.notification_body);
  }

  @override
  void initState() {
    super.initState();
    check_permissions();
    loader.loadVideoList().then((value) {
      setState(() {
        videos = value;
      });
    });
    loader.loadcompletion().then((completionMessage) {
      setState(() {
        Data.completion_message = completionMessage ?? "";
        result = Data.completion_message;
        if (result == '') {
          isLoading = true;
          _Makerequest(interest);
        }
      });
    });

    if (Data.port_state == false) {
      Data.port_state = true;
      print("portListening");
      Data.port.listen((message) async {
        print(message);

        Data.completion_message = message['completion'] ?? "";
        Data.videoList = message['videoList'] ?? [];
        change_val();
      });
    }
  }

  void change_val() {
    setState(() {
      videos = Data.videoList;
      result = Data.completion_message;
    });
  }

  void check_permissions() async {
    bool? isPermission = await UsageStats.checkUsagePermission();
    if (isPermission == false) {
      PhoneUsage.showPermissionDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentor')),
      body: SingleChildScrollView(
        // Wrap the body with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppsChooser(),
              const SizedBox(height: 16.0),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(Data.userId)
                    .collection("journal")
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
                    return const Text(
                        'Not wrote a journal yet? Go to journal page');
                  }

                  final lastJournalData =
                      journalDocs[0].data() as Map<String, dynamic>;
                  final timestamp = lastJournalData['title'] as Timestamp;
                  var format = DateFormat('H:m d-M-y');

                  final lastJournalTitle = format.format(timestamp.toDate());
                  final lastJournalContent =
                      lastJournalData['content'] as String;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lastJournalTitle,
                                style: const TextStyle(fontSize: 25),
                              ),
                              IconButton(
                                  tooltip: "Add",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            JournalEditingPage(
                                          journalTitle: '',
                                          journalContent: '',
                                          documentId: null,
                                          userId: Data.userId
                                              .toString(), // Pass null as document ID for a new journal
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add)),
                            ],
                          ),
                          subtitle: Text(
                            lastJournalContent,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JournalEditingPage(
                                  journalTitle: lastJournalTitle,
                                  journalContent: lastJournalContent,
                                  documentId: journalDocs[0].id,
                                  userId: Data.userId.toString(),
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
                  Text(
                    "Mentor is scratching his head",
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    "Please hang on for a while",
                  )
                ])
              else
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChatPage()),
                      );
                    },
                    child: Card(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Mentor",
                              style: TextStyle(fontSize: 25),
                            ),
                            IconButton(
                                tooltip: "Reload",
                                onPressed: () {
                                  setState(() {
                                    isLoading = true;
                                    _Makerequest(interest);
                                  });
                                },
                                icon: const Icon(Icons.refresh)),
                          ],
                        ),
                        subtitle: Text(
                          "$result \n\n Click to chat with mentor",
                        ),
                      ),
                    )),
              const SizedBox(height: 16.0),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];

                  return Card(
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
    );
  }
}

class AppsChooser extends StatefulWidget {
  const AppsChooser({super.key});

  @override
  State<AppsChooser> createState() => _AppsChooserState();
}

class _AppsChooserState extends State<AppsChooser> {
  Loader loader = Loader();
  ValueNotifier<List<Application>> selectedAppsNotifier =
      ValueNotifier<List<Application>>(Data.selected_apps);

  Future<void> load_apps() async {
    await loader.loadSelectedApps();
    if (mounted) {
      selectedAppsNotifier.value = Data.selected_apps;
      print(selectedAppsNotifier.value);
    }
  }

  @override
  void initState() {
    super.initState();
    load_apps();
    selectedAppsNotifier.addListener(updateApps);
  }

  @override
  void dispose() {
    selectedAppsNotifier.removeListener(updateApps);
    super.dispose();
  }

  void updateApps() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedAppsNotifier,
      builder: (context, List<Application> selected_apps_data, _) {
        return Card(
          child: ListTile(
            onLongPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppSelectionPage(),
                ),
              );
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppsPage()),
              );
            },
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Apps",
                  style: TextStyle(fontSize: 25),
                ),
                Icon(
                  Icons.expand,
                )
              ],
            ),
            subtitle: selected_apps_data.isEmpty
                ? const Text(
                    'Select the apps you want to display by long pressing. If changes didn\'t show up click the home again')
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: selected_apps_data.length,
                    itemBuilder: (context, index) {
                      final Application app = selected_apps_data[index];
                      return ListTile(
                        onTap: () async {
                          bool isInstalled =
                              await DeviceApps.isAppInstalled(app.packageName);
                          if (isInstalled) {
                            DeviceApps.openApp(app.packageName);
                          }
                        },
                        title: Text('~ ${app.appName}'),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
