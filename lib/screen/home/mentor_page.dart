import 'package:intl/intl.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

import '../../utils/data.dart';
import '../../utils/make_request.dart';
import '../journal/journal_editing_page.dart';
import 'video_page.dart';
import 'chat_page.dart';
import '../../utils/loader.dart';
import 'apps_page.dart';
import '../settings/apps_selection_page.dart';
import '../../utils/notifications.dart';

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
    loader.loadjournal();
    super.initState();
    check_permissions();
    loader.getApiKey();
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
              StreamBuilder<Map<String, dynamic>>(
                stream: Data.journalStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final journalDocs = snapshot.data;

                  if (journalDocs == null || journalDocs.isEmpty) {
                    return const Text(
                        'Not wrote a journal yet? Go to journal page');
                  }

                  // Assuming the keys are timestamps in a sortable format
                  final lastEntryKey = journalDocs.keys
                      .reduce((a, b) => a.compareTo(b) > 0 ? a : b);
                  final lastJournalData = journalDocs[lastEntryKey];

                  // Assuming 'title' and 'content' are part of the journal data
                  final lastJournalTitle = lastEntryKey;
                  final lastJournalContent = lastJournalData;
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
                                DateFormat('yyyy-MM-dd')
                                    .format(DateTime.parse(lastJournalTitle)),
                                style: const TextStyle(fontSize: 25),
                              ),
                              IconButton(
                                  tooltip: "Add",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const JournalEditingPage(
                                          journalTitle: '',
                                          journalContent: '',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add)),
                            ],
                          ),
                          subtitle: Text(lastJournalContent),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JournalEditingPage(
                                  journalTitle: lastJournalTitle,
                                  journalContent: lastJournalContent,
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This code runs after the widget is built
      // Add your items to the sink here
      Data.appSink.add(Data
          .selected_apps); // Replace `addItemToSink` and `yourItem` with your actual method and item
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Application>>(
      stream: Data.appStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final appDocs = snapshot.data!;
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
            subtitle: appDocs.isEmpty
                ? const Text(
                    'Select the apps you want to display by long pressing. If changes didn\'t show up click the home again')
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: appDocs.length,
                    itemBuilder: (context, index) {
                      final Application app = appDocs[index];
                      return ListTile(
                        onTap: () async {
                          bool isInstalled =
                              await DeviceApps.isAppInstalled(app.packageName);
                          if (isInstalled) {
                            DeviceApps.openApp(app.packageName);
                          }
                        },
                        title: Text('- ${app.appName}'),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
